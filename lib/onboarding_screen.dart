import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Flyz onboarding — 3 screens, deep Mediterranean blue, French copy.
/// Discover → Compare flights → Book, ending on Sign up / Log in.
class FlyzOnboarding extends StatefulWidget {
  const FlyzOnboarding({
    super.key,
    required this.onSignUp,
    required this.onLogIn,
    required this.onSkip,
  });

  final VoidCallback onSignUp;
  final VoidCallback onLogIn;
  final VoidCallback onSkip;

  @override
  State<FlyzOnboarding> createState() => _FlyzOnboardingState();
}

class _FlyzOnboardingState extends State<FlyzOnboarding> {
  static const Color _blue = Color(0xFF1346CC);
  static const Color _blueDeep = Color(0xFF0E37A8);
  static const Color _blueGlow = Color(0xFF2E6BF0);
  static const Color _cyan = Color(0xFF3DA8FF);
  static const Color _navy = Color(0xFF08245E);

  static const _pages = <_OnbPage>[
    _OnbPage(
      headline: 'Explorez la Méditerranée',
      sub: 'Mer, désert et culture : découvrez l’Algérie et ses plus belles destinations.',
      image: 'assets/images/onb_1.png',
      caption: 'Photo · destination méditerranéenne',
    ),
    _OnbPage(
      headline: 'Comparez tous les vols',
      sub: 'Le meilleur prix en quelques secondes — vols directs ou avec escale.',
      image: 'assets/images/onb_2.png',
      caption: 'Photo · recherche de vols',
    ),
    _OnbPage(
      headline: 'Réservez en un instant',
      sub: 'Paiement sécurisé et tous vos voyages au même endroit.',
      image: 'assets/images/onb_3.png',
      caption: 'Photo · carte d’embarquement',
    ),
  ];

  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  void _go(int i) {
    _controller.animateToPage(
      i.clamp(0, _pages.length - 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _blue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.84),
            radius: 1.3,
            colors: [_blueGlow, _blue, _blueDeep],
            stops: [0.0, 0.46, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset('assets/images/logo.svg', height: 22),
                    AnimatedOpacity(
                      opacity: _isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: _isLast ? null : widget.onSkip,
                        child: const Text(
                          'Passer',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Slides
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _SlideView(page: _pages[i]),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: _isLast ? _ctas() : _nav(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nav() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (i) {
            final on = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: on ? 24 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: on ? _cyan : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(99),
                boxShadow: on
                    ? [const BoxShadow(color: Color(0x993DA8FF), blurRadius: 12)]
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '0${_index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Outfit',
                  ),
                ),
                TextSpan(
                  text: '  —  0${_pages.length}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Outfit',
                  ),
                ),
              ]),
              style: const TextStyle(fontSize: 14, letterSpacing: 1),
            ),
            GestureDetector(
              onTap: () => _go(_index + 1),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: _cyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xCC3DA8FF),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: _navy, size: 26),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ctas() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Skip — subtle, sits above the main CTAs
        SizedBox(
          height: 56,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onSkip,
            icon: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.55),
            ),
            label: Text(
              'Continuer sans compte',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Outfit',
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.55),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: _cyan,
              foregroundColor: _navy,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Outfit',
              ),
            ),
            child: const Text('S’inscrire'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onLogIn,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Outfit',
              ),
            ),
            child: const Text('Se connecter'),
          ),
        ),
      ],
    );
  }
}

class _OnbPage {
  const _OnbPage({
    required this.headline,
    required this.sub,
    required this.image,
    required this.caption,
  });
  final String headline, sub, image, caption;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.page});
  final _OnbPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xB3040F3C),
                      blurRadius: 44,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Image.asset(
                  page.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(page.caption),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            page.headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            page.sub,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w400,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _placeholder(String caption) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined,
              color: Colors.white.withValues(alpha: 0.5), size: 34),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              caption,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
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
