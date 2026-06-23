import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _kLockdownJs = r"""
(function() {
  var VP = 'width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
  function applyViewport() {
    var head = document.head || document.getElementsByTagName('head')[0];
    if (!head) return;
    var meta = document.querySelector('meta[name="viewport"]');
    if (meta) {
      if (meta.getAttribute('content') !== VP) meta.setAttribute('content', VP);
    } else {
      var m = document.createElement('meta');
      m.name = 'viewport';
      m.content = VP;
      head.appendChild(m);
    }
  }
  applyViewport();

  // React/Next.js may re-render the head and replace the viewport meta —
  // observe and re-apply so the no-zoom directive sticks.
  if (!window._flyzViewportObserver) {
    var headEl = document.head || document.getElementsByTagName('head')[0];
    if (headEl) {
      window._flyzViewportObserver = new MutationObserver(applyViewport);
      window._flyzViewportObserver.observe(headEl,
        { childList: true, subtree: true, attributes: true, attributeFilter: ['content'] });
    }
  }

  // touch-action: manipulation is the canonical way to disable
  // double-tap-to-zoom on iOS WKWebView (works in iOS 10+).
  if (!document.getElementById('_flyz_lockdown_css')) {
    var style = document.createElement('style');
    style.id = '_flyz_lockdown_css';
    style.textContent =
      'html, body { touch-action: manipulation !important; -ms-touch-action: manipulation !important; }' +
      '* { -webkit-user-select: none !important; user-select: none !important; -webkit-touch-callout: none !important; -webkit-tap-highlight-color: transparent !important; touch-action: manipulation !important; }' +
      'input, textarea, [contenteditable] { -webkit-user-select: text !important; user-select: text !important; }';
    (document.head || document.documentElement).appendChild(style);
  }

  if (window._flyzGesturesBound) return;
  window._flyzGesturesBound = true;

  document.addEventListener('contextmenu', function(e) {
    e.preventDefault(); e.stopPropagation(); return false;
  }, true);
  document.addEventListener('dblclick', function(e) {
    e.preventDefault(); e.stopPropagation(); return false;
  }, true);
  // iOS-specific pinch gesture events — block pinch-to-zoom outright.
  document.addEventListener('gesturestart', function(e) { e.preventDefault(); }, { passive: false, capture: true });
  document.addEventListener('gesturechange', function(e) { e.preventDefault(); }, { passive: false, capture: true });
  document.addEventListener('gestureend', function(e) { e.preventDefault(); }, { passive: false, capture: true });
  document.addEventListener('touchstart', function(e) {
    if (e.touches.length > 1) { e.preventDefault(); }
  }, { passive: false, capture: true });
  document.addEventListener('touchmove', function(e) {
    if (e.touches.length > 1) { e.preventDefault(); }
  }, { passive: false, capture: true });
  var lastTap = 0;
  document.addEventListener('touchend', function(e) {
    var now = Date.now();
    if (now - lastTap < 350) { e.preventDefault(); }
    lastTap = now;
  }, { passive: false, capture: true });
})();
""";

// Injected after page load — persistent MutationObserver that catches the
// Next.js "Application error" crash page on both initial loads AND
// client-side navigation errors (e.g. ChunkLoadError).
const _kErrorDetectJs = r"""
(function() {
  if (window._flyzErrObserver) return;

  function _check() {
    try {
      var t = document.body ? document.body.innerText : '';
      if (t.indexOf('Application error') !== -1 ||
          t.indexOf('client-side exception') !== -1) {
        FlyzBridge.postMessage('app_error');
        if (window._flyzErrObserver) {
          window._flyzErrObserver.disconnect();
          window._flyzErrObserver = null;
        }
      }
    } catch(e) {}
  }

  setTimeout(_check, 800);

  window._flyzErrObserver = new MutationObserver(function() {
    clearTimeout(window._flyzErrTimer);
    window._flyzErrTimer = setTimeout(_check, 400);
  });
  window._flyzErrObserver.observe(document.documentElement,
    { childList: true, subtree: true });
})();
""";

enum _ErrorKind { network, server, app }

class FlyzWebScreen extends StatefulWidget {
  const FlyzWebScreen({
    super.key,
    required this.initialUrl,
    required this.onDone,
    this.detectAuth = true,
    this.showLoadingCover = true,
  });

  final String initialUrl;
  final VoidCallback onDone;
  final bool detectAuth;
  final bool showLoadingCover;

