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

        private const val REGISTER_CALLBACK_ID_METHOD = "registerCallbackId"

        private const val START_SERVICE_METHOD = "startFgService"
        private const val STOP_SERVICE_METHOD = "stopServiceMethod"
        private const val GET_SERVICE_STATUS_METHOD = "getServiceStatus"

        private const val CONTENT_TO_IMAGE_METHOD = "contentToImage"

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
            REGISTER_CALLBACK_ID_METHOD -> {
                try {
                    val callbackId = call.arguments as Long
                    ForegroundDispatcher.register(context, callbackId)
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "onMethodCall: ", e)
                    result.success(false)
                }
            }

            START_SERVICE_METHOD -> {
                try {
                    ForegroundService.start()
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "onMethodCall: ", e)
                    result.success(false)
                }
            }

            CONTENT_TO_IMAGE_METHOD -> {
                val args = call.arguments as String
                Utils.convertHtmlToImageBytes(context, args, result)
            }

            GET_SERVICE_STATUS_METHOD -> result.success(ForegroundService.isRunning)

            STOP_SERVICE_METHOD -> {
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