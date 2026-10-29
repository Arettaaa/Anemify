import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../scan/domain/entities/risk_category.dart';
import '../../domain/entities/history_entry.dart';

/// Grafik garis kategori risiko dalam satu periode (bukan kadar Hb).
class RiskTrendChart extends StatelessWidget {
  final List<HistoryEntry> entries; // urut lama -> baru
  final DateTime start;
  final DateTime end;
  final bool monthly;

  const RiskTrendChart({
    super.key,
    required this.entries,
    required this.start,
    required this.end,
    required this.monthly,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(entries, start, end, monthly),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.entries, this.start, this.end, this.monthly);

  final List<HistoryEntry> entries;
  final DateTime start;
  final DateTime end;
  final bool monthly;

  static const _leftPad = 70.0;
  static const _rightPad = 8.0;
  static const _topPad = 10.0;
  static const _bottomPad = 24.0;

  static int _level(RiskCategory c) => switch (c) {
        RiskCategory.rendah => 0,
        RiskCategory.perluPerhatian => 1,
        RiskCategory.tinggi => 2,
      };

  TextPainter _text(String s, {double size = 10.5}) => TextPainter(
        text: TextSpan(
          text: s,
          style: GoogleFonts.dmSans(
              fontSize: size, color: AppColors.textSecondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final chartH = size.height - _topPad - _bottomPad;
    final chartW = size.width - _leftPad - _rightPad;
    double y(int level) => _topPad + (2 - level) / 2 * chartH;
    double x(DateTime t) {
      final total = end.difference(start).inMinutes;
      final f = total == 0 ? 0.0 : t.difference(start).inMinutes / total;
      return _leftPad + f.clamp(0.0, 1.0) * chartW;
    }

    // Garis bantu + label kategori
    final grid = Paint()
      ..color = AppColors.inactive
      ..strokeWidth = 1;
    const labels = ['Rendah', 'Perhatian', 'Tinggi'];
    for (var l = 0; l < 3; l++) {
      final yy = y(l);
      canvas.drawLine(Offset(_leftPad, yy), Offset(size.width - _rightPad, yy), grid);
      final tp = _text(labels[l]);
      tp.paint(canvas, Offset(0, yy - tp.height / 2));
    }

    // Label sumbu X: awal, tengah, akhir periode
    final last = end.subtract(const Duration(days: 1));
    final mid = start.add(Duration(days: end.difference(start).inDays ~/ 2));
    for (final d in [start, mid, last]) {
      final tp = _text('${d.day}', size: 10);
      final xx = x(DateTime(d.year, d.month, d.day, 12));
      tp.paint(canvas, Offset(xx - tp.width / 2, size.height - tp.height));
    }

    if (entries.isEmpty) return;

    final pts = [
      for (final e in entries) Offset(x(e.createdAt), y(_level(e.category))),
    ];

    if (pts.length > 1) {
      final line = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts.skip(1)) {
        line.lineTo(p.dx, p.dy);
      }
      final fill = Path.from(line)
        ..lineTo(pts.last.dx, y(0))
        ..lineTo(pts.first.dx, y(0))
        ..close();
      canvas.drawPath(fill, Paint()..color = AppColors.primary.withValues(alpha: 0.07));
      canvas.drawPath(
        line,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (final p in pts) {
      canvas.drawCircle(p, 5, Paint()..color = AppColors.white);
      canvas.drawCircle(p, 3.5, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.entries != entries || old.start != start || old.end != end;
}