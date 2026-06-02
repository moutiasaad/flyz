import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Flyz animated splash — "pro flight app" motion.
///
/// The paper-plane descends from the top along a curved route, banking as it
/// flies and leaving a glowing tapered contrail. It lands in the logo with a
/// soft bloom; then "flyz" wipes in, the tagline settles, and a slim progress
/// bar fills before the lockup lifts + fades to hand off into the app.
class FlyzSplashScreen extends StatefulWidget {
  const FlyzSplashScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<FlyzSplashScreen> createState() => _FlyzSplashScreenState();
}

class _FlyzSplashScreenState extends State<FlyzSplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color _blue = Color(0xFF1346CC);
  static const Color _blueDeep = Color(0xFF0E37A8);
  static const Color _blueGlow = Color(0xFF2E6BF0);

  static const double _planeW = 83, _wordW = 130, _rowH = 80;
  static const Cubic _easeOutQuint = Cubic(0.22, 1.0, 0.36, 1.0);

  late final AnimationController _c;
  late final Animation<double> _planeT, _bloom, _word, _tag,
      _progFade, _progFill, _exit;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3400));

    Animation<double> seg(double a, double b,
            {Curve curve = _easeOutQuint}) =>
        CurvedAnimation(parent: _c, curve: Interval(a, b, curve: curve));

    _planeT = seg(0.06, 0.48, curve: const Cubic(0.5, 0, 0.3, 1));
    _bloom = seg(0.48, 0.64, curve: Curves.easeOut);
    _word = seg(0.50, 0.72);
    _tag = seg(0.60, 0.80);
    _progFade = seg(0.50, 0.57);
    _progFill = seg(0.52, 0.92, curve: const Cubic(0.45, 0.05, 0.2, 1));
    _exit = seg(0.92, 1.0, curve: const Cubic(0.5, 0, 0.2, 1));

    _c.forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Offset _bezier(Offset p0, Offset c1, Offset c2, Offset p3, double t) {
    final u = 1 - t;
    return p0 * (u * u * u) +
        c1 * (3 * u * u * t) +
        c2 * (3 * u * t * t) +
        p3 * (t * t * t);
  }

  Offset _bezierTangent(Offset p0, Offset c1, Offset c2, Offset p3, double t) {
    final u = 1 - t;
    return (c1 - p0) * (3 * u * u) +
        (c2 - c1) * (6 * u * t) +
        (p3 - c2) * (3 * t * t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _blue,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final W = constraints.maxWidth, H = constraints.maxHeight;
          final cx = W / 2, cy = H / 2 - 14;
          final planeCenter = Offset(cx - 65, cy);
          final wordCenter = Offset(cx + 41.5, cy);

          final p0 = planeCenter + const Offset(63, -268);
          final c1 = planeCenter + const Offset(29, -132);
          final c2 = planeCenter + const Offset(-31, 2);
          final p3 = planeCenter;
          final finalTan = _bezierTangent(p0, c1, c2, p3, 1);
          final finalAng = math.atan2(finalTan.dy, finalTan.dx);

          return AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final e = _exit.value;
              final sceneOpacity = (1 - e).clamp(0.0, 1.0);
              final sceneDy = -8.0 * e;
              final sceneScale = 1 + 0.05 * e;

              final pt = _planeT.value;
              final planePos = _bezier(p0, c1, c2, p3, pt);
              final tan = _bezierTangent(p0, c1, c2, p3, pt);
              final ang = math.atan2(tan.dy, tan.dx);
              final planeRot =
                  ((ang - finalAng) * 0.32).clamp(-0.42, 0.42).toDouble();
              final planeScale = 0.62 + 0.38 * math.min(1.0, pt / 0.6);

              return Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.32),
                        radius: 1.2,
                        colors: [_blueGlow, _blue, _blueDeep],
                        stops: [0.0, 0.47, 1.0],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: sceneOpacity,
                    child: Transform.translate(
                      offset: Offset(0, sceneDy),
                      child: Transform.scale(
                        scale: sceneScale,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Contrail + landing bloom
                            CustomPaint(
                              painter: _FlightPainter(
                                p0: p0, c1: c1, c2: c2, p3: p3,
                                planeT: pt,
                                bloom: _bloom.value,
                                bezier: _bezier,
                              ),
                            ),

                            // Wordmark (wipe-in)
                            Positioned(
                              left: wordCenter.dx - _wordW / 2,
                              top: wordCenter.dy - _rowH / 2,
                              width: _wordW,
                              height: _rowH,
                              child: Opacity(
                                opacity: _word.value.clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset:
                                      Offset(-9 * (1 - _word.value), 0),
                                  child: ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      widthFactor:
                                          _word.value.clamp(0.0, 1.0),
                                      child: SvgPicture.asset(
                                        'assets/images/word.svg',
                                        width: _wordW,
                                        height: _rowH,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Flying plane (glow + banking)
                            Positioned(
                              left: planePos.dx - _planeW / 2,
                              top: planePos.dy - _rowH / 2,
                              width: _planeW,
                              height: _rowH,
                              child: Opacity(
                                opacity: (pt * 8).clamp(0.0, 1.0),
                                child: Transform.rotate(
                                  angle: planeRot,
                                  child: Transform.scale(
                                    scale: planeScale,
                                    child: SvgPicture.asset(
                                      'assets/images/plane.svg',
                                      width: _planeW,
                                      height: _rowH,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Tagline
                            Positioned(
                              left: 0,
                              right: 0,
                              top: cy + 62,
                              child: Opacity(
                                opacity: _tag.value * 0.92,
                                child: Transform.translate(
                                  offset:
                                      Offset(0, 9 * (1 - _tag.value)),
                                  child: const Text(
                                    'Travel to the Mediterranean',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Progress bar
                            Align(
                              alignment: const Alignment(0, 0.80),
                              child: Opacity(
                                opacity: _progFade.value,
                                child:
                                    _ProgressBar(value: _progFill.value),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Glowing tapered contrail that follows the plane + a landing bloom.
class _FlightPainter extends CustomPainter {
  const _FlightPainter({
    required this.p0,
    required this.c1,
    required this.c2,
    required this.p3,
    required this.planeT,
    required this.bloom,
    required this.bezier,
  });

  final Offset p0, c1, c2, p3;
  final double planeT, bloom;
  final Offset Function(Offset, Offset, Offset, Offset, double) bezier;

  static const int _segs = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final trailAlpha = (1 - bloom).clamp(0.0, 1.0);

    if (planeT > 0.01 && trailAlpha > 0.01) {
      final head = planeT;
      final tail = math.max(0.0, planeT - 0.28);
      for (int i = 0; i < _segs; i++) {
        final f0 = i / _segs, f1 = (i + 1) / _segs;
        final a = bezier(p0, c1, c2, p3, tail + (head - tail) * f0);
        final b = bezier(p0, c1, c2, p3, tail + (head - tail) * f1);
        final paint = Paint()
          ..color = const Color(0xFFBFE1FF)
              .withValues(alpha: math.pow(f1, 1.4) * 0.6 * trailAlpha)
          ..strokeWidth = 0.8 + f1 * 3.4
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
        canvas.drawLine(a, b, paint);
      }
    }

    // Landing bloom — radial flash + expanding ring
    if (bloom > 0.0 && bloom < 1.0) {
      const flashR = 46.0;
      final flash = Paint()
        ..shader = ui.Gradient.radial(p3, flashR, [
          Colors.white.withValues(alpha: 0.55 * (1 - bloom)),
          const Color(0xFF9FD0FF).withValues(alpha: 0.0),
        ], [
          0.0,
          1.0
        ]);
      canvas.drawCircle(p3, flashR, flash);

      final ringR = 10 + 18 * bloom;
      final ring = Paint()
        ..color = Colors.white.withValues(alpha: 0.85 * (1 - bloom))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(p3, ringR, ring);
    }
  }

  @override
  bool shouldRepaint(_FlightPainter o) =>
      o.planeT != planeT || o.bloom != bloom;
}

/// Slim rounded progress bar with a cyan-tipped fill + glow.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Stack(
          children: [
            const ColoredBox(color: Color(0x29FFFFFF)),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFF3DA8FF)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xB33DA8FF), blurRadius: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
