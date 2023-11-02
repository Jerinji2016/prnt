package com.jerin.prnt

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
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

        fun start(context: Context) {
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
                setContentTitle("PrintBot")
                setContentText("Printer Service Running (Dineazy)")
                setContentIntent(pendingIntent)
                setSmallIcon(android.R.drawable.ic_menu_info_details)
                setOnlyAlertOnce(true)
                setOngoing(true)
                return build()
            }
        }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: ")

        startForeground(NOTIFICATION_ID, notification)

        ForegroundDispatcher(applicationContext).dispatch()
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