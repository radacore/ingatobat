package com.ingatobat.ingatobat

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.OpenableColumns
import android.provider.Settings
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/**
 * Jembatan native `com.ingatobat/alarm`: alarm, izin, TTS, notifikasi,
 * widget, dan penyimpanan SAF.
 */
class MainActivity : FlutterActivity() {

    private val channelName = "com.ingatobat/alarm"
    private var channel: MethodChannel? = null
    private val io = Executors.newSingleThreadExecutor()

    private var previewPlayer: MediaPlayer? = null

    private var folderResult: MethodChannel.Result? = null
    private var fileResult: MethodChannel.Result? = null

    private companion object {
        const val REQ_TREE = 4711
        const val REQ_FILE = 4712
        const val REQ_NOTIF = 4713
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Notifier.ensureChannels(this)

        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel = ch
        ch.setMethodCallHandler { call, result ->
            try {
                handleCall(call, result)
            } catch (e: Exception) {
                result.error("native", e.message, null)
            }
        }

        handleIntentExtras(intent)
    }

    private fun handleCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // ---------------------------------------------------------- Awal
            "getInitialAlarm" -> result.success(AlarmStore.takeInitialAlarmIds(this))

            // ------------------------------------------------------ Perizinan
            "hasNotificationPermission" -> result.success(hasNotificationPermission())
            "hasExactAlarmPermission" -> result.success(hasExactAlarmPermission())
            "isIgnoringBatteryOptimizations" ->
                result.success(isIgnoringBatteryOptimizations())
            "hasDndAccess" -> result.success(hasDndAccess())
            "requestNotificationPermission" -> {
                requestNotificationPermission()
                result.success(null)
            }
            "openExactAlarmSettings" -> {
                openExactAlarmSettings()
                result.success(null)
            }
            "openDndSettings" -> {
                startActivitySafe(Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS))
                result.success(null)
            }
            "openBatterySettings" -> {
                startActivitySafe(
                    Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                        .setData(Uri.parse("package:$packageName")),
                )
                result.success(null)
            }
            "openNotificationSettings" -> {
                openNotificationSettings()
                result.success(null)
            }

            // ----------------------------------------------------------- TTS
            "isTtsAvailable" -> checkTts(result)
            "testTts" -> {
                testTts(call.argument<String>("text") ?: "")
                result.success(null)
            }

            // ---------------------------------------------------- Penjadwalan
            "scheduleAlarm" -> {
                scheduleAlarm(call)
                result.success(null)
            }
            "cancelAlarm" -> {
                AlarmScheduler.cancel(this, call.argument<String>("id") ?: "")
                result.success(null)
            }
            "cancelAll" -> {
                AlarmScheduler.cancelAll(this)
                result.success(null)
            }
            "previewAlarm" -> {
                previewAlarm(
                    call.argument<String>("toneUri"),
                    call.argument<Int>("volume") ?: 80,
                )
                result.success(null)
            }
            "stopPreview" -> {
                stopPreview()
                result.success(null)
            }
            "startAlarmNow" -> {
                startAlarmNow(call)
                result.success(null)
            }
            "stopAlarm" -> {
                val svc = Intent(this, AlarmService::class.java)
                    .setAction(AlarmService.ACTION_STOP)
                startService(svc)
                result.success(null)
            }

            // ---------------------------------------------------- Notifikasi
            "showNotification" -> {
                Notifier.show(
                    this,
                    call.argument<Int>("id") ?: 0,
                    call.argument<String>("title") ?: "",
                    call.argument<String>("body") ?: "",
                    call.argument<Boolean>("highPriority") ?: false,
                )
                result.success(null)
            }
            "cancelNotification" -> {
                Notifier.cancel(this, call.argument<Int>("id") ?: 0)
                result.success(null)
            }
            "cancelAllNotifications" -> {
                Notifier.cancelAll(this)
                result.success(null)
            }
            "updateAgendaWidget" -> {
                AgendaWidgetProvider.updateAll(
                    this,
                    call.argument<String>("items") ?: "[]",
                    call.argument<String>("count") ?: "0",
                )
                result.success(null)
            }
            "restartApp" -> {
                restartApp()
                result.success(null)
            }

            // ----------------------------------------------------------- SAF
            "pickBackupFolder" -> {
                folderResult = result
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                    addFlags(
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                            Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
                    )
                }
                startActivityForResult(intent, REQ_TREE)
            }
            "pickFile" -> {
                fileResult = result
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "*/*"
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                startActivityForResult(intent, REQ_FILE)
            }
            "writeBackupToFolder" -> result.success(
                writeBackupToFolder(
                    call.argument<String>("uri") ?: "",
                    call.argument<String>("name") ?: "backup.zip",
                    call.argument<ByteArray>("bytes") ?: ByteArray(0),
                ),
            )
            "listBackups" -> result.success(
                listBackups(call.argument<String>("uri") ?: ""),
            )
            "deleteDocument" -> {
                deleteDocument(call.argument<String>("uri") ?: "")
                result.success(null)
            }
            "getAlarmTones" -> result.success(getAlarmTones())

            else -> result.notImplemented()
        }
    }

    // ------------------------------------------------------------- Intent

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntentExtras(intent)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
        val uri = data?.data
        when (requestCode) {
            REQ_TREE -> {
                val res = folderResult
                folderResult = null
                if (uri == null) {
                    res?.success(null)
                    return
                }
                try {
                    contentResolver.takePersistableUriPermission(
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                    )
                } catch (_: Exception) {
                    // izin persisten opsional
                }
                res?.success(uri.toString())
            }
            REQ_FILE -> {
                val res = fileResult
                fileResult = null
                if (uri == null) {
                    res?.success(null)
                    return
                }
                try {
                    val name = queryDisplayName(uri) ?: "backup.zip"
                    val bytes = contentResolver.openInputStream(uri)
                        ?.use { it.readBytes() } ?: ByteArray(0)
                    res?.success(mapOf("name" to name, "bytes" to bytes))
                } catch (e: Exception) {
                    res?.error("saf", e.message, null)
                }
            }
        }
    }

    private fun handleIntentExtras(intent: Intent?) {
        if (intent == null) return
        val ids = intent.getStringArrayListExtra("doseLogIds")
        val action = intent.getStringExtra("alarmAction")

        if (action != null) {
            deliverToDart(
                "onAlarmAction",
                mapOf("action" to action, "doseLogIds" to (ids ?: emptyList<String>())),
            )
        } else if (!ids.isNullOrEmpty()) {
            AlarmStore.setInitialAlarmIds(this, ids)
            deliverToDart("onAlarmLaunch", mapOf("doseLogIds" to ids))
        }

        intent.removeExtra("doseLogIds")
        intent.removeExtra("alarmAction")
    }

    /** Kirim ke Dart dengan jeda singkat agar handler Dart siap lebih dulu. */
    private fun deliverToDart(method: String, args: Map<String, Any?>) {
        Handler(Looper.getMainLooper()).postDelayed(
            { channel?.invokeMethod(method, args) },
            600,
        )
    }

    // ------------------------------------------------------- Penjadwalan

    private fun scheduleAlarm(call: MethodCall) {
        val id = call.argument<String>("id") ?: return
        val triggerAt = (call.argument<Number>("triggerAtMs") ?: return).toLong()
        val alarm = StoredAlarm(
            id = id,
            triggerAtMs = triggerAt,
            title = call.argument<String>("title") ?: "Waktunya Minum Obat",
            body = call.argument<String>("body") ?: "",
            toneUri = call.argument<String>("toneUri"),
            ttsEnabled = call.argument<Boolean>("ttsEnabled") ?: true,
            ttsText = call.argument<String>("ttsText"),
            fullAlarm = call.argument<Boolean>("fullAlarm") ?: true,
            doseLogIds = call.argument<List<String>>("doseLogIds") ?: emptyList(),
        )
        AlarmScheduler.schedule(this, alarm)
    }

    private fun startAlarmNow(call: MethodCall) {
        val alarm = StoredAlarm(
            id = "test_${System.currentTimeMillis()}",
            triggerAtMs = System.currentTimeMillis(),
            title = call.argument<String>("title") ?: "Uji Alarm",
            body = call.argument<String>("body") ?: "",
            toneUri = call.argument<String>("toneUri"),
            ttsEnabled = call.argument<Boolean>("ttsEnabled") ?: false,
            ttsText = call.argument<String>("ttsText"),
            fullAlarm = true,
            doseLogIds = call.argument<List<String>>("doseLogIds") ?: emptyList(),
        )
        val svc = Intent(this, AlarmService::class.java).apply {
            action = AlarmService.ACTION_START_NOW
            putExtra("payload", AlarmStore.encode(alarm))
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(svc)
        } else {
            startService(svc)
        }
    }

    private fun previewAlarm(toneUri: String?, volume: Int) {
        stopPreview()
        val uri = if (toneUri.isNullOrEmpty()) {
            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        } else {
            Uri.parse(toneUri)
        }
        try {
            val v = volume.coerceIn(0, 100) / 100f
            previewPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                setDataSource(this@MainActivity, uri)
                isLooping = true
                setVolume(v, v)
                prepare()
                start()
            }
        } catch (_: Exception) {
            previewPlayer = null
        }
    }

    private fun stopPreview() {
        try {
            previewPlayer?.stop()
        } catch (_: Exception) {
        }
        try {
            previewPlayer?.release()
        } catch (_: Exception) {
        }
        previewPlayer = null
    }

    // -------------------------------------------------------- Perizinan

    private fun hasNotificationPermission(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED
        } else {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.areNotificationsEnabled()
        }

    private fun hasExactAlarmPermission(): Boolean =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (getSystemService(Context.ALARM_SERVICE) as AlarmManager).canScheduleExactAlarms()
        } else {
            true
        }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun hasDndAccess(): Boolean {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return nm.isNotificationPolicyAccessGranted
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissions(
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                REQ_NOTIF,
            )
        }
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            startActivitySafe(
                Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                    .setData(Uri.parse("package:$packageName")),
            )
        }
    }

    private fun openNotificationSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.parse("package:$packageName"))
        }
        startActivitySafe(intent)
    }

    private fun startActivitySafe(intent: Intent) {
        try {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (_: Exception) {
            // abaikan bila layar pengaturan tidak tersedia
        }
    }

    // -------------------------------------------------------------- TTS

    private fun checkTts(result: MethodChannel.Result) {
        io.execute {
            var ok = false
            var instance: TextToSpeech? = null
            val latch = CountDownLatch(1)
            try {
                instance = TextToSpeech(applicationContext) { status ->
                    ok = status == TextToSpeech.SUCCESS
                    latch.countDown()
                }
                latch.await(1500, TimeUnit.MILLISECONDS)
            } catch (_: Exception) {
                ok = false
            } finally {
                try {
                    instance?.shutdown()
                } catch (_: Exception) {
                }
            }
            val available = ok
            runOnUiThread { result.success(available) }
        }
    }

    private fun testTts(text: String) {
        var instance: TextToSpeech? = null
        instance = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                try {
                    instance?.language = Locale("id", "ID")
                } catch (_: Exception) {
                    // pakai bahasa default bila id-ID tidak ada
                }
                instance?.setOnUtteranceProgressListener(
                    object : UtteranceProgressListener() {
                        override fun onStart(utteranceId: String?) = Unit
                        override fun onDone(utteranceId: String?) {
                            instance?.shutdown()
                        }

                        @Deprecated("Deprecated in Java")
                        override fun onError(utteranceId: String?) {
                            instance?.shutdown()
                        }
                    },
                )
                instance?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "test")
            } else {
                instance?.shutdown()
            }
        }
    }

    // ---------------------------------------------------------- Nada alarm

    private fun getAlarmTones(): List<Map<String, String>> {
        val list = mutableListOf<Map<String, String>>()
        try {
            val rm = RingtoneManager(this)
            rm.setType(
                RingtoneManager.TYPE_ALARM or
                    RingtoneManager.TYPE_RINGTONE or
                    RingtoneManager.TYPE_NOTIFICATION,
            )
            val cursor = rm.cursor
            while (cursor.moveToNext()) {
                val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                    ?: continue
                val uri = rm.getRingtoneUri(cursor.position)?.toString() ?: continue
                list.add(mapOf("title" to title, "uri" to uri))
            }
        } catch (_: Exception) {
            // kembalikan daftar kosong bila tidak dapat dibaca
        }
        return list
    }

    // --------------------------------------------------------------- SAF

    private fun queryDisplayName(uri: Uri): String? {
        try {
            contentResolver.query(
                uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null,
            )?.use { c ->
                if (c.moveToFirst()) return c.getString(0)
            }
        } catch (_: Exception) {
            // jatuh ke lastPathSegment
        }
        return uri.lastPathSegment
    }

    private fun writeBackupToFolder(
        treeUri: String, name: String, bytes: ByteArray,
    ): Map<String, String>? {
        if (treeUri.isEmpty()) return null
        val tree = DocumentFile.fromTreeUri(this, Uri.parse(treeUri)) ?: return null
        try {
            tree.findFile(name)?.delete()
            val file = tree.createFile("application/zip", name) ?: return null
            contentResolver.openOutputStream(file.uri)?.use { it.write(bytes) }
            return mapOf("name" to name, "uri" to file.uri.toString())
        } catch (_: Exception) {
            return null
        }
    }

    private fun listBackups(treeUri: String): List<Map<String, String>> {
        if (treeUri.isEmpty()) return emptyList()
        val tree = DocumentFile.fromTreeUri(this, Uri.parse(treeUri))
            ?: return emptyList()
        return try {
            tree.listFiles()
                .filter { it.isFile && (it.name?.endsWith(".zip") == true) }
                .map {
                    mapOf(
                        "name" to (it.name ?: ""),
                        "uri" to it.uri.toString(),
                    )
                }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun deleteDocument(docUri: String) {
        if (docUri.isEmpty()) return
        try {
            DocumentFile.fromSingleUri(this, Uri.parse(docUri))?.delete()
        } catch (_: Exception) {
            // abaikan bila gagal dihapus
        }
    }

    // ------------------------------------------------------------ Restart

    private fun restartApp() {
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pi = PendingIntent.getActivity(this, 987654, intent, flags)
            val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            am.set(AlarmManager.RTC, System.currentTimeMillis() + 300, pi)
        } catch (_: Exception) {
            // abaikan; proses tetap diakhiri
        }
        Runtime.getRuntime().exit(0)
    }

    override fun onDestroy() {
        stopPreview()
        io.shutdown()
        super.onDestroy()
    }
}
