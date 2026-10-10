package com.ingatobat.ingatobat

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.speech.tts.TextToSpeech
import java.util.Locale

/**
 * Foreground service yang membunyikan alarm: nada looping + getar + TTS,
 * dengan batas waktu otomatis.
 */
class AlarmService : Service() {

    companion object {
        const val ACTION_FIRE = "com.ingatobat.ACTION_FIRE"
        const val ACTION_START_NOW = "com.ingatobat.ACTION_START_NOW"
        const val ACTION_STOP = "com.ingatobat.ACTION_STOP"
        private const val NOTIF_ID = 77001
        private const val TIMEOUT_MS = 5 * 60 * 1000L
    }

    private var player: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var tts: TextToSpeech? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private val handler = Handler(Looper.getMainLooper())
    private val stopRunnable = Runnable { stopEverything() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopEverything()
                return START_NOT_STICKY
            }
            ACTION_START_NOW -> {
                val alarm = intent.getStringExtra("payload")?.let { AlarmStore.decode(it) }
                if (alarm != null) startAlarm(alarm) else stopSelf()
                return START_STICKY
            }
            ACTION_FIRE -> {
                val id = intent.getStringExtra("id")
                val alarm = AlarmStore.loadAll(this).firstOrNull { it.id == id }
                if (alarm != null) startAlarm(alarm) else stopSelf()
                return START_STICKY
            }
            else -> {
                stopSelf()
                return START_NOT_STICKY
            }
        }
    }

    private fun startAlarm(a: StoredAlarm) {
        stopSound()
        val notif = Notifier.buildAlarm(this, a, a.fullAlarm)
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(
                NOTIF_ID, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } else {
            startForeground(NOTIF_ID, notif)
        }
        acquireWakeLock()
        playTone(a)
        startVibration()
        speak(a)
        handler.removeCallbacks(stopRunnable)
        handler.postDelayed(stopRunnable, TIMEOUT_MS)
    }

    private fun playTone(a: StoredAlarm) {
        val uri = if (a.toneUri.isNullOrEmpty()) {
            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        } else {
            Uri.parse(a.toneUri)
        }
        try {
            player = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                setDataSource(this@AlarmService, uri)
                isLooping = true
                setVolume(1f, 1f)
                prepare()
                start()
            }
        } catch (_: Exception) {
            try {
                player = MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .build(),
                    )
                    setDataSource(
                        this@AlarmService,
                        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE),
                    )
                    isLooping = true
                    prepare()
                    start()
                }
            } catch (_: Exception) {
                player = null
            }
        }
    }

    private fun startVibration() {
        try {
            vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                (getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                    .defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            val pattern = longArrayOf(0, 800, 600, 800, 600, 1200)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(pattern, 0)
            }
        } catch (_: Exception) {
            vibrator = null
        }
    }

    private fun speak(a: StoredAlarm) {
        val text = a.ttsText
        if (!a.ttsEnabled || text.isNullOrEmpty()) return
        try {
            var instance: TextToSpeech? = null
            instance = TextToSpeech(this) { status ->
                if (status == TextToSpeech.SUCCESS) {
                    try {
                        instance?.language = Locale("id", "ID")
                        instance?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "alarm")
                    } catch (_: Exception) {
                        // abaikan bila bahasa id-ID tidak tersedia
                    }
                }
            }
            tts = instance
        } catch (_: Exception) {
            tts = null
        }
    }

    private fun acquireWakeLock() {
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "ingatobat:alarm")
            wakeLock?.acquire(TIMEOUT_MS + 60_000)
        } catch (_: Exception) {
            wakeLock = null
        }
    }

    private fun stopSound() {
        try {
            player?.stop()
        } catch (_: Exception) {
        }
        try {
            player?.release()
        } catch (_: Exception) {
        }
        player = null
        try {
            vibrator?.cancel()
        } catch (_: Exception) {
        }
        try {
            tts?.stop()
        } catch (_: Exception) {
        }
        try {
            tts?.shutdown()
        } catch (_: Exception) {
        }
        tts = null
    }

    private fun stopEverything() {
        handler.removeCallbacks(stopRunnable)
        stopSound()
        try {
            wakeLock?.release()
        } catch (_: Exception) {
        }
        wakeLock = null
        Notifier.cancel(this, NOTIF_ID)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    override fun onDestroy() {
        handler.removeCallbacks(stopRunnable)
        stopSound()
        try {
            wakeLock?.release()
        } catch (_: Exception) {
        }
        super.onDestroy()
    }
}
