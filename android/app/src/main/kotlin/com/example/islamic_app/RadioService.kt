package com.zbooma.suhbah // ⚠️ CHANGE THIS to your package name

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
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem

class RadioService : Service() {

    private var player: ExoPlayer? = null
    private val CHANNEL_ID = "islamic_audio_channel"
    private val NOTIFICATION_ID = 1

    private var currentTitle = "Islamic App"
    private var currentDesc = "Audio Playing"

    override fun onCreate() {
        super.onCreate()
        if (player == null) {
            player = ExoPlayer.Builder(this).build()
        }
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action

        // 🟢 THIS BLOCK IS MISSING IN YOUR CODE. ADD IT!
        when (action) {
            "STOP" -> {
                player?.stop()
                stopForeground(true)
                stopSelf()
                return START_NOT_STICKY
            }
            "PAUSE" -> {
                player?.pause() // 🛑 This stops the audio
                updateNotification(isPaused = true)
                return START_STICKY
            }
            "RESUME" -> {
                player?.play() // ▶️ This resumes the audio
                updateNotification(isPaused = false)
                return START_STICKY
            }
        }
        // 🟢 END OF CRITICAL BLOCK

        // --- Handle Play New URL ---
        val url = intent?.getStringExtra("url")
        val title = intent?.getStringExtra("title")
        val desc = intent?.getStringExtra("desc")

        if (url != null) {
            if (title != null) currentTitle = title
            if (desc != null) currentDesc = desc

            playStream(url)
            
            // Start Foreground Service
            val notification = createNotification(currentTitle, currentDesc, isPaused = false)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        }

        return START_STICKY
    }

    private fun playStream(url: String) {
        player?.let {
            it.setMediaItem(MediaItem.fromUri(Uri.parse(url)))
            it.prepare()
            it.play()
        }
    }

    private fun updateNotification(isPaused: Boolean) {
        val notification = createNotification(currentTitle, currentDesc, isPaused)
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Audio Playback",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(title: String, desc: String, isPaused: Boolean): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE
        )

        // Stop Action
        val stopIntent = Intent(this, RadioService::class.java).apply { action = "STOP" }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent, PendingIntent.FLAG_IMMUTABLE
        )

        // Pause/Resume Action
        val toggleAction = if (isPaused) "RESUME" else "PAUSE"
        val toggleIntent = Intent(this, RadioService::class.java).apply { action = toggleAction }
        val togglePendingIntent = PendingIntent.getService(
            this, 1, toggleIntent, PendingIntent.FLAG_IMMUTABLE
        )

        val actionIcon = if (isPaused) android.R.drawable.ic_media_play else android.R.drawable.ic_media_pause
        val actionText = if (isPaused) "Play" else "Pause"

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(desc)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .addAction(actionIcon, actionText, togglePendingIntent)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Stop", stopPendingIntent)
            .setStyle(androidx.media.app.NotificationCompat.MediaStyle().setShowActionsInCompactView(0, 1))
            .setOngoing(!isPaused)
            .build()
    }

    override fun onDestroy() {
        player?.release()
        player = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}