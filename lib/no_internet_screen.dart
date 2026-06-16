import 'dart:math' as math;
import 'package:flutter/material.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _navy = Color(0xFF070D1F);
  static const _blue = Color(0xFF1346CC);
  static const _cyan = Color(0xFF3DA8FF);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: Stack(
        children: [
          // Dot-field background
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _DotFieldPainter()),
            ),
          ),

          // Top gradient scrim
          Positioned(
            top: 0, left: 0, right: 0, height: 180,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF060B1A).withValues(alpha: 0.7),
                      const Color(0xFF060B1A).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Logo
                  Image.asset('assets/images/logo-white.png', width: 110),

                  const Spacer(),

                  // Pulsing icon
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Three staggered pulse rings
                        for (int i = 0; i < 3; i++)
                          AnimatedBuilder(
                            animation: _ctrl,
                            builder: (_, __) {
                              var t = (_ctrl.value - i / 3) % 1.0;
                              if (t < 0) t += 1.0;
                              final eased = Curves.easeOut.transform(t);
                              final scale = 0.35 + eased * 1.3;
                              final opacity = (1.0 - eased) * 0.35;
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _cyan.withValues(alpha: opacity),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        // Icon core
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _blue.withValues(alpha: 0.18),
                            border: Border.all(
                              color: _cyan.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _cyan.withValues(alpha: 0.15),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            color: _cyan,
                            size: 34,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Connexion perdue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                      letterSpacing: -0.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Vérifiez votre Wi-Fi ou vos données\nmobiles, puis réessayez.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Outfit',
                    ),
                  ),

                  const Spacer(),

                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Réessayer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: _blue.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Auto-check indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 11,
                        height: 11,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vérification automatique en cours…',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 12,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle dot field matching the onboarding background.
class _DotFieldPainter extends CustomPainter {
  const _DotFieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const spacing = 16.0;
    final center = Offset(w * 0.5, h * 0.38);
    final maxD = math.sqrt(w * w + h * h) * 0.6;
    final dot = Paint();
    for (double y = 8; y < h; y += spacing) {
      for (double x = 8; x < w; x += spacing) {
        final d = (Offset(x, y) - center).distance;
        var a = (1 - d / maxD).clamp(0.0, 1.0);
        a *= (1 - (y / h) * 0.45).clamp(0.0, 1.0);
        if (a <= 0.02) continue;
        dot.color = const Color(0xFFCFE0FF).withValues(alpha: 0.12 * a);
        canvas.drawCircle(Offset(x, y), 1.0, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_DotFieldPainter _) => false;
}
