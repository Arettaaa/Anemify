import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../scan/presentation/widgets/risk_badge.dart';
import '../../../scan/presentation/widgets/scan_widgets.dart';
import '../../domain/entities/history_entry.dart';

String sumberFoto(HistoryEntry e) => e.usesFusion
    ? 'Mata + telapak'
    : (e.eyeScore != null ? 'Mata saja' : 'Telapak saja');

class HistoryScanCard extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;

  const HistoryScanCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.inactive),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.pinkTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.monitor_heart_outlined,
                  color: AppColors.primarySoft, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatTglPendek(entry.createdAt),
                      style: scanStyle(size: 16, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    '${sumberFoto(entry)} · ${formatJam(entry.createdAt)}',
                    style: scanStyle(size: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            RiskBadge(category: entry.category),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}