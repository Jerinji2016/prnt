package com.jerin.prnt

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.util.Log
import io.flutter.app.FlutterApplication

class App : FlutterApplication() {
    companion object {
        private const val TAG = "App"

        @SuppressLint("StaticFieldLeak")
        private var mInstance: App? = null

        val instance: App?
            get() {
                return mInstance
            }
    }

    override fun onCreate() {
        super.onCreate()
        mInstance = this

        createNotificationChannel()
    }

    private fun createNotificationChannel() {
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
}