package com.jerin.prnt

import android.content.Context
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterCallbackInformation
import java.util.concurrent.Executors

class ForegroundDispatcher(private val context: Context) {
    companion object {
        private const val TAG = "ForegroundDispatcher"

        private const val CALLBACK_METHOD_KEY = "fg-callback-method-key"

        fun register(context: Context, callbackId: Long) {
            Executors.newCachedThreadPool().execute(
                RegisterCallbackTask(context, callbackId)
            )
        }
    }

    private var flutterEngine: FlutterEngine? = null

    fun dispatch() {
        flutterEngine = FlutterEngine(context)

        val flutterLoader = FlutterInjector.instance().flutterLoader()
        if (!flutterLoader.initialized()) {
            flutterLoader.startInitialization(context)
        }
        flutterLoader.ensureInitializationComplete(context, null)
        val assets = context.assets
        val appBundlePath = flutterLoader.findAppBundlePath()

        flutterEngine?.let {
            AppChannel.registerChannel(context, it)
            GeneratedPluginRegistrant.registerWith(it)

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

    fun destroy() {
        Log.d(TAG, "destroy: Destroy Flutter Engine")
        flutterEngine?.destroy()
        flutterEngine = null
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

            Log.d(TAG, "run: ✅ Registered headless callbacks [$dartForegroundMethodId]")
        }
    }
}