  @override
  State<FlyzWebScreen> createState() => _FlyzWebScreenState();
}

class _FlyzWebScreenState extends State<FlyzWebScreen> {
  late final WebViewController _controller;
  int _loadProgress = 0;
  bool _loadDone = false;
  bool _everLoaded = false;
  _ErrorKind? _error;
  String? _navUrl; // tracks the current main-frame navigation URL

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
      ..enableZoom(false)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'FlyzBridge',
        onMessageReceived: (msg) {
          // Only trigger app-error overlay on home screen (not signIn/signUp)
          if (msg.message == 'app_error' && !widget.detectAuth && mounted) {
            setState(() => _error = _ErrorKind.app);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() {
            _loadProgress = p;
            if (p >= 100) _loadDone = true;
          }),
          onPageStarted: (url) {
            // Apply zoom lockdown as early as possible so iOS WKWebView
            // never sees a zoomable viewport, even during initial paint.
            _controller.runJavaScript(_kLockdownJs);
            setState(() {
              _navUrl = url;
              _error = null;
              _loadDone = false;
              _loadProgress = 0;
              _applyStatusBarStyle(url);
            });
          },
          onPageFinished: (url) {
            _controller.runJavaScript(_kLockdownJs);
            // Error crash detection only needed on home — not on auth pages
            if (!widget.detectAuth) {
              _controller.runJavaScript(_kErrorDetectJs);
            }
            setState(() {
              _everLoaded = true;
              _applyStatusBarStyle(url);
            });
          },
          onWebResourceError: (error) {
            // Only act on main-frame failures to avoid false positives from
            // sub-resource errors (ads, images, third-party scripts).
            // If the page already rendered once, cached content is visible —
            // keep showing it instead of replacing it with an error screen.
            if (error.isForMainFrame != false && !_everLoaded && mounted) {
              setState(() => _error = _ErrorKind.network);
            }
          },
          onHttpError: (error) {
            // Android fires onHttpError for ALL resources, not just main frame.
            // Only treat it as a page error if the failing URL matches the
            // current navigation URL set by onPageStarted.
            // If cached content is already visible, keep it instead of
            // showing an error overlay.
            final uri = error.request?.uri.toString() ?? '';
            if (uri != _navUrl) return;
            if (_everLoaded) return;
            final code = error.response?.statusCode ?? 0;
            if (code >= 400 && mounted) {
              setState(() => _error = _ErrorKind.server);
            }
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

  Future<void> _retry() async {
    final wasAppError = _error == _ErrorKind.app;
    setState(() {
      _error = null;
      _everLoaded = false;
      _loadProgress = 0;
      _loadDone = false;
    });
    // For app crashes (ChunkLoadError etc.) go back to the working previous
    // page instead of reloading the broken one.
    if (wasAppError && await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      _controller.reload();
    }
  }

  void _applyStatusBarStyle(String url) {
    final isHome = _homeUrls.any((h) =>
        url == h || url.startsWith('$h?') || url.startsWith('$h#'));
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
          backgroundColor: _everLoaded ? _statusBarBg : _blue,
          body: Stack(
            children: [
              Positioned(
                top: topInset,
                left: 0,
                right: 0,
                bottom: 0,
                child: WebViewWidget(controller: _controller),
              ),

              if (_everLoaded && !_loadDone && _error == null)
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

              if (widget.showLoadingCover)
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

              // Error overlay — sits above everything including the WebView
              if (_error != null)
                Positioned.fill(
                  child: _ErrorOverlay(
                    kind: _error!,
                    onRetry: _retry,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.kind, required this.onRetry});
  final _ErrorKind kind;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = switch (kind) {
      _ErrorKind.network => (
          Icons.wifi_off_rounded,
          'Pas de connexion',
          'Vérifiez votre connexion internet\net réessayez.',
        ),
      _ErrorKind.server => (
          Icons.cloud_off_rounded,
          'Service indisponible',
          'Le serveur a retourné une erreur.\nRéessayez dans quelques instants.',
        ),
      _ErrorKind.app => (
          Icons.refresh_rounded,
          'Une erreur est survenue',
          'L\'application a rencontré un problème\ninattendu. Réessayez.',
        ),
    };

    return Container(
      color: const Color(0xFF070D1F),
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo-white.png', width: 120),
          const SizedBox(height: 48),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1346CC).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF3DA8FF), size: 34),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w400,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Réessayer',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1346CC),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
