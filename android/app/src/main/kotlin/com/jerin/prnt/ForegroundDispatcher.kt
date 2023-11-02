package com.jerin.prnt

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.ApplicationInfoLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterCallbackInformation
import java.util.concurrent.Executors

class ForegroundDispatcher(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "ForegroundDispatcher"

        private const val CALLBACK_METHOD_KEY = "fg-callback-method-key"

        private const val CHANNEL_NAME = "com.jerin.prnt/foreground"

        private const val initializedMethod = "initialized";

        fun register(context: Context, callbackId: Long) {
            Executors.newCachedThreadPool().execute(
                RegisterCallbackTask(context, callbackId)
            )
        }
    }

    private var flutterEngine: FlutterEngine? = null

    private var channel: MethodChannel? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")

        when(call.method) {

        }
    }

    fun dispatch() {
        val info = ApplicationInfoLoader.load(context)
        val appBundlePath = info.flutterAssetsDir
        val assets = context.assets

        flutterEngine = FlutterEngine(context.applicationContext)
        flutterEngine?.let {
            GeneratedPluginRegistrant.registerWith(it)
            MethodChannel(it.dartExecutor, CHANNEL_NAME).apply {
                channel = this
                setMethodCallHandler(this@ForegroundDispatcher)
            }

            val sharedPreferences = context.getSharedPreferences(TAG, Context.MODE_PRIVATE)
            val dartForegroundCallbackId = sharedPreferences.getLong(CALLBACK_METHOD_KEY, -1L)
            val callbackInfo =
                FlutterCallbackInformation.lookupCallbackInformation(dartForegroundCallbackId)

            if (callbackInfo == null) {
                Log.d(
                    TAG,
                    "startForegroundFlutterEngine: failed to get callback: $dartForegroundCallbackId"
                )
                return
            }

            val dartCallback = DartExecutor.DartCallback(assets, appBundlePath, callbackInfo)
            it.dartExecutor.executeDartCallback(dartCallback)
        }
    }

    class RegisterCallbackTask(
        private val context: Context,
        private val dartForegroundMethodId: Long,
    ) : Runnable {
        override fun run() {
            val sharedPreferences =
                context.getSharedPreferences(TAG, Context.MODE_PRIVATE)
            sharedPreferences.edit().apply {
                putLong(CALLBACK_METHOD_KEY, dartForegroundMethodId)
                apply()
            }
            Log.d(TAG, "run: registered headless callbacks [$dartForegroundMethodId]")
        }
    }
}