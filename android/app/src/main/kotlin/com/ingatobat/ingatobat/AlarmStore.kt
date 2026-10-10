package com.ingatobat.ingatobat

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/** Satu alarm yang dijadwalkan ke AlarmManager. */
data class StoredAlarm(
    val id: String,
    val triggerAtMs: Long,
    val title: String,
    val body: String,
    val toneUri: String?,
    val ttsEnabled: Boolean,
    val ttsText: String?,
    val fullAlarm: Boolean,
    val doseLogIds: List<String>,
)

/** Penyimpanan alarm (SharedPreferences) agar tetap ada setelah reboot. */
object AlarmStore {
    private const val PREF = "ingatobat_alarms"
    private const val KEY_ALARMS = "alarms"
    private const val KEY_INITIAL = "initial_alarm_ids"

    private fun prefs(ctx: Context) =
        ctx.getSharedPreferences(PREF, Context.MODE_PRIVATE)

    fun save(ctx: Context, alarm: StoredAlarm) {
        val all = loadAll(ctx).toMutableList()
        all.removeAll { it.id == alarm.id }
        all.add(alarm)
        persist(ctx, all)
    }

    fun remove(ctx: Context, id: String) {
        val all = loadAll(ctx).toMutableList()
        all.removeAll { it.id == id }
        persist(ctx, all)
    }

    fun clear(ctx: Context) {
        prefs(ctx).edit().remove(KEY_ALARMS).apply()
    }

    fun loadAll(ctx: Context): List<StoredAlarm> {
        val raw = prefs(ctx).getString(KEY_ALARMS, null) ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).map { fromJson(arr.getJSONObject(it)) }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun persist(ctx: Context, list: List<StoredAlarm>) {
        val arr = JSONArray()
        list.forEach { arr.put(toJson(it)) }
        prefs(ctx).edit().putString(KEY_ALARMS, arr.toString()).apply()
    }

    fun encode(a: StoredAlarm): String = toJson(a).toString()

    fun decode(raw: String): StoredAlarm? = try {
        fromJson(JSONObject(raw))
    } catch (_: Exception) {
        null
    }

    fun toJson(a: StoredAlarm): JSONObject = JSONObject().apply {
        put("id", a.id)
        put("triggerAtMs", a.triggerAtMs)
        put("title", a.title)
        put("body", a.body)
        put("toneUri", a.toneUri ?: JSONObject.NULL)
        put("ttsEnabled", a.ttsEnabled)
        put("ttsText", a.ttsText ?: JSONObject.NULL)
        put("fullAlarm", a.fullAlarm)
        put("doseLogIds", JSONArray(a.doseLogIds))
    }

    fun fromJson(o: JSONObject): StoredAlarm = StoredAlarm(
        id = o.getString("id"),
        triggerAtMs = o.optLong("triggerAtMs", 0L),
        title = o.optString("title", "Waktunya Minum Obat"),
        body = o.optString("body", ""),
        toneUri = if (o.isNull("toneUri")) null else o.optString("toneUri"),
        ttsEnabled = o.optBoolean("ttsEnabled", true),
        ttsText = if (o.isNull("ttsText")) null else o.optString("ttsText"),
        fullAlarm = o.optBoolean("fullAlarm", true),
        doseLogIds = o.optJSONArray("doseLogIds")?.let { arr ->
            (0 until arr.length()).map { arr.getString(it) }
        } ?: emptyList(),
    )

    /** Simpan payload dosis agar bisa diambil Dart via `getInitialAlarm`. */
    fun setInitialAlarmIds(ctx: Context, ids: List<String>) {
        prefs(ctx).edit().putString(KEY_INITIAL, JSONArray(ids).toString()).apply()
    }

    fun takeInitialAlarmIds(ctx: Context): List<String> {
        val raw = prefs(ctx).getString(KEY_INITIAL, null)
        prefs(ctx).edit().remove(KEY_INITIAL).apply()
        if (raw == null) return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).map { arr.getString(it) }
        } catch (_: Exception) {
            emptyList()
        }
    }
}
