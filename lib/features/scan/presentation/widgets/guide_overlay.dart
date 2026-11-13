import 'package:flutter/material.dart';

import '../../domain/entities/guide_geometry.dart';

/// Overlay panduan kamera, digambar LANGSUNG dari GuideGeometry
/// (bentuk yang sama persis dengan area yang dipotong).
/// Boleh diubah warnanya / diberi hiasan, JANGAN diubah geometrinya.
/// Harus berukuran sama persis dengan preview kamera (pakai Stack di atas preview).
class GuideOverlay extends StatelessWidget {
  const GuideOverlay({super.key, required this.isEye});

  final bool isEye;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
            return CustomPaint(painter: _GuidePainter(isEye), size: Size.infinite);
          }
          final r = isEye
              ? GuideGeometry.eyeRect(w.round(), h.round())
              : GuideGeometry.palmRect(w.round(), h.round());
          final hintTop = (r.top + r.height + 14).toDouble();
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _GuidePainter(isEye), size: Size.infinite),
              if (hintTop < h - 36)
                Positioned(
                  top: hintTop,
                  left: 12,
                  right: 12,
                  child: Center(
                    child: _HintChip(
                      icon: isEye
                          ? Icons.remove_red_eye_outlined
                          : Icons.back_hand_outlined,
                      text: isEye
                          ? 'Bagian merah muda kelopak bawah mengisi sabit'
                          : 'Tengah telapak memenuhi kotak',
                    ),
                  ),
                ),
            ],
          );
        },
      );
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  _GuidePainter(this.isEye);

  final bool isEye;

  Path _guide(Size size) {
    final w = size.width.round(), h = size.height.round();
    if (!isEye) {
      final r = GuideGeometry.palmRect(w, h);
      return Path()
        ..addRect(Rect.fromLTWH(
            r.left.toDouble(), r.top.toDouble(), r.width.toDouble(), r.height.toDouble()));
    }
    final r = GuideGeometry.eyeRect(w, h);
    final box =
        Rect.fromLTWH(r.left.toDouble(), r.top.toDouble(), r.width.toDouble(), r.height.toDouble());
    // Kurva Bezier kuadrat dengan titik kontrol di tengah = parabola yang sama persis
    // dengan eyeLowerV/eyeUpperV (puncak = setengah tinggi titik kontrol).
    final lowerCtrlY = box.top + 2 * 1.0 * box.height;
    final upperCtrlY = box.top + 2 * (1 - GuideGeometry.eyeThickness) * box.height;
    return Path()
      ..moveTo(box.left, box.top)
      ..quadraticBezierTo(box.center.dx, lowerCtrlY, box.right, box.top)
      ..quadraticBezierTo(box.center.dx, upperCtrlY, box.left, box.top)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final guide = _guide(size);
    final dim = Path.combine(
        PathOperation.difference, Path()..addRect(Offset.zero & size), guide);
    canvas.drawPath(dim, Paint()..color = Colors.black54);

    canvas.drawPath(
      guide,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_GuidePainter old) => old.isEye != isEye;
}
