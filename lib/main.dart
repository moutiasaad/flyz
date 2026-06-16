import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'theme/app_theme.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'web_screen.dart';
import 'no_internet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FcmService.init(); // non-blocking — runs in background

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  runApp(const FlyzApp());
}

class FlyzApp extends StatelessWidget {
  const FlyzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flyz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

enum _Screen { splash, onboarding, signIn, signUp, home }

class _RootState extends State<_Root> {
  _Screen _screen = _Screen.splash;
  bool _preWarm = true; // start immediately so WebViews load during splash
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (mounted && online != _isOnline) setState(() => _isOnline = online);
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final online = results.any((r) => r != ConnectivityResult.none);
    if (mounted && !online) setState(() => _isOnline = false);
  }

  void _advance(_Screen next) => setState(() => _screen = next);

  // IndexedStack keeps all WebViews at full screen dimensions so Android's
  // native WebView can actually load content during pre-warming.
  int get _webViewIndex => switch (_screen) {
        _Screen.signIn => 1,
        _Screen.signUp => 2,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Pre-warmed WebViews ──────────────────────────────────────────
        if (_preWarm)
          IndexedStack(
            index: _webViewIndex,
            children: [
              FlyzWebScreen(
                key: const ValueKey('home'),
                initialUrl: 'https://m.flyz.app',
                detectAuth: false,
                onDone: () {},
              ),
              FlyzWebScreen(
                key: const ValueKey('signIn'),
                initialUrl: 'https://m.flyz.app/fr/signin',
                showLoadingCover: false,
                onDone: () => _advance(_Screen.home),
              ),
              FlyzWebScreen(
                key: const ValueKey('signUp'),
                initialUrl: 'https://m.flyz.app/fr/signup',
                showLoadingCover: false,
                onDone: () => _advance(_Screen.home),
              ),
            ],
          ),

        // ── Foreground screens ───────────────────────────────────────────
        if (_screen == _Screen.splash)
          FlyzSplashScreen(
            onDone: () => _advance(_Screen.onboarding),
          ),

        if (_screen == _Screen.onboarding)
          FlyzOnboarding(
            onGetStarted: () => _advance(_Screen.home),
            onLogIn: () => _advance(_Screen.signIn),
          ),

        // ── No internet overlay ──────────────────────────────────────────
        // Shown on all screens except splash (splash has no network dependency).
        if (!_isOnline && _screen != _Screen.splash)
          NoInternetScreen(
            onRetry: _checkConnectivity,
          ),
      ],
    );
  }
}
