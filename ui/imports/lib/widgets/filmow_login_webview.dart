import 'dart:async';
import 'dart:convert';

import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FilmowLoginResult {
  final String username;
  final String cookies;

  const FilmowLoginResult({required this.username, required this.cookies});
}

class FilmowLoginWebview extends StatefulWidget {
  const FilmowLoginWebview({super.key});

  @override
  State<FilmowLoginWebview> createState() => _FilmowLoginWebviewState();
}

class _FilmowLoginWebviewState extends State<FilmowLoginWebview> {
  /// `onPageFinished` alone is not reliable: it may not fire after the login
  /// redirect, or fire before the header with the profile link is rendered.
  /// Polling keeps checking until the logged-in page is ready.
  static const _pollInterval = Duration(seconds: 1);
  static const _cookiesChannel = MethodChannel('muuvie/webview_cookies');
  static const _sessionCookies = {'filmow_sessionid', 'cf_clearance '};

  late final WebViewController _controller;
  Timer? _poll;
  bool _loading = true;
  bool _checking = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
            _checkLoginStatus();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://filmow.com/login/'));
    _poll = Timer.periodic(_pollInterval, (_) => _checkLoginStatus());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted || _checking || _completed) return;
    _checking = true;
    try {
      final url = await _controller.currentUrl();
      if (url == null || !_isPostLoginUrl(url)) return;

      final username = await _extractUsername();
      if (username == null) return;

      final cookies = await _readSessionCookies();

      if (!mounted || _completed) return;
      _completed = true;
      _poll?.cancel();
      Navigator.of(
        context,
      ).pop(FilmowLoginResult(username: username, cookies: cookies));
    } catch (_) {
      // The page is mid-navigation; the next tick retries.
    } finally {
      _checking = false;
    }
  }

  bool _isPostLoginUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.endsWith('filmow.com')) return false;
    return !uri.path.startsWith('/login') && !uri.path.startsWith('/cdn-cgi');
  }

  /// Reads the username from the profile link, looking in the site header
  /// first so links to other users (feed, comments) are not picked up.
  Future<String?> _extractUsername() async {
    final result = await _controller.runJavaScriptReturningResult('''
      (function() {
        if (document.querySelector('input[type="password"]')) return '';
        var scopes = ['header', 'nav', '#header', '.navbar', 'body'];
        for (var i = 0; i < scopes.length; i++) {
          var links = document.querySelectorAll(scopes[i] + ' a[href*="/usuario/"]');
          for (var j = 0; j < links.length; j++) {
            var match = links[j].pathname.match(/^\\/usuario\\/([^/]+)/);
            if (match) return match[1];
          }
        }
        return '';
      })()
      ''');
    final username = _asString(result);
    return username.isNotEmpty ? username : null;
  }

  /// Reads the Filmow login from the native cookie jar: the session cookie is
  /// HttpOnly, so `document.cookie` never sees it. Only the login cookies are
  /// sent; ad/analytics trackers and Cloudflare's clearance stay on the device.
  Future<String> _readSessionCookies() async {
    try {
      final header = await _cookiesChannel.invokeMethod<String>('getCookies', {
        'url': 'https://filmow.com/',
      });
      return (header ?? '')
          .split(';')
          .map((pair) => pair.trim())
          .where((pair) => _sessionCookies.contains(pair.split('=').first))
          .join('; ');
    } on MissingPluginException {
      return '';
    } on PlatformException {
      return '';
    }
  }

  /// Android returns JS strings JSON-encoded (`"abc"`); iOS returns them raw.
  String _asString(Object result) {
    final value = result.toString();
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      try {
        return jsonDecode(value) as String;
      } catch (_) {
        return value.substring(1, value.length - 1);
      }
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.editProfileFilmowLogin ?? ''),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: colorScheme.secondaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.importFilmowWaitMessage ?? '',
                    style: TextStyle(color: colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  LinearProgressIndicator(color: colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
