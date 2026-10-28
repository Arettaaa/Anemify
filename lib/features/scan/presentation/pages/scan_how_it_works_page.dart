import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/scan_widgets.dart';
import 'scan_intro_page.dart';

const kScanHowtoSeenKey = 'scan_howto_seen';

class ScanHowItWorksPage extends StatelessWidget {
  final bool isGate;
  const ScanHowItWorksPage({super.key, this.isGate = false});

  static const _steps = [
    (
      '1. Ambil dua foto dengan panduan',
      'Kamera menampilkan sabit untuk konjungtiva dan kotak untuk telapak. '
          'Area di dalam panduan itulah yang dianalisis. Foto diproses di '
          'perangkat dan tidak dikirim ke server.'
    ),
    (
      '2. Cek kualitas & objek',
      'Foto yang terlalu gelap, terlalu terang, atau buram ditolak. Foto yang '
          'tidak dikenali sebagai konjungtiva atau telapak juga ditolak dan '
          'perlu diulang.'
    ),
    (
      '3. Analisis di perangkat',
      'Dua model TFLite menilai foto mata dan telapak, lalu hasilnya '
          'digabungkan menjadi satu skor risiko skrining.'
    ),
    (
      '4. Kategori risiko',
      'Hasil berupa Risiko rendah, Perlu perhatian, atau Risiko tinggi. '
          'Bila hasil mata dan telapak berbeda jauh, kamu akan diberi '
          'peringatan.'
    ),
    (
      '5. Batasan',
      'Model dilatih pada dataset terbatas dan belum divalidasi secara '
          'klinis. Kamera, pencahayaan, dan warna kulit dapat memengaruhi '
          'hasil.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScanPageScaffold(
      showBack: !isGate,
      children: [
        const ScanTitle(
          title: 'Cara Kerja & Akurasi',
          subtitle: TextSpan(
            text: 'Teknologi yang transparan, untuk keputusan yang lebih bijak.',
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined,
                  color: AppColors.white, size: 26),
              const SizedBox(height: 14),
              Text(
                'Skrining awal, bukan diagnosis.',
                style: scanStyle(
                    size: 18, weight: FontWeight.w700, color: AppColors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Analisis berjalan di perangkatmu. Hasil tidak menggantikan '
                'pemeriksaan hemoglobin oleh tenaga kesehatan.',
                style: scanStyle(
                    size: 12.5, height: 1.7, color: const Color(0xFFD5D8E0)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final s in _steps) ...[
          _StepCard(title: s.$1, body: s.$2),
          const SizedBox(height: 16),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.pinkTint,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            'Hasil risiko rendah tidak menyingkirkan anemia. Bila ada keluhan '
            'atau faktor risiko, konsultasikan kebutuhan tes darah. Foto tidak '
            'disimpan; riwayat hanya menyimpan kategori dan skor.',
            style: scanStyle(size: 13, height: 1.7, color: AppColors.primary),
          ),
        ),
        if (isGate) ...[
          const SizedBox(height: 24),
          ScanPrimaryButton(
            label: 'Saya mengerti, lanjut',
            onPressed: () async {
              final nav = Navigator.of(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(kScanHowtoSeenKey, true);
              nav.pushReplacement(
                MaterialPageRoute(builder: (_) => const ScanIntroPage()),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  final String body;
  const _StepCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inactive),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: scanStyle(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            body,
            style: scanStyle(
                size: 14, height: 1.6, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}