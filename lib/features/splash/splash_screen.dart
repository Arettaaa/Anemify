import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/injection.dart';
import '../history/domain/usecases/history_usecases.dart';
import '../onboarding/presentation/pages/onboarding_page.dart';
import '../profile/domain/usecases/profile_usecases.dart';
import '../shell/presentation/pages/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _asset = 'assets/animations/splash_screen.json';
  static const _skipIntro = 0.05;

  late final AnimationController _controller;
  LottieComposition? _composition;
  bool _navigated = false;

  /// Hasil cek onboarding + pemanasan data, jalan paralel dengan animasi.
  late final Future<bool> _prepare = _warmUp();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _goNext();
      });
    _loadLottie();
    _prepare; // mulai sekarang, jangan tunggu animasi selesai
  }

  Future<void> _loadLottie() async {
    try {
      final c = await AssetLottie(_asset).load();
      if (!mounted) return;
      _controller.duration = c.duration;
      setState(() => _composition = c);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.value = _skipIntro;
        _controller.forward();
      });
    } catch (e) {
      debugPrint('Splash: gagal memuat Lottie: $e');
      Future.delayed(const Duration(milliseconds: 800), _goNext);
    }
  }

  /// Semua yang biasanya bikin halaman berikutnya "nyendat" dimuat di sini.
  Future<bool> _warmUp() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;

    final jobs = <Future<void>>[
      // font DM Sans (google_fonts unduh saat runtime)
      GoogleFonts.pendingFonts([
        GoogleFonts.dmSans(),
        GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      ]).then((_) {}),
    ];

    if (seen) {
      jobs.addAll([
        sl<GetActiveProfile>()().then((_) {}),
        sl<GetScanHistory>()().then((_) {}), // buka SQLite lebih awal
      ]);
    }

    if (mounted) {
      final imgs = seen
          ? ['assets/foods/bayam.png', 'assets/foods/telur.png']
          : [
              'assets/images/onboarding_mascot_1.png',
              'assets/images/onboarding_mascot_2.png',
              'assets/images/onboarding_mascot_3.png',
            ];
      for (final p in imgs) {
        jobs.add(precacheImage(AssetImage(p), context));
      }
    }

    try {
      await Future.wait(jobs).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Splash: warm-up dilewati: $e'); // offline/timeout tetap lanjut
    }
    return seen;
  }

  Future<void> _goNext() async {
    if (_navigated || !mounted) return;
    _navigated = true;

    final seen = await _prepare; // biasanya sudah selesai saat animasi habis
    if (!mounted) return;

    final Widget next = seen ? const MainShell() : const OnboardingPage();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, animation, __, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.12, 0),
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
      parent: ModalRoute.of(context)?.secondaryAnimation ??
          kAlwaysDismissedAnimation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(exit),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.12, 0),
        ).animate(exit),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand(
            child: composition == null
                ? null
                : RepaintBoundary(
                    child: Lottie(
                      composition: composition,
                      controller: _controller,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}