package com.example.unique_data

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.text.format.Formatter
import android.os.BatteryManager
import android.content.IntentFilter
import android.util.Log
import android.Manifest
import android.content.pm.PackageManager
import android.content.Intent

class ImeiHelper(private val context: Context, private val flutterEngine: FlutterEngine) {
    private val CHANNEL = "com.example.device/info"
    private val TAG = "ImeiHelper"

    @SuppressLint("HardwareIds", "MissingPermission")
    fun setupChannel() {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    try {
                        val data = mutableMapOf<String, String?>()

                        // Android ID
                        data["androidId"] = try {
                            Settings.Secure.getString(
                                context.contentResolver,
                                Settings.Secure.ANDROID_ID
                            ) ?: "null"
                        } catch (e: Exception) {
                            Log.e(TAG, "Error getting Android ID", e)
                            "Unavailable"
                        }

                        // Device info
                        data["model"] = Build.MODEL
                        data["manufacturer"] = Build.MANUFACTURER
                        data["brand"] = Build.BRAND
                        data["sdkVersion"] = Build.VERSION.SDK_INT.toString()

                        // Wifi info
                        try {
                            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                            val wifiInfo = wifiManager.connectionInfo
                            data["macAddress"] = wifiInfo.macAddress
                            data["ipAddress"] = Formatter.formatIpAddress(wifiInfo.ipAddress)
                            data["ssid"] = wifiInfo.ssid?.removeSurrounding("\"") ?: "Not connected"
                        } catch (e: Exception) {
                            Log.e(TAG, "Error getting WiFi info", e)
                            data["macAddress"] = "Unavailable"
                            data["ipAddress"] = "Unavailable"
                            data["ssid"] = "Unavailable"
                        }

                        result.success(data)
                    } catch (e: Exception) {
                        Log.e(TAG, "General error in getDeviceInfo", e)
                        result.error("ERROR", "Failed to get device info: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}