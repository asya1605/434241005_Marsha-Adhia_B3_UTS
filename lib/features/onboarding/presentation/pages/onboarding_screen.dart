import 'package:flutter/material.dart';

/// ONBOARDING SCREEN — 4 slide
/// Gradient disamakan dengan splash screen existing (#1A4FE0 -> #2B6FF0).
/// Tempatkan setelah SplashScreen, sebelum LoginScreen, hanya tampil
/// sekali (cek flag "onboarding_seen" di local storage/shared_preferences).
class OnboardingScreen extends StatefulWidget {
  final void Function(BuildContext context) onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.confirmation_number_outlined,
      title: 'Laporkan masalahmu',
      description: 'Buat tiket dalam hitungan detik, kapan saja kamu butuh bantuan',
    ),
    _OnboardingSlide(
      icon: Icons.notifications_active_outlined,
      title: 'Pantau status real-time',
      description: 'Dapatkan notifikasi setiap ada update pada tiketmu',
    ),
    _OnboardingSlide(
      icon: Icons.history,
      title: 'Lihat riwayat lengkap',
      description: 'Semua tiket dan perjalanannya tersimpan rapi di satu tempat',
    ),
    _OnboardingSlide(
      icon: Icons.support_agent,
      title: 'Tim kami siap bantu',
      description: 'Helpdesk akan merespon dan menyelesaikan masalahmu secepatnya',
    ),
  ];

  void _goToNextOrFinish() {
    if (_currentPage == _slides.length - 1) {
      widget.onFinish(context);
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.3, -1),
            end: Alignment(0.3, 1),
            colors: [Color(0xFF1A4FE0), Color(0xFF2B6FF0), Color(0xFF1A4FE0)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Lingkaran dekoratif, posisi disesuaikan per kebutuhan —
            // sengaja tidak ikut animasi page agar terasa "menyatu" dengan
            // splash screen sebelumnya.
            Positioned(
              top: -40,
              right: -30,
              child: _decorCircle(120),
            ),
            Positioned(
              bottom: 140,
              left: -40,
              child: _decorCircle(110),
            ),

            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _slides.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, index) => _SlideContent(slide: _slides[index]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            _slides.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 5),
                              width: i == _currentPage ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _currentPage ? Colors.white : Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _goToNextOrFinish,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              isLast ? 'Mulai' : 'Skip',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(isLast ? 1 : 0.75),
                                fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _decorCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.06),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _SlideContent extends StatelessWidget {
  final _OnboardingSlide slide;

  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(slide.icon, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.78), height: 1.5),
          ),
        ],
      ),
    );
  }
}
