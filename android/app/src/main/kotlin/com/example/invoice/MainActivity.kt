package com.example.invoice

import android.bluetooth.BluetoothAdapter
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "invoice/bluetooth"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "requestEnableBluetooth" -> {

                    val adapter =
                        BluetoothAdapter.getDefaultAdapter()

                    if (adapter == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    if (adapter.isEnabled) {
                        result.success(true)
                        return@setMethodCallHandler
                    }

                    try {
                        val intent =
                            Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)

                        startActivityForResult(intent, 1001)

                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}