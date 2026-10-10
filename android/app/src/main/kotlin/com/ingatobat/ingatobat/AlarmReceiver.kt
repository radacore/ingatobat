package com.ingatobat.ingatobat

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/** Menerima tembakan AlarmManager dan menjalankan alarm. */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getStringExtra("id") ?: return
        val alarm = AlarmStore.loadAll(context).firstOrNull { it.id == id } ?: return

        if (!alarm.fullAlarm) {
            // Mode pantau: cukup notifikasi, tidak ada suara keras.
            val notif = Notifier.buildAlarm(context, alarm, fullScreen = false)
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE)
                    as android.app.NotificationManager
            nm.notify(id.hashCode(), notif)
            return
        }

        val svc = Intent(context, AlarmService::class.java).apply {
            action = AlarmService.ACTION_FIRE
            putExtra("id", alarm.id)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(svc)
        } else {
            context.startService(svc)
        }
    }
}
