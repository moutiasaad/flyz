import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Flyz onboarding — dark navy, transparent 787 hero, French copy.
/// Plane + point-field background stay fixed; only the copy block pages horizontally.
class FlyzOnboarding extends StatefulWidget {
  const FlyzOnboarding({
    super.key,
    required this.onGetStarted,
    required this.onLogIn,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogIn;

  @override
  State<FlyzOnboarding> createState() => _FlyzOnboardingState();
}

class _FlyzOnboardingState extends State<FlyzOnboarding>
    with TickerProviderStateMixin {
  static const Color flyzBlue = Color(0xFF1346CC);
  static const Color flyzCyan = Color(0xFF3DA8FF);
  static const Color bg0 = Color(0xFF0D1936);
  static const Color bg1 = Color(0xFF070D1F);
  static const Color bg2 = Color(0xFF04060E);

  static const _pages = <_OnbPage>[
    _OnbPage(
      head: 'Le monde des vols au bout des doigts',
      accent: 'vols',
      sub:
          'Vos projets de voyage simplifiés. Commencez votre réservation dès maintenant.',
    ),
    _OnbPage(
      head: 'Envolez-vous vers la Méditerranée',
      accent: 'Méditerranée',
      sub:
          'Mer, désert et culture — trouvez votre prochain vol en quelques secondes.',
    ),
    _OnbPage(
      head: 'Voyagez plus loin avec flyz',
      accent: 'flyz',
      sub:
          'Tous vos voyages réunis dans une seule application, du départ à l’arrivée.',
    ),
  ];

  final _controller = PageController();
  int _index = 0;
  bool get _isLast => _index == _pages.length - 1;

  late AnimationController _logoController;
  late AnimationController _planeController;
  late AnimationController _bgController;
  late AnimationController _contentController;

  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _planeOpacity;
  late Animation<Offset> _planeSlide;
  late Animation<double> _bgOpacity;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    // Logo animation (0-600ms)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Background animation (200-900ms)
    _bgController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _bgOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeIn),
    );

