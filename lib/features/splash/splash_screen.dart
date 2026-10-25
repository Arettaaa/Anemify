import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../onboarding/presentation/pages/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _asset = 'assets/animations/splash_screen.json';

  late final AnimationController _controller;
  LottieComposition? _composition;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _goToOnboarding();
      });
    _load();
  }

  static const _skipIntro = 0.05;

  Future<void> _load() async {
    final sw = Stopwatch()..start();
    try {
      final composition = await AssetLottie(_asset).load();
      debugPrint('Splash: Lottie dimuat dalam ${sw.elapsedMilliseconds} ms');
      if (!mounted) return;
      _controller.duration = composition.duration;
      setState(() => _composition = composition);
      // Mulai putar SETELAH frame pertama tergambar.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.value = _skipIntro; // loncat ke frame yang sudah terlihat
        _controller.forward(); // kecepatan tetap, hanya sisa durasi
      });
    } catch (e, st) {
      debugPrint('Splash: gagal memuat Lottie: $e\n$st');
      Future.delayed(const Duration(seconds: 1), _goToOnboarding);
    }
  }

  void _goToOnboarding() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (_, __, ___) => const OnboardingPage(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(
                  0.25,
                  0,
                ), // masuk dari kanan, jaraknya pendek
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final composition = _composition;
    final exit = CurvedAnimation(
      parent:
          ModalRoute.of(context)?.secondaryAnimation ??
          kAlwaysDismissedAnimation,
      curve: Curves.easeInOut,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(exit),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.25, 0), // keluar ke kiri, jaraknya pendek
        ).animate(exit),
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: SizedBox.expand(
            child: composition == null
                ? null
                : Lottie(
                    composition: composition,
                    controller: _controller,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
    );
  }
}
