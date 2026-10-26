import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/scan_widgets.dart';

class ScanResultPage extends StatelessWidget {
  final XFile eyePhoto;
  final XFile palmPhoto;
  const ScanResultPage({
    super.key,
    required this.eyePhoto,
    required this.palmPhoto,
  });

  void _save(BuildContext context) {
    // TODO: simpan ke sqflite untuk profil aktif (ProfileStorage.getActive().id)
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).popUntil((r) => r.isFirst);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Simulasi disimpan ke riwayat (contoh)', style: scanStyle(size: 13, color: AppColors.white)),
      ),
    );
  }

  void _pdf(BuildContext context) {
    // TODO: generator PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unduh PDF menyusul', style: scanStyle(size: 13, color: AppColors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScanPageScaffold(
      showBack: false,
      children: [
        const ScanTitle(
          title: 'Satu langkah lebih peduli',
          subtitle: TextSpan(
            text: 'Tinjau kategori risiko dan langkah selanjutnya. '
                'Foto tersedia pada detail riwayat.',
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.pinkTint,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'HASIL SIMULASI',
                  style: scanStyle(
                    size: 10.5,
                    weight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Risiko ringan',
                textAlign: TextAlign.center,
                style: scanStyle(
                  size: 30,
                  weight: FontWeight.w700,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ringan',
                      style: scanStyle(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kategori ini contoh antarmuka, bukan penilaian '
                'kesehatan atau diagnosis.',
                textAlign: TextAlign.center,
                style: scanStyle(
                  size: 12.5,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Langkah selanjutnya',
          style: scanStyle(size: 17, weight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          'Lengkapi menu dengan sumber zat besi dan vitamin C. Ikuti '
          'anjuran TTD dari tenaga kesehatan. Periksakan keluhan meski '
          'kategori tampak normal.',
          style: scanStyle(
            size: 14,
            height: 1.7,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Hasil dan foto ini hanya contoh simulasi, bukan citra '
            'analisis medis. Foto ikut disimpan di riwayat pada perangkat '
            'ini agar contoh tampil lengkap.',
            style: scanStyle(
              size: 12,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ScanPrimaryButton(
          label: 'Simpan simulasi ke riwayat',
          icon: Icons.done_all_rounded,
          iconAfter: false,
          onPressed: () => _save(context),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => _pdf(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.inactive),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(
              Icons.description_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
            label: Text(
              'Unduh contoh PDF',
              style: scanStyle(size: 15, weight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'PDF memuat crop sesi ini jika ada. Simpan laporan dengan aman.',
            textAlign: TextAlign.center,
            style: scanStyle(
              size: 11,
              height: 1.5,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}