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
  const OnboardingPage({super.key});

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

  OnboardingItem get _item => _items[_current];
  bool get _isFirst => _current == 0;
  bool get _isLast => _current == _items.length - 1;
  bool get _canNext => !_item.requiresConsent || _consent;

  void _go(int page) => _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );

  void _next() {
    if (_isLast) {
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
                onSkip: () => _go(_items.length - 1),
                counter: _isLast
                    ? '0${_current + 1} / 0${_items.length}'
                    : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _items.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (_, i) => OnboardingSlide(
                    item: _items[i],
                    index: i,
                    total: _items.length,
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
                    color: AppColors.textSecondary.withOpacity(0.7),
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