    // Plane animation (400-1100ms)
    _planeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _planeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _planeController, curve: Curves.easeOut),
    );
    _planeSlide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _planeController, curve: Curves.easeOutCubic),
    );

    // Content animation (600-1300ms)
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    // Start animations in sequence
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _bgController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _planeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _contentController.forward();
    });
  }

  void _next() {
    if (_isLast) {
      widget.onGetStarted();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoController.dispose();
    _planeController.dispose();
    _bgController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg1,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0.76),
            radius: 1.25,
            colors: [bg0, bg1, bg2],
            stops: [0.0, 0.56, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // subtle point-field + dashed flight-path arcs
            Positioned.fill(
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: _bgOpacity,
                  child: const CustomPaint(painter: _BgDecoPainter()),
                ),
              ),
            ),

            // 787 hero — shifted left so nose/top is visible
            Positioned(
              top: 200,
              left: 0,
              right: -80,
              child: IgnorePointer(
                child: SlideTransition(
                  position: _planeSlide,
                  child: FadeTransition(
                    opacity: _planeOpacity,
                    child: Image.asset(
                      'assets/images/plane_787.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),

            // top scrim keeps logo crisp over the plane
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF060B1A).withValues(alpha: 0.66),
                        const Color(0xFF060B1A).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // content column
            SafeArea(
              child: Column(
                children: [
                  SlideTransition(
                    position: _logoSlide,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32, bottom: 2),
                        child: SvgPicture.asset('assets/images/logo.svg',
                            height: 28),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Column(
                        children: [
                          // paged copy block (lower half; plane occupies the top)
                          SizedBox(
                            height: 196,
                            child: PageView.builder(
                              controller: _controller,
                              itemCount: _pages.length,
                              onPageChanged: (i) => setState(() => _index = i),
                              itemBuilder: (_, i) =>
                                  _CopyBlock(page: _pages[i]),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // page dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(width: 28),
                              ...List.generate(_pages.length, (i) {
                                final on = i == _index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 6),
                                  width: on ? 22 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: on
                                        ? flyzCyan
                                        : Colors.white.withValues(alpha: 0.28),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                );
                              }),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // CTA + login link
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 54,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _next,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: flyzBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor:
                                          flyzBlue.withValues(alpha: 0.6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Commencer',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded,
                                            size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                GestureDetector(
                                  onTap: widget.onLogIn,
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Vous avez déjà un compte ? ',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.6),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Outfit',
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'Connexion',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbPage {
  const _OnbPage({required this.head, required this.accent, required this.sub});
  final String head, accent, sub;
}

/// Left-aligned headline (with cyan accent word) + subtitle.
class _CopyBlock extends StatelessWidget {
  const _CopyBlock({required this.page});
  final _OnbPage page;

  @override
  Widget build(BuildContext context) {
    final parts = page.head.split(page.accent);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                height: 1.12,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                fontFamily: 'Outfit',
              ),
              children: [
                TextSpan(text: parts.first),
                TextSpan(
                  text: page.accent,
                  style: const TextStyle(color: _FlyzOnboardingState.flyzCyan),
                ),
                if (parts.length > 1)
                  TextSpan(text: parts.sublist(1).join(page.accent)),
              ],
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: 250,
            child: Text(
              page.sub,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.66),
                fontSize: 13.5,
                height: 1.55,
                fontWeight: FontWeight.w500,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle point-field + dashed flight-path arcs with location pins.
class _BgDecoPainter extends CustomPainter {
  const _BgDecoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // point field (14px grid), faded toward edges/bottom
    const spacing = 14.0;
    final center = Offset(w * 0.5, h * 0.32);
    final maxD = math.sqrt(w * w + h * h) * 0.62;
    final dot = Paint()..color = const Color(0xFFCFE0FF);
    for (double y = 8; y < h; y += spacing) {
      for (double x = 8; x < w; x += spacing) {
        final d = (Offset(x, y) - center).distance;
        var a = (1 - (d / maxD)).clamp(0.0, 1.0);
        a *= (1 - (y / h) * 0.5).clamp(0.0, 1.0);
        if (a <= 0.02) continue;
        dot.color = const Color(0xFFCFE0FF).withValues(alpha: 0.13 * a);
        canvas.drawCircle(Offset(x, y), 1.0, dot);
      }
    }

    // dashed flight-path arcs (scaled to 300×650 design space)
    final sx = w / 300, sy = h / 650;
    Offset p(double px, double py) => Offset(px * sx, py * sy);

    void dashedPath(Path path, Color color) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = color;
      for (final metric in path.computeMetrics()) {
        double dist = 0;
        while (dist < metric.length) {
          final seg = metric.extractPath(dist, dist + 2);
          canvas.drawPath(seg, paint);
          dist += 8; // 2px on / 6px off
        }
      }
    }

    final arc1 = Path()
      ..moveTo(p(14, 250).dx, p(14, 250).dy)
      ..cubicTo(p(96, 196).dx, p(96, 196).dy, p(214, 214).dx, p(214, 214).dy,
          p(290, 158).dx, p(290, 158).dy);
    final arc2 = Path()
      ..moveTo(p(22, 556).dx, p(22, 556).dy)
      ..cubicTo(p(118, 486).dx, p(118, 486).dy, p(206, 540).dx, p(206, 540).dy,
          p(292, 470).dx, p(292, 470).dy);
    dashedPath(arc1, _cyanA(0.18));
    dashedPath(arc2, _cyanA(0.13));

    // location pins (ring + dot)
    const pins = [
      Offset(14, 250),
      Offset(290, 158),
      Offset(22, 556),
      Offset(292, 470),
      Offset(150, 205),
    ];
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _cyanA(0.32);
    final core = Paint()
      ..color = const Color(0xFF7DC4FF).withValues(alpha: 0.55);
    for (final pin in pins) {
      canvas.drawCircle(p(pin.dx, pin.dy), 4.4, ring);
      canvas.drawCircle(p(pin.dx, pin.dy), 1.7, core);
    }
  }

  static Color _cyanA(double a) => const Color(0xFF3DA8FF).withValues(alpha: a);

  @override
  bool shouldRepaint(_BgDecoPainter oldDelegate) => false;
}
