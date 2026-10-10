package com.ingatobat.ingatobat

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/** Penjadwalan alarm tepat waktu via AlarmManager. */
object AlarmScheduler {

    fun schedule(ctx: Context, alarm: StoredAlarm) {
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = broadcastIntent(ctx, alarm)
        val triggerAt = alarm.triggerAtMs
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !am.canScheduleExactAlarms()
            ) {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pi)
            } else {
                am.setAlarmClock(
                    AlarmManager.AlarmClockInfo(triggerAt, showIntent(ctx, alarm)),
                    pi,
                )
            }
        } catch (_: SecurityException) {
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pi)
        }
        AlarmStore.save(ctx, alarm)
    }

    fun cancel(ctx: Context, id: String) {
        val alarm = AlarmStore.loadAll(ctx).firstOrNull { it.id == id } ?: return
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.cancel(broadcastIntent(ctx, alarm))
        AlarmStore.remove(ctx, id)
    }

    fun cancelAll(ctx: Context) {
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        AlarmStore.loadAll(ctx).forEach { am.cancel(broadcastIntent(ctx, it)) }
        AlarmStore.clear(ctx)
    }

    fun rescheduleAll(ctx: Context) {
        AlarmStore.loadAll(ctx).forEach { schedule(ctx, it) }
    }

    private fun piFlags(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

    private fun broadcastIntent(ctx: Context, alarm: StoredAlarm): PendingIntent {
        val intent = Intent(ctx, AlarmReceiver::class.java).apply {
            action = "com.ingatobat.ALARM"
            putExtra("id", alarm.id)
        }
        return PendingIntent.getBroadcast(ctx, alarm.id.hashCode(), intent, piFlags())
    }

    private fun showIntent(ctx: Context, alarm: StoredAlarm): PendingIntent {
        val intent = Intent(ctx, MainActivity::class.java).apply {
            action = "com.ingatobat.SHOW_ALARM"
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putStringArrayListExtra("doseLogIds", ArrayList(alarm.doseLogIds))
        }
        return PendingIntent.getActivity(
            ctx, alarm.id.hashCode() + 1, intent, piFlags(),
        )
    }
}
