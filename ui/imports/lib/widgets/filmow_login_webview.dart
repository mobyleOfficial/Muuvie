import 'package:common/common.dart';
import 'package:flutter/material.dart';
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
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _checkLoginStatus(),
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
        ),
      )
      ..loadRequest(Uri.parse('https://filmow.com/login/'));
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;
    setState(() => _loading = false);

    final url = await _controller.currentUrl();
    if (url == null) return;

    final isLoggedIn = !url.contains('/login');
    if (!isLoggedIn) return;

    final username = await _extractUsername();
    if (username == null || username.isEmpty) return;

    final cookies = await _controller.runJavaScriptReturningResult(
      'document.cookie',
    );

    if (mounted) {
      final cookieString = cookies.toString().replaceAll('"', '');
      Navigator.of(
        context,
      ).pop(FilmowLoginResult(username: username, cookies: cookieString));
    }
  }

  Future<String?> _extractUsername() async {
    final result = await _controller.runJavaScriptReturningResult('''
      (function() {
        var link = document.querySelector('a[href*="/usuario/"]');
        if (link) {
          var match = link.getAttribute('href').match(/\\/usuario\\/([^/]+)/);
          return match ? match[1] : '';
        }
        return '';
      })()
      ''');
    final username = result.toString().replaceAll('"', '');
    return username.isNotEmpty ? username : null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.editProfileFilmowLogin ?? ''),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) LinearProgressIndicator(color: colorScheme.primary),
        ],
      ),
    );
  }
}
