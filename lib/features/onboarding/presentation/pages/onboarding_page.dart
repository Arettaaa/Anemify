import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/pages/profile_setup_page.dart';
import '../models/onboarding_item.dart';
import '../widgets/onboarding_back_button.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_primary_button.dart';
import '../widgets/onboarding_skip_row.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  /// true = dibuka dari Pengaturan: hanya melihat, tanpa membuat profil.
  final bool viewOnly;
  const OnboardingPage({super.key, this.viewOnly = false});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _current = 0;
  bool _consent = false;

  static const _items = [
    OnboardingItem(
      eyebrow: 'Langkah kecil, dampak besar',
      title: 'Lebih peduli, lebih awal.',
      description:
          'Kenali risiko anemia dengan cara yang lebih nyaman. Mulai dari foto mata dan telapak tangan, tanpa jarum dan tanpa akun.',
      badge: 'Mudah. Nyaman. Aman.',
      imageAsset: 'assets/images/onboarding_mascot_1.png',
    ),
    OnboardingItem(
      eyebrow: 'Privasimu adalah prioritas',
      title: 'Datamu tetap di tanganmu.',
      description:
          'Seluruh data dan riwayat tersimpan dengan aman di dalam perangkat. Foto tidak akan diunggah ke server, dan penyimpanan potongan gambar sepenuhnya memerlukan persetujuan Anda.',
      badge: 'Tanpa login · Privasi Terjaga',
      imageAsset: 'assets/images/onboarding_mascot_2.png',
      footnote:
          'Ekspor berkala: data bisa hilang jika penyimpanan dihapus atau perangkat rusak.',
    ),
    OnboardingItem(
      eyebrow: 'Kenali batasannya',
      title: 'Skrining awal, bukan diagnosis.',
      description:
          'Anemify tidak dirancang untuk menggantikan tes medis di laboratorium. Hasil yang diberikan sekadar berfungsi sebagai indikasi tingkat risiko',
      badge: 'Keputusan sehat, bersama tenaga kesehatan',
      imageAsset: 'assets/images/onboarding_mascot_3.png',
      buttonLabel: 'Buat profil',
      consentText:
          'Saya memahami batasan skrining, penyimpanan lokal, dan bahwa hasil prototipe bukan diagnosis medis.',
    ),
  ];

  /// Mode lihat saja: tanpa centang persetujuan, tombol akhir "Selesai".
  late final List<OnboardingItem> _pages = widget.viewOnly
      ? [
          for (final i in _items)
            OnboardingItem(
              eyebrow: i.eyebrow,
              title: i.title,
              description: i.description,
              badge: i.badge,
              imageAsset: i.imageAsset,
              footnote: i.footnote,
              buttonLabel: identical(i, _items.last) ? 'Selesai' : i.buttonLabel,
            ),
        ]
      : _items;

  OnboardingItem get _item => _pages[_current];
  bool get _isFirst => _current == 0;
  bool get _isLast => _current == _pages.length - 1;
  bool get _canNext => !_item.requiresConsent || _consent;

  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Muat gambar maskot lebih dulu supaya geser slide tidak patah-patah.
    if (_precached) return;
    _precached = true;
    for (final item in _items) {
      precacheImage(AssetImage(item.imageAsset), context);
    }
  }

  void _go(int page) => _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );

  void _next() {
    if (_isLast && widget.viewOnly) {
      Navigator.of(context).pop();
    } else if (_isLast) {
      Navigator.of(context).push(_fadeRoute(const ProfileSetupPage()));
    } else {
      _go(_current + 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            children: [
              const OnboardingHeader(),
              const SizedBox(height: 20),
              OnboardingSkipRow(
                onSkip: () => _go(_pages.length - 1),
                counter: _isLast
                    ? '0${_current + 1} / 0${_pages.length}'
                    : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (_, i) => OnboardingSlide(
                    item: _pages[i],
                    index: i,
                    total: _pages.length,
                    consent: _consent,
                    onConsentChanged: (v) => setState(() => _consent = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Tombol kembali muncul/hilang dengan halus (tidak loncat)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _isFirst
                          ? const SizedBox(key: ValueKey('none'))
                          : Padding(
                              key: const ValueKey('back'),
                              padding: const EdgeInsets.only(right: 12),
                              child: OnboardingBackButton(
                                onPressed: () => _go(_current - 1),
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: OnboardingPrimaryButton(
                        key: ValueKey(_item.buttonLabel),
                        label: _item.buttonLabel,
                        onPressed: _canNext ? _next : null,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _item.footnote == null
                      ? const SizedBox(
                          key: ValueKey('no-note'),
                          width: double.infinity,
                        )
                      : Padding(
                          key: ValueKey(_item.footnote),
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _item.footnote!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Transisi halus (fade + geser sedikit) ke halaman berikutnya.
Route<T> _fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondary) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );