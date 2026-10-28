import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/risk_category.dart';
import 'scan_widgets.dart';

class RiskBadge extends StatelessWidget {
  final RiskCategory category;
  const RiskBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (category) {
      RiskCategory.rendah => ('Rendah', AppColors.successSoft, AppColors.success),
      RiskCategory.perluPerhatian =>
        ('Perhatian', AppColors.warningSoft, AppColors.warning),
      RiskCategory.tinggi => ('Tinggi', AppColors.primary, AppColors.white),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: scanStyle(size: 12, weight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}