package com.jerin.prnt

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AppChannel private constructor(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "AppChannel"

        private const val CHANNEL_NAME = "com.jerin.prnt/main"

        private const val registerCallbackMethod = "registerCallbackId"
        private const val startServiceMethod = "startFgService"

        private const val contentToImage = "contentToImage"

        private const val getServiceStatusMethod = "getServiceStatus"
        private const val stopServiceMethod = "stopServiceMethod"

        fun registerChannel(context: Context, flutterEngine: FlutterEngine) {
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL_NAME
            ).setMethodCallHandler(AppChannel(context))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            registerCallbackMethod -> {
                try {
                    val callbackId = call.arguments as Long
                    ForegroundDispatcher.register(context, callbackId)
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "onMethodCall: ", e)
                    result.success(false)
                }
            }

            startServiceMethod -> {
                try {
                    ForegroundService.start()
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "onMethodCall: ", e)
                    result.success(false)
                }
            }

            contentToImage -> {
                val args = call.arguments as String
                Utils.convertHtmlToImageBytes(context, args, result)
            }

            getServiceStatusMethod -> result.success(ForegroundService.isRunning)

            stopServiceMethod -> {
                try {
                    ForegroundService.stop()
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "onMethodCall: ", e)
                }
            }
        }
    }
}