import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../scan/presentation/widgets/scan_widgets.dart';
import '../../domain/entities/ttd_settings.dart';

class TtdCalendar extends StatelessWidget {
  final DateTime month;
  final TtdSettings settings;
  final Map<String, DateTime> logs;
  final ValueChanged<DateTime> onTapDay;

  const TtdCalendar({
    super.key,
    required this.month,
    required this.settings,
    required this.logs,
    required this.onTapDay,
  });

  static const _heads = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday - 1;
    final today = dayOnly(DateTime.now());

    return LayoutBuilder(builder: (context, c) {
      final cell = c.maxWidth / 7;
      final dot = (cell - 6).clamp(28.0, 44.0);
      return Column(
        children: [
          Row(
            children: [
              for (final h in _heads)
                SizedBox(
                  width: cell,
                  child: Text(h,
                      textAlign: TextAlign.center,
                      style:
                          scanStyle(size: 11, color: AppColors.textSecondary)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            children: [
              for (var i = 0; i < lead; i++)
                SizedBox(width: cell, height: dot + 6),
              for (var day = 1; day <= daysInMonth; day++)
                _cell(DateTime(month.year, month.month, day), today, cell, dot),
            ],
          ),
        ],
      );
    });
  }

  Widget _cell(DateTime d, DateTime today, double cell, double size) {
    final taken = logs.containsKey(dateKey(d));
    final future = d.isAfter(today);
    final scheduled = settings.isScheduled(d);
    final isToday = d == today;

    Color bg = Colors.transparent;
    Color fg = AppColors.textSecondary;
    Border? border;
    Widget child;

    if (taken) {
      bg = AppColors.primary;
      child = const Icon(Icons.check_rounded, size: 18, color: AppColors.white);
    } else {
      if (future) {
        fg = AppColors.textSecondary.withValues(alpha: 0.4);
      } else if (scheduled) {
        bg = AppColors.surface;
        fg = AppColors.textPrimary;
      } else {
        border = Border.all(color: AppColors.inactive);
      }
      child = Text('${d.day}',
          style: scanStyle(size: 12.5, weight: FontWeight.w600, color: fg));
    }
    if (isToday && !taken) {
      border = Border.all(color: AppColors.primary, width: 1.5);
    }

    return SizedBox(
      width: cell,
      height: size + 6,
      child: Center(
        child: GestureDetector(
          onTap: future ? null : () => onTapDay(d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: border,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}