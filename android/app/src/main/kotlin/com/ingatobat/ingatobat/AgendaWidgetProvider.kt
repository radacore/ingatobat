package com.ingatobat.ingatobat

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONArray

/** Widget agenda hari ini (FR-14). Data ditulis dari Dart via MethodChannel. */
class AgendaWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS = "ingatobat_widget"
        private const val KEY_ITEMS = "items"
        private const val KEY_COUNT = "count"

        fun updateAll(ctx: Context, itemsJson: String, count: String) {
            ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_ITEMS, itemsJson)
                .putString(KEY_COUNT, count)
                .apply()

            val mgr = AppWidgetManager.getInstance(ctx)
            val ids = mgr.getAppWidgetIds(
                ComponentName(ctx, AgendaWidgetProvider::class.java),
            )
            if (ids.isEmpty()) return
            val intent = Intent(ctx, AgendaWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            ctx.sendBroadcast(intent)
        }
    }

    override fun onUpdate(
        context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, buildViews(context))
        }
    }

    private fun buildViews(ctx: Context): RemoteViews {
        val views = RemoteViews(ctx.packageName, R.layout.widget_agenda)
        val prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val count = prefs.getString(KEY_COUNT, "0") ?: "0"
        views.setTextViewText(R.id.widget_title, "Agenda Hari Ini ($count)")

        val raw = prefs.getString(KEY_ITEMS, "[]") ?: "[]"
        val sb = StringBuilder()
        try {
            val arr = JSONArray(raw)
            for (i in 0 until arr.length()) {
                val o = arr.getJSONObject(i)
                sb.append(o.optString("time")).append(" • ")
                    .append(o.optString("medicine"))
                val member = o.optString("member")
                if (member.isNotEmpty()) sb.append(" (").append(member).append(")")
                if (i < arr.length() - 1) sb.append("\n")
            }
        } catch (_: Exception) {
            // biarkan kosong bila data rusak
        }
        views.setTextViewText(
            R.id.widget_items,
            if (sb.isEmpty()) "Belum ada jadwal hari ini" else sb.toString(),
        )
        return views
    }
}
