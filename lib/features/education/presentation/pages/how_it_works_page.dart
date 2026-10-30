import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol Kembali
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Judul & Subjudul
              Text(
                'Cara Kerja & Akurasi',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2D42),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Teknologi yang transparan, untuk keputusan yang lebih bijak.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Hero Card Gelap
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2D42),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.shieldCheck,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Skrining awal, bukan diagnosis.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Prototipe ini belum memuat model TFLite atau segmentasi ML. Tidak ada angka akurasi klinis yang dapat diklaim.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // List Poin 1 - 5
              _buildStepCard(
                number: '1',
                title: 'Ambil dua foto',
                description:
                    'Gunakan panduan bulan sabit untuk konjungtiva dan frame tangan untuk telapak. Foto diproses di browser, tidak dikirim ke server.',
              ),
              _buildStepCard(
                number: '2',
                title: 'Periksa kualitas',
                description:
                    'Rata-rata luminansi mengecek terang/gelap. Variansi Laplacian membantu mengenali blur. Ambang heuristik di prototipe belum divalidasi untuk semua kamera, warna kulit, dan pencahayaan.',
              ),
              _buildStepCard(
                number: '3',
                title: 'Tinjau area panduan',
                description:
                    'Crop diambil dari pusat frame foto. Outline menunjukkan panduan posisi, bukan batas jaringan hasil segmentasi. Sistem belum dapat memastikan foto benar-benar mata atau telapak.',
              ),
              _buildStepCard(
                number: '4',
                title: 'Kategori & ketidakpastian',
                description:
                    'Kategori Normal, Ringan, Sedang, dan Berat adalah contoh skenario. Confidence demo di bawah 70% menghasilkan Tidak Yakin. Nilai dan ambang ini ilustratif, bukan keyakinan model terlatih.',
              ),
              _buildStepCard(
                number: '5',
                title: 'Validasi sebelum penggunaan medis',
                description:
                    'Implementasi nyata perlu dataset dengan label Hb laboratorium, uji pada data independen, sensitivitas, spesifisitas, serta evaluasi pada kelompok usia, warna kulit, kehamilan, dan kamera yang berbeda. Tidak ada metrik tersebut pada prototipe ini.',
              ),

              const SizedBox(height: 12),

              // Card Peringatan Merah Mudanya
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD6DC), width: 1),
                ),
                child: Text(
                  'Hasil normal tidak menyingkirkan anemia. Bila ada keluhan atau faktor risiko, konsultasikan kebutuhan tes darah. Crop yang disimpan lokal dengan persetujuan tetap merupakan data biometrik sensitif.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    height: 1.5,
                    color: const Color(0xFF9E2A2B),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  'Edukasi umum, bukan pengganti konsultasi medis.',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B2D42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
