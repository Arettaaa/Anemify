import 'package:flutter/material.dart';

class CrescentPainter extends CustomPainter {
  const CrescentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final left = Offset(w * 0.19, h * 0.40);
    final right = Offset(w * 0.81, h * 0.40);

    final path = Path()
      ..moveTo(left.dx, left.dy)
      ..cubicTo(w * 0.24, h * 0.72, w * 0.76, h * 0.72, right.dx, right.dy)
      ..quadraticBezierTo(w * 0.5, h * 0.52, left.dx, left.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HandPainter extends CustomPainter {
  const HandPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bw = w * 0.42;
    final bh = h * 0.72;
    final ox = (w - bw) / 2;
    final oy = h * 0.14;
    Offset p(double x, double y) => Offset(ox + x * bw, oy + y * bh);

    final path = Path();
    void mv(double x, double y) {
      final o = p(x, y);
      path.moveTo(o.dx, o.dy);
    }

    void ln(double x, double y) {
      final o = p(x, y);
      path.lineTo(o.dx, o.dy);
    }

    void qd(double cx, double cy, double x, double y) {
      final c = p(cx, cy);
      final o = p(x, y);
      path.quadraticBezierTo(c.dx, c.dy, o.dx, o.dy);
    }

    void cb(double x1, double y1, double x2, double y2, double x, double y) {
      final a = p(x1, y1);
      final b = p(x2, y2);
      final o = p(x, y);
      path.cubicTo(a.dx, a.dy, b.dx, b.dy, o.dx, o.dy);
    }

    // pergelangan kiri -> jempol
    mv(0.24, 1.0);
    ln(0.22, 0.80);
    cb(0.15, 0.72, 0.02, 0.60, 0.01, 0.46);
    qd(0.02, 0.38, 0.09, 0.42);
    cb(0.14, 0.46, 0.20, 0.54, 0.26, 0.58);
    // telunjuk
    ln(0.26, 0.24);
    qd(0.325, 0.08, 0.39, 0.24);
    ln(0.395, 0.36);
    // jari tengah
    ln(0.40, 0.12);
    qd(0.465, -0.04, 0.53, 0.12);
    ln(0.535, 0.34);
    // jari manis
    ln(0.54, 0.20);
    qd(0.60, 0.04, 0.66, 0.20);
    ln(0.665, 0.42);
    // kelingking
    ln(0.67, 0.30);
    qd(0.73, 0.14, 0.79, 0.30);
    ln(0.81, 0.62);
    ln(0.76, 1.0);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // garis telapak
    final lines = Path();
    void lm(double x, double y) {
      final o = p(x, y);
      lines.moveTo(o.dx, o.dy);
    }

    void lq(double cx, double cy, double x, double y) {
      final c = p(cx, cy);
      final o = p(x, y);
      lines.quadraticBezierTo(c.dx, c.dy, o.dx, o.dy);
    }

    lm(0.30, 0.60);
    lq(0.48, 0.54, 0.70, 0.60);
    lm(0.30, 0.68);
    lq(0.50, 0.62, 0.66, 0.74);
    lm(0.42, 0.60);
    lq(0.36, 0.78, 0.46, 0.90);

    canvas.drawPath(
      lines,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}