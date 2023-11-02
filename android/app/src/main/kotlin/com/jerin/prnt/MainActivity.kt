package com.jerin.prnt

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "MainActivity"

        private const val CHANNEL_NAME = "com.jerin.prnt/main"

        private const val registerCallbackMethod = "registerCallbackId"
        private const val startServiceMethod = "startFgService"

        private const val getServiceStatusMethod = "getServiceStatus"
        private const val stopServiceMethod = "stopServiceMethod"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel = NotificationChannel(
                ForegroundService.SERVICE_NOTIFICATION_CHANNEL_ID,
                "Service Notification",
                NotificationManager.IMPORTANCE_HIGH
            )

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(notificationChannel)
            Log.d(TAG, "onCreate: Notification Channel Created")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")

        when (call.method) {
            registerCallbackMethod -> {
                try {
                    val callbackId = call.arguments as Long
                    ForegroundDispatcher.register(applicationContext, callbackId)
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "onMethodCall: ", e)
                    result.success(false)
                }
            }

            startServiceMethod -> {
                try {
                    ForegroundService.start(applicationContext)
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "onMethodCall: ", e)
                    result.success(false)
                }
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
