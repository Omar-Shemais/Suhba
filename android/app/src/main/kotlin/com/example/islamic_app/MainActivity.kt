package com.zbooma.suhbah // ⚠️ CHANGE THIS to your actual package name

import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.islamic_app/radio"

    companion object {
        var methodChannel: MethodChannel? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable edge-to-edge window layout across Android versions
        WindowCompat.setDecorFitsSystemWindows(window, false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
            window.isStatusBarContrastEnforced = false
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel = channel

        channel.setMethodCallHandler { call, result ->
            // Create the Intent that targets our RadioService
            val intent = Intent(this, RadioService::class.java)

            when (call.method) {
                "play" -> {
                    val url = call.argument<String>("url")
                    val title = call.argument<String>("title")
                    val desc = call.argument<String>("desc")

                    intent.action = "PLAY"
                    intent.putExtra("url", url)
                    intent.putExtra("title", title)
                    intent.putExtra("desc", desc)

                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }
                "stop" -> {
                    intent.action = "STOP"
                    startService(intent)
                    result.success(null)
                }
                "pause" -> {
                    intent.action = "PAUSE"
                    startService(intent)
                    result.success(null)
                }
                "resume" -> {
                    intent.action = "RESUME"
                    startService(intent)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        methodChannel = null
        super.onDestroy()
    }
}