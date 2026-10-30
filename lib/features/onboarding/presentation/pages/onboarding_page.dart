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

  void _go(int page) => _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );

  void _next() {
    if (_isLast && widget.viewOnly) {
      Navigator.of(context).pop();
    } else if (_isLast) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
      );
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
                  if (!_isFirst) ...[
                    OnboardingBackButton(onPressed: () => _go(_current - 1)),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: OnboardingPrimaryButton(
                      label: _item.buttonLabel,
                      onPressed: _canNext ? _next : null,
                    ),
                  ),
                ],
              ),
              if (_item.footnote != null) ...[
                const SizedBox(height: 12),
                Text(
                  _item.footnote!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}