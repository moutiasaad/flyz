import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _kLockdownJs = r"""
(function() {
  var meta = document.querySelector('meta[name="viewport"]');
  if (meta) {
    meta.setAttribute('content',
      'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
  } else {
    var m = document.createElement('meta');
    m.name = 'viewport';
    m.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
    document.head.appendChild(m);
  }
  var style = document.createElement('style');
  style.textContent = '* { -webkit-user-select: none !important; user-select: none !important; -webkit-touch-callout: none !important; }';
  document.head.appendChild(style);
  document.addEventListener('contextmenu', function(e) {
    e.preventDefault(); e.stopPropagation(); return false;
  }, true);
  document.addEventListener('touchstart', function(e) {
    if (e.touches.length > 1) { e.preventDefault(); }
  }, { passive: false, capture: true });
  document.addEventListener('touchmove', function(e) {
    if (e.touches.length > 1) { e.preventDefault(); }
  }, { passive: false, capture: true });
  var lastTap = 0;
  document.addEventListener('touchend', function(e) {
    var now = Date.now();
    if (now - lastTap < 300) { e.preventDefault(); }
    lastTap = now;
  }, { passive: false, capture: true });
})();
""";

class FlyzWebScreen extends StatefulWidget {
  const FlyzWebScreen({
    super.key,
    required this.initialUrl,
    required this.onDone,
    this.detectAuth = true,
  });

  final String initialUrl;
  final VoidCallback onDone;
  final bool detectAuth;

  @override
  State<FlyzWebScreen> createState() => _FlyzWebScreenState();
}

class _FlyzWebScreenState extends State<FlyzWebScreen> {
  late final WebViewController _controller;
  int _loadProgress = 0;
  bool _loadDone = false;
  bool _everLoaded = false;

  // Color shown in the status-bar slot — switches per URL so the slot
  // always matches the top of the page (white for most pages, blue for home).
  Color _statusBarBg = const Color(0xFF1346CC);
  Brightness _iconBrightness = Brightness.light;

  static const _blue = Color(0xFF1346CC);

  static const _homeUrls = <String>[
    'https://m.flyz.app',
    'https://m.flyz.app/',
    'https://m.flyz.app/fr',
    'https://m.flyz.app/fr/',
  ];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() {
            _loadProgress = p;
            if (p >= 100) _loadDone = true;
          }),
          onPageStarted: (url) => setState(() {
            _loadDone = false;
            _loadProgress = 0;
            _applyStatusBarStyle(url);
          }),
          onPageFinished: (url) {
            _controller.runJavaScript(_kLockdownJs);
            setState(() {
              _everLoaded = true;
              _applyStatusBarStyle(url);
            });
          },
          onNavigationRequest: (req) {
            if (widget.detectAuth) {
              final url = req.url;
              if (_isHomeUrl(url) && url != widget.initialUrl) {
                widget.onDone();
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _applyStatusBarStyle(String url) {
    final isHome = _homeUrls.any((h) =>
        url == h || url.startsWith('$h?') || url.startsWith('$h#'));
    // Home hero → blue slot + light (white) icons.
    // All other pages (results, booking, auth…) → white slot + dark icons.
    _statusBarBg = isHome ? _blue : Colors.white;
    _iconBrightness = isHome ? Brightness.light : Brightness.dark;
  }

  bool _isHomeUrl(String url) {
    for (final h in _homeUrls) {
      if (url == h || url.startsWith('$h?') || url.startsWith('$h#')) {
        return true;
      }
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final path = uri.path;
    return !path.contains('signin') &&
        !path.contains('signup') &&
        !path.contains('register') &&
        !path.contains('password') &&
        !path.contains('login');
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          widget.onDone();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              _everLoaded ? _iconBrightness : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          // This fills the status-bar slot and must match the page's top color.
          // Results / detail pages → white (matches their white header).
          // Home → blue (matches the hero).
          backgroundColor: _everLoaded ? _statusBarBg : _blue,
          body: Stack(
            children: [
              // WebView starts below the status bar so the site's own header
              // is never hidden behind the clock / battery icons.
              Positioned(
                top: topInset,
                left: 0,
                right: 0,
                bottom: 0,
                child: WebViewWidget(controller: _controller),
              ),

              // Thin progress bar for subsequent in-page navigations
              if (_everLoaded && !_loadDone)
                Positioned(
                  top: topInset,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: _loadProgress / 100,
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0080FF),
                    ),
                  ),
                ),

              // Full-screen blue cover — hides the blank WebView until first
              // paint. Fades out once onPageFinished fires.
              AnimatedOpacity(
                opacity: _everLoaded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 350),
                child: IgnorePointer(
                  ignoring: _everLoaded,
                  child: Container(
                    color: _blue,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/logo-white.png',
                      width: 160,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
