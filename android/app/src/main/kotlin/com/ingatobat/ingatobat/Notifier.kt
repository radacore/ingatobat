package com.ingatobat.ingatobat

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build

/** Kanal dan pembuatan notifikasi native. */
object Notifier {
    const val CHANNEL_ALARM = "ingatobat_alarm"
    const val CHANNEL_MONITOR = "ingatobat_monitor"
    const val CHANNEL_GENERAL = "ingatobat_general"

    fun ensureChannels(ctx: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (nm.getNotificationChannel(CHANNEL_ALARM) == null) {
            val ch = NotificationChannel(
                CHANNEL_ALARM, "Alarm Minum Obat",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Alarm keras saat waktu minum obat"
                setBypassDnd(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setSound(null, null)
                enableVibration(true)
            }
            nm.createNotificationChannel(ch)
        }

        if (nm.getNotificationChannel(CHANNEL_MONITOR) == null) {
            val ch = NotificationChannel(
                CHANNEL_MONITOR, "Pengingat Obat",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Pengingat minum obat (mode pantau)"
                val attrs = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION), attrs)
                enableVibration(true)
            }
            nm.createNotificationChannel(ch)
        }

        if (nm.getNotificationChannel(CHANNEL_GENERAL) == null) {
            val ch = NotificationChannel(
                CHANNEL_GENERAL, "Informasi",
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply { description = "Stok menipis, cadangan, dan info lain" }
            nm.createNotificationChannel(ch)
        }
    }

    private fun builder(ctx: Context, channelId: String): Notification.Builder =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(ctx, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(ctx)
        }

    private fun piFlags(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

    private fun contentIntent(ctx: Context, a: StoredAlarm, code: Int): PendingIntent {
        val intent = Intent(ctx, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putStringArrayListExtra("doseLogIds", ArrayList(a.doseLogIds))
        }
        return PendingIntent.getActivity(ctx, code, intent, piFlags())
    }

    private fun actionIntent(
        ctx: Context, a: StoredAlarm, action: String, code: Int,
    ): PendingIntent {
        val intent = Intent(ctx, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("alarmAction", action)
            putStringArrayListExtra("doseLogIds", ArrayList(a.doseLogIds))
        }
        return PendingIntent.getActivity(ctx, code, intent, piFlags())
    }

    fun buildAlarm(ctx: Context, a: StoredAlarm, fullScreen: Boolean): Notification {
        ensureChannels(ctx)
        val code = a.id.hashCode()
        val b = builder(ctx, if (fullScreen) CHANNEL_ALARM else CHANNEL_MONITOR)
            .setContentTitle(a.title)
            .setContentText(a.body)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setCategory(
                if (fullScreen) Notification.CATEGORY_ALARM
                else Notification.CATEGORY_REMINDER,
            )
            .setOngoing(fullScreen)
            .setAutoCancel(!fullScreen)
            .setContentIntent(contentIntent(ctx, a, code))
            .setVisibility(Notification.VISIBILITY_PUBLIC)

        if (fullScreen) {
            b.setFullScreenIntent(contentIntent(ctx, a, code + 1), true)
            b.setSound(null)
        }

        b.addAction(
            Notification.Action.Builder(
                null, "Sudah Minum", actionIntent(ctx, a, "taken", code + 10),
            ).build(),
        )
        b.addAction(
            Notification.Action.Builder(
                null, "Tunda", actionIntent(ctx, a, "snooze", code + 11),
            ).build(),
        )
        b.addAction(
            Notification.Action.Builder(
                null, "Lewati", actionIntent(ctx, a, "skip", code + 12),
            ).build(),
        )
        return b.build()
    }

    fun show(ctx: Context, id: Int, title: String, body: String, highPriority: Boolean) {
        ensureChannels(ctx)
        val notif = builder(ctx, if (highPriority) CHANNEL_MONITOR else CHANNEL_GENERAL)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setAutoCancel(true)
            .build()
        val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(id, notif)
    }

    fun cancel(ctx: Context, id: Int) {
        (ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .cancel(id)
    }

    fun cancelAll(ctx: Context) {
        (ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .cancelAll()
    }
}
