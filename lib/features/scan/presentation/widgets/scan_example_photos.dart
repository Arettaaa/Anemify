import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'dart:math' as math;
import 'scan_widgets.dart';

/// Kartu contoh foto benar vs salah, ditampilkan sebelum pengguna memotret.
/// Ilustrasi (bukan foto asli): tile "salah" memakai blur + gelap sungguhan
/// supaya perbedaannya langsung terlihat.
class ContohFotoCard extends StatelessWidget {
  const ContohFotoCard({super.key, required this.isEye});

  final bool isEye;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contoh foto',
                  style: scanStyle(size: 14.5, weight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Ilustrasi',
                  style: scanStyle(
                      size: 10, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ExampleTile(isEye: isEye, good: true),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ExampleTile(isEye: isEye, good: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.isEye, required this.good});

  final bool isEye;
  final bool good;

  @override
  Widget build(BuildContext context) {
    Widget illu = CustomPaint(
      painter: isEye ? const _EyeExamplePainter() : const _PalmExamplePainter(),
      size: Size.infinite,
    );
    if (!good) {
      illu = Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2.6, sigmaY: 2.6),
            child: illu,
          ),
          Container(color: Colors.black.withValues(alpha: 0.38)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(aspectRatio: 4 / 3, child: illu),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              good ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 15,
              color: good ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                good ? 'Terang & tajam' : 'Gelap atau buram',
                style: scanStyle(
                  size: 11.5,
                  height: 1.3,
                  weight: FontWeight.w600,
                  color: good ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Mata dengan kelopak bawah ditarik: konjungtiva merah muda terlihat.
class _EyeExamplePainter extends CustomPainter {
  const _EyeExamplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // kulit
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEFC5A6));
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.7, w, h * 0.3),
      Paint()..color = const Color(0xFFE8B897),
    );

    // mata (sklera)
    final eye = Path()
      ..moveTo(w * 0.18, h * 0.38)
      ..quadraticBezierTo(w * 0.5, h * 0.08, w * 0.82, h * 0.38)
      ..quadraticBezierTo(w * 0.5, h * 0.56, w * 0.18, h * 0.38)
      ..close();
    canvas.drawPath(eye, Paint()..color = Colors.white);

    // iris + pupil
    canvas.save();
    canvas.clipPath(eye);
    canvas.drawCircle(Offset(w * 0.5, h * 0.33), w * 0.115,
        Paint()..color = const Color(0xFF6B4A32));
    canvas.drawCircle(Offset(w * 0.5, h * 0.33), w * 0.05,
        Paint()..color = const Color(0xFF2A1A10));
    canvas.restore();

    // garis kelopak atas
    final lid = Path()
      ..moveTo(w * 0.18, h * 0.38)
      ..quadraticBezierTo(w * 0.5, h * 0.08, w * 0.82, h * 0.38);
    canvas.drawPath(
      lid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF9C6B4C),
    );

    // konjungtiva: sabit merah muda di bawah mata (kelopak bawah ditarik)
    final crescent = Path()
      ..moveTo(w * 0.22, h * 0.46)
      ..quadraticBezierTo(w * 0.5, h * 0.78, w * 0.78, h * 0.46)
      ..quadraticBezierTo(w * 0.5, h * 0.60, w * 0.22, h * 0.46)
      ..close();
    canvas.drawPath(crescent, Paint()..color = const Color(0xFFE98FA2));
    canvas.drawPath(
      crescent,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFC96B80),
    );

    // ujung jari menarik kelopak
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.95), width: w * 0.46, height: h * 0.42),
      Paint()..color = const Color(0xFFDFA783),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Close-up tengah telapak (tanpa jari), seperti foto dataset.
class _PalmExamplePainter extends CustomPainter {
  const _PalmExamplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3CDB0), Color(0xFFE9B995)],
        ).createShader(Offset.zero & size),
    );
    // sedikit variasi kulit supaya tidak terlihat polos
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.35, h * 0.4), width: w * 0.5, height: h * 0.45),
      Paint()..color = const Color(0xFFF7D8BE).withValues(alpha: 0.6),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.7, h * 0.7), width: w * 0.45, height: h * 0.4),
      Paint()..color = const Color(0xFFE2AD88).withValues(alpha: 0.45),
    );
    // kotak panduan memenuhi frame
    final side = math.min(w, h) * 0.78;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w / 2, h / 2), width: side, height: side),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
