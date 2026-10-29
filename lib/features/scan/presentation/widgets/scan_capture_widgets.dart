import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'scan_widgets.dart';

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

/// Kotak gelap: ilustrasi panduan, atau pratinjau foto kalau sudah diambil.
/// Area yang dianalisis mengikuti frame di halaman kamera, bukan ilustrasi ini.
class ScanFrameBox extends StatelessWidget {
  final Uint8List? photo;
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
                Image.memory(photo!, fit: BoxFit.cover)
              else
                CustomPaint(painter: painter),
              Positioned(
                top: 16,
                left: 4,
                child: _Pill(
                  icon: photo != null
                      ? Icons.check_circle_outline
                      : Icons.verified_user_outlined,
                  text: photo != null ? 'Foto sudah diambil' : 'Panduan posisi foto',
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
        color: Colors.black.withValues(alpha: 0.35),
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
                  size: 11.5, weight: FontWeight.w500, color: AppColors.white),
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
                size: 14, height: 1.6, color: AppColors.textSecondary),
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
        'Frame di kamera menunjukkan area yang dianalisis.\n'
        'Foto diproses di perangkat dan tidak disimpan.',
        textAlign: TextAlign.center,
        style: scanStyle(
          size: 11,
          height: 1.5,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}