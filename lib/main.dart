import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'theme/app_theme.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'web_screen.dart';

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

  // Flips to true when splash ends — starts pre-warming all three WebViews
  // in the background while user reads the onboarding slides.
  bool _preWarm = false;

  void _advance(_Screen next) => setState(() {
        if (next != _Screen.splash) _preWarm = true;
        _screen = next;
      });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Pre-warmed WebViews ──────────────────────────────────────────
        // Kept alive with Offstage from the moment splash ends.
        // They load in the background while the user goes through onboarding,
        // so by the time a button is tapped the page is already ready.
        if (_preWarm) ...[
          Offstage(
            offstage: _screen != _Screen.home,
            child: FlyzWebScreen(
              key: const ValueKey('home'),
              initialUrl: 'https://m.flyz.app',
              detectAuth: false,
              onDone: () {},
            ),
          ),
          Offstage(
            offstage: _screen != _Screen.signIn,
            child: FlyzWebScreen(
              key: const ValueKey('signIn'),
              initialUrl: 'https://m.flyz.app/fr/signin',
              onDone: () => _advance(_Screen.home),
            ),
          ),
          Offstage(
            offstage: _screen != _Screen.signUp,
            child: FlyzWebScreen(
              key: const ValueKey('signUp'),
              initialUrl: 'https://m.flyz.app/fr/signup',
              onDone: () => _advance(_Screen.home),
            ),
          ),
        ],

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
      ],
    );
  }
}
