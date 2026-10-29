package com.mobyle.muuvie

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import android.webkit.CookieManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The WebView cookie jar, including HttpOnly cookies that `document.cookie` cannot see.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WEBVIEW_COOKIES_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getCookies" -> {
                        val url = call.argument<String>("url")
                        if (url == null) {
                            result.error("missing_url", "url is required", null)
                        } else {
                            result.success(CookieManager.getInstance().getCookie(url).orEmpty())
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // Push notifications (fase 15) use the channel the backend names in each message.
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(SOCIAL_CHANNEL, "Social", NotificationManager.IMPORTANCE_HIGH)
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private companion object {
        const val SOCIAL_CHANNEL = "social"
        const val WEBVIEW_COOKIES_CHANNEL = "muuvie/webview_cookies"
    }
}
