import 'package:flutter/material.dart';

import '../../domain/entities/guide_geometry.dart';

/// Overlay panduan kamera, digambar LANGSUNG dari GuideGeometry
/// (bentuk yang sama persis dengan area yang dipotong).
/// Boleh diubah warnanya, JANGAN diubah geometrinya.
/// Harus berukuran sama persis dengan preview kamera (pakai Stack di atas preview).
class GuideOverlay extends StatelessWidget {
  const GuideOverlay({super.key, required this.isEye});

  final bool isEye;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GuidePainter(isEye), size: Size.infinite);
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