package com.jerin.prnt

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.Size
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import java.io.ByteArrayOutputStream
import kotlin.math.absoluteValue

object Utils {
    private const val TAG = "Utils"

    private const val KEY_DISPLAY_WIDTH = "d-width"
    private const val HEY_DISPLAY_HEIGHT = "d-height"

    private fun getDisplaySize(context: Context): Size? {
        val sharedPreferences = context.getSharedPreferences(TAG, Context.MODE_PRIVATE)
        val width = sharedPreferences.getInt(KEY_DISPLAY_WIDTH, -1)
        val height = sharedPreferences.getInt(HEY_DISPLAY_HEIGHT, -1)

        if (width == -1 || height == -1)
            return null

        return Size(width, height)
    }

    fun didSaveDisplaySize(context: Context): Boolean {
        return getDisplaySize(context) != null
    }

    fun saveDisplaySize(context: Context) {
        val isPortrait =
            context.resources.configuration.orientation == Configuration.ORIENTATION_PORTRAIT

        val displayMetrics = context.resources.displayMetrics
        val w = (displayMetrics.widthPixels / displayMetrics.density).toInt()
        val h = (displayMetrics.heightPixels / displayMetrics.density).toInt()

        val width = if (isPortrait) w else h
        val height = if (isPortrait) h else w

        val sharedPreferences = context.getSharedPreferences(TAG, Context.MODE_PRIVATE)
        sharedPreferences.edit().apply {
            putInt(KEY_DISPLAY_WIDTH, width)
            putInt(HEY_DISPLAY_HEIGHT, height)
            apply()
        }
        Log.d(TAG, "saveDisplaySize: ✅ Display Size Saved")
    }

    fun WebView.toBitmap(offsetWidth: Double, offsetHeight: Double): Bitmap? {
        if (offsetHeight > 0 && offsetWidth > 0) {
            val width = (offsetWidth * this.scale).absoluteValue.toInt()
            val height = (offsetHeight * this.scale).absoluteValue.toInt()
            this.measure(
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            )
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            this.draw(canvas)
            return bitmap
        }
        return null
    }

    fun Bitmap.toByteArray(): ByteArray {
        ByteArrayOutputStream().apply {
            compress(Bitmap.CompressFormat.PNG, 0, this)
            return toByteArray()
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    fun convertHtmlToImageBytes(context: Context, content: String, result: MethodChannel.Result) {
        val webView = WebView(context)

        val displaySize = getDisplaySize(context)
        if (displaySize == null) {
            result.error("no_display_size", "Failed to get Display Size", null)
            return
        }

        val width = displaySize.width
        val height = displaySize.height
        Log.d(TAG, "convertHtmlToImageBytes: width: $width, height: $height")

        webView.layout(0, 0, width, height)
        webView.loadDataWithBaseURL(null, content, "text/HTML", "UTF-8", null)
        webView.setInitialScale(100)
        webView.settings.javaScriptEnabled = true
        webView.settings.useWideViewPort = true
        webView.settings.javaScriptCanOpenWindowsAutomatically = true
        webView.settings.loadWithOverviewMode = true
        webView.settings.builtInZoomControls = false

        WebView.enableSlowWholeDocumentDraw()

        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String) {
                super.onPageFinished(view, url)

                // delay 300 ms for every `height` 2000
                val duration = (height / 2000) * 300

                Handler(Looper.getMainLooper()).postDelayed({
                    webView.evaluateJavascript("(function () {\n" +
                            "        let billHeight = 0;\n" +
                            "        const children = document.body.children;\n" +
                            "        for (let i = 0; i < children.length; i++) {\n" +
                            "            billHeight += children[i].clientHeight;\n" +
                            "        }\n" +
                            "        return [document.body.offsetWidth, billHeight];\n" +
                            "    })()") {
                        val xy = JSONArray(it)

                        Log.d(TAG, "onPageFinished: $xy")
                        val offsetWidth = xy[0].toString()
                        var offsetHeight = xy[1].toString()
                        if (offsetHeight.toInt() < 1000) {
                            offsetHeight = (xy[1].toString().toInt() + 20).toString()
                        }

                        val data = webView.toBitmap(offsetWidth.toDouble(), offsetHeight.toDouble())
                        if (data != null) {
                            val bytes = data.toByteArray()
                            Log.d(TAG, "onPageFinished: Got Snapshot")
                            result.success(bytes)
                        }
                    }
                }, duration.toLong())
            }
        }
    }
}