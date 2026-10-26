import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scan_intro_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/scan_widgets.dart';

const kScanHowtoSeenKey = 'scan_howto_seen';
class ScanHowItWorksPage extends StatelessWidget {
  final bool isGate;
  const ScanHowItWorksPage({super.key, this.isGate = false});

  static const _steps = [
    (
      '1. Ambil dua foto',
      'Gunakan panduan bulan sabit untuk konjungtiva dan frame tangan untuk '
          'telapak. Foto diproses di perangkat, tidak dikirim ke server.'
    ),
    (
      '2. Periksa kualitas',
      'Rata-rata luminansi mengecek terang/gelap. Variansi Laplacian membantu '
          'mengenali blur. Ambang heuristik di prototipe belum divalidasi untuk '
          'semua kamera, warna kulit, dan pencahayaan.'
    ),
    (
      '3. Tinjau area panduan',
      'Crop diambil dari pusat frame foto. Outline menunjukkan panduan posisi, '
          'bukan batas jaringan hasil segmentasi. Sistem belum dapat memastikan '
          'foto benar-benar mata atau telapak.'
    ),
    (
      '4. Kategori & ketidakpastian',
      'Kategori Normal, Ringan, Sedang, dan Berat adalah contoh skenario. '
          'Confidence demo di bawah 70% menghasilkan Tidak Yakin. Nilai dan '
          'ambang ini ilustratif, bukan keyakinan model terlatih.'
    ),
    (
      '5. Validasi sebelum penggunaan medis',
      'Implementasi nyata perlu dataset dengan label Hb laboratorium, uji pada '
          'data independen, sensitivitas, spesifisitas, serta evaluasi pada '
          'kelompok usia, warna kulit, kehamilan, dan kamera yang berbeda. '
          'Tidak ada metrik tersebut pada prototipe ini.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScanPageScaffold(
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
              const Icon(
                Icons.verified_user_outlined,
                color: AppColors.white,
                size: 26,
              ),
              const SizedBox(height: 14),
              Text(
                'Skrining awal, bukan diagnosis.',
                style: scanStyle(
                  size: 18,
                  weight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Prototipe ini belum memuat model TFLite atau segmentasi ML. '
                'Tidak ada angka akurasi klinis yang dapat diklaim.',
                style: scanStyle(
                  size: 12.5,
                  height: 1.7,
                  color: const Color(0xFFD5D8E0),
                ),
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
            'Hasil normal tidak menyingkirkan anemia. Bila ada keluhan atau '
            'faktor risiko, konsultasikan kebutuhan tes darah. Crop yang '
            'disimpan lokal dengan persetujuan tetap merupakan data biometrik '
            'sensitif.',
            style: scanStyle(
              size: 13,
              height: 1.7,
              color: AppColors.primary,
            ),
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
          Text(
            title,
            style: scanStyle(size: 15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: scanStyle(
              size: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}