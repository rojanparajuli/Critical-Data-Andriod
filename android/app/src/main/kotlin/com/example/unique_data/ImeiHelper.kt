package com.example.unique_data

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class ImeiHelper(private val activity: FlutterActivity) {
    private val CHANNEL = "com.example.imei/imei"

    fun setupChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getImei") {
                    try {
                        val identifier: String = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                            val telephonyManager =
                                activity.getSystemService(FlutterActivity.TELEPHONY_SERVICE) as TelephonyManager
                            if (ActivityCompat.checkSelfPermission(
                                    activity,
                                    Manifest.permission.READ_PHONE_STATE
                                ) != PackageManager.PERMISSION_GRANTED
                            ) {
                                result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission not granted", null)
                                return@setMethodCallHandler
                            }

                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                telephonyManager.imei
                            } else {
                                telephonyManager.deviceId
                            }
                        } else {
                            // Android 10+ fallback
                            Settings.Secure.getString(
                                activity.contentResolver,
                                Settings.Secure.ANDROID_ID
                            )
                        }

                        if (identifier != null) {
                            result.success(identifier)
                        } else {
                            result.error("NULL_ID", "Identifier is null", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get identifier: ${e.message}", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
