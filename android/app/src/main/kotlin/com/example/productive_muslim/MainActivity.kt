package com.example.productive_muslim

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "productive_muslim/timezone")
            .setMethodCallHandler { call, result ->
                if (call.method == "getLocalTimezone") {
                    result.success(TimeZone.getDefault().id)
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "productive_muslim/haptics")
            .setMethodCallHandler { call, result ->
                try {
                    val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                        vibratorManager?.defaultVibrator
                    } else {
                        @Suppress("DEPRECATION")
                        getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                    }

                    if (vibrator == null || !vibrator.hasVibrator()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    val duration = (call.argument<Int>("duration") ?: 30).toLong()
                    val amplitude = call.argument<Int>("amplitude") ?: VibrationEffect.DEFAULT_AMPLITUDE

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val effect = when (call.argument<String>("type")) {
                            "tick" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK)
                            } else {
                                VibrationEffect.createOneShot(20L, amplitude)
                            }
                            "click" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
                            } else {
                                VibrationEffect.createOneShot(35L, amplitude)
                            }
                            "heavy" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                VibrationEffect.createPredefined(VibrationEffect.EFFECT_HEAVY_CLICK)
                            } else {
                                VibrationEffect.createOneShot(75L, amplitude)
                            }
                            else -> VibrationEffect.createOneShot(duration, amplitude)
                        }
                        vibrator.vibrate(effect)
                    } else {
                        @Suppress("DEPRECATION")
                        vibrator.vibrate(duration)
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
    }
}
