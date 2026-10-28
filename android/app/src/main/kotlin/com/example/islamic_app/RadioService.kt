package com.zbooma.suhbah

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.google.android.exoplayer2.C
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.audio.AudioAttributes

class RadioService : Service() {

    private var player: ExoPlayer? = null
    private val CHANNEL_ID = "islamic_audio_channel"
    private val NOTIFICATION_ID = 1

    private var currentTitle = "Islamic App"
    private var currentDesc = "Audio Playing"

    override fun onCreate() {
        super.onCreate()
        initPlayer()
        createNotificationChannel()
    }

    private fun initPlayer() {
        if (player == null) {
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(C.USAGE_MEDIA)
                .setContentType(C.AUDIO_CONTENT_TYPE_SPEECH)
                .build()

            player = ExoPlayer.Builder(this)
                .setAudioAttributes(audioAttributes, true)
                .setHandleAudioBecomingNoisy(true)
                .setWakeMode(C.WAKE_MODE_NETWORK)
                .build().apply {
                    addListener(object : Player.Listener {
                        override fun onPlaybackStateChanged(playbackState: Int) {
                            if (playbackState == Player.STATE_ENDED && (player?.mediaItemCount ?: 0) > 0) {
                                updateNotification(isPaused = true)
                                notifyFlutter("onStop")
                            }
                        }
                    })
                }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: return START_NOT_STICKY

        initPlayer()

        when (action) {
            "PLAY" -> {
                val url = intent.getStringExtra("url")
                val title = intent.getStringExtra("title")
                val desc = intent.getStringExtra("desc")

                if (title != null) currentTitle = title
                if (desc != null) currentDesc = desc

                // 1. Immediately call startForeground to satisfy Android 12+ requirements
                val notification = createNotification(currentTitle, currentDesc, isPaused = false)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
                } else {
                    startForeground(NOTIFICATION_ID, notification)
                }

                // 2. Play the audio stream
                if (url != null) {
                    playStream(url)
                }
                return START_STICKY
            }

            "PAUSE" -> {
                if (player != null && (player?.mediaItemCount ?: 0) > 0) {
                    player?.pause()
                    updateNotification(isPaused = true)
                }
                return START_STICKY
            }

            "RESUME" -> {
                if (player != null && (player?.mediaItemCount ?: 0) > 0) {
                    resumePlayer()
                    updateNotification(isPaused = false)
                }
                return START_STICKY
            }

            "STOP" -> {
                stopPlayback()
                return START_NOT_STICKY
            }

            // --- Notification Drawer Actions (User pressed button in notification drawer) ---
            "NOTIFICATION_PAUSE" -> {
                player?.pause()
                updateNotification(isPaused = true)
                notifyFlutter("onPause")
                return START_STICKY
            }

            "NOTIFICATION_RESUME" -> {
                resumePlayer()
                updateNotification(isPaused = false)
                notifyFlutter("onPlay")
                return START_STICKY
            }

            "NOTIFICATION_STOP" -> {
                stopPlayback()
                notifyFlutter("onStop")
                return START_NOT_STICKY
            }
        }

        return START_STICKY
    }

    private fun resumePlayer() {
        player?.let {
            if (it.playbackState == Player.STATE_IDLE) {
                it.prepare()
            }
            it.play()
        }
    }

    private fun stopPlayback() {
        try {
            player?.stop()
            player?.clearMediaItems()
        } catch (e: Exception) {
            e.printStackTrace()
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                @Suppress("DEPRECATION")
                stopForeground(true)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.cancel(NOTIFICATION_ID)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun playStream(url: String) {
        player?.let {
            it.stop()
            it.setMediaItem(MediaItem.fromUri(Uri.parse(url)))
            it.prepare()
            it.play()
        }
    }

    private fun updateNotification(isPaused: Boolean) {
        try {
            val notification = createNotification(currentTitle, currentDesc, isPaused)
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(NOTIFICATION_ID, notification)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun notifyFlutter(action: String) {
        try {
            Handler(Looper.getMainLooper()).post {
                when (action) {
                    "onPlay" -> MainActivity.methodChannel?.invokeMethod("onPlay", null)
                    "onPause" -> MainActivity.methodChannel?.invokeMethod("onPause", null)
                    "onStop" -> MainActivity.methodChannel?.invokeMethod("onStop", null)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "تشغيل الصوت",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "إشعارات تشغيل القرآن الكريم والراديو الإسلامي"
                setShowBadge(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(title: String, desc: String, isPaused: Boolean): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, flags
        )

        // Stop Action from Notification
        val stopIntent = Intent(this, RadioService::class.java).apply { action = "NOTIFICATION_STOP" }
        val stopPendingIntent = PendingIntent.getService(
            this, 2, stopIntent, flags
        )

        // Pause/Resume Action from Notification
        val toggleAction = if (isPaused) "NOTIFICATION_RESUME" else "NOTIFICATION_PAUSE"
        val toggleIntent = Intent(this, RadioService::class.java).apply { action = toggleAction }
        val togglePendingIntent = PendingIntent.getService(
            this, 1, toggleIntent, flags
        )

        val actionIcon = if (isPaused) android.R.drawable.ic_media_play else android.R.drawable.ic_media_pause
        val actionText = if (isPaused) "تشغيل" else "إيقاف مؤقت"

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(desc)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .addAction(actionIcon, actionText, togglePendingIntent)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "إيقاف", stopPendingIntent)
            .setStyle(androidx.media.app.NotificationCompat.MediaStyle().setShowActionsInCompactView(0, 1))
            .setOngoing(!isPaused)
            .build()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        stopPlayback()
        stopSelf()
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        stopPlayback()
        player?.release()
        player = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}