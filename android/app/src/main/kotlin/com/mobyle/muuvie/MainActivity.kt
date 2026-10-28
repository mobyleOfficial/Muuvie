package com.mobyle.muuvie

import android.webkit.CookieManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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

    private companion object {
        const val WEBVIEW_COOKIES_CHANNEL = "muuvie/webview_cookies"
    }
}
