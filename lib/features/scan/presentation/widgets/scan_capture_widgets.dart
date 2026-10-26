import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import 'scan_widgets.dart';

/// Sheet pilih kamera/galeri lalu ambil foto. Mengembalikan null kalau batal.
Future<XFile?> pickScanPhoto(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(
              'Ambil foto',
              style: scanStyle(size: 15, weight: FontWeight.w600),
            ),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(
              'Pilih dari galeri',
              style: scanStyle(size: 15, weight: FontWeight.w600),
            ),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null) return null;
  return ImagePicker().pickImage(source: source, imageQuality: 90);
}

/// Dua bar progres; [step] = jumlah bar yang merah (1 atau 2).
class ScanStepBars extends StatelessWidget {
  final int step;
  const ScanStepBars({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: 5,
              decoration: BoxDecoration(
                color: i < step ? AppColors.primary : AppColors.inactive,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Kotak gelap berisi foto (kalau ada) + garis panduan + caption.
class ScanFrameBox extends StatelessWidget {
  final XFile? photo;
  final CustomPainter painter;
  final String caption;
  const ScanFrameBox({
    super.key,
    required this.photo,
    required this.painter,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 345 / 315,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [Color(0xFF55556F), AppColors.textPrimary],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (photo != null)
                kIsWeb
                    ? Image.network(photo!.path, fit: BoxFit.cover)
                    : Image.file(File(photo!.path), fit: BoxFit.cover),
              CustomPaint(painter: painter),
              const Positioned(
                top: 16,
                left: 4,
                child: _Pill(
                  icon: Icons.verified_user_outlined,
                  text: 'Panduan posisi foto',
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(child: _Pill(text: caption)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData? icon;
  final String text;
  const _Pill({this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.white),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: scanStyle(
                size: 11.5,
                weight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu abu "Panduan foto ...".
class ScanGuideCard extends StatelessWidget {
  final String title;
  final String body;
  const ScanGuideCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: scanStyle(size: 15, weight: FontWeight.w700)),
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

class ScanCaptureFootnote extends StatelessWidget {
  const ScanCaptureFootnote({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Frame dan garis adalah panduan posisi, bukan segmentasi '
        'otomatis. Foto dummy hanya ditampilkan di riwayat.\n'
        'Analisis TFLite belum tersedia.',
        textAlign: TextAlign.center,
        style: scanStyle(
          size: 11,
          height: 1.5,
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
      ),
    );
  }
}