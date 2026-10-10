package com.ingatobat.ingatobat

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Menyusun ulang alarm setelah perangkat dinyalakan atau aplikasi diperbarui. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON" ->
                AlarmScheduler.rescheduleAll(context)
        }
    }
}
