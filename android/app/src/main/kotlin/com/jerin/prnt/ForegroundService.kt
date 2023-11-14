package com.jerin.prnt

import android.app.Notification
import android.app.Notification.FOREGROUND_SERVICE_IMMEDIATE
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

class ForegroundService : Service() {
    companion object {
        private const val TAG = "ForegroundService"

        const val SERVICE_NOTIFICATION_CHANNEL_ID = "com.jerin.prnt.ServiceNotificationChannel"

        private var instance: ForegroundService? = null

        private const val NOTIFICATION_ID = 0x2018

        fun start() {
            val context = App.instance?.applicationContext
                ?: throw NullPointerException("No Application Context was found")

            Log.d(TAG, "startService: ")
            ContextCompat.startForegroundService(
                context,
                Intent(context, ForegroundService::class.java)
            )
        }

        fun stop() {
            instance?.stopSelf()
        }

        val isRunning: Boolean
            get() {
                return instance != null
            }
    }

    private val notification: Notification
        get() {
            val newIntent = Intent(this, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                this,
                0,
                newIntent,
                PendingIntent.FLAG_IMMUTABLE
            )

            NotificationCompat.Builder(this, SERVICE_NOTIFICATION_CHANNEL_ID).apply {
                setContentTitle("Print service Running")
                setContentText("Tap to manage")
                setContentIntent(pendingIntent)
                setSmallIcon(android.R.drawable.ic_menu_info_details)
                setOnlyAlertOnce(true)
                setOngoing(true)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    foregroundServiceBehavior = FOREGROUND_SERVICE_IMMEDIATE
                }
                return build()
            }
        }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: ")

        startForeground(NOTIFICATION_ID, notification)

        ForegroundDispatcher(this).dispatch()
        instance = this

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }

    override fun onBind(p0: Intent?): IBinder? {
        Log.d(TAG, "onBind: ")
        return null
    }
}