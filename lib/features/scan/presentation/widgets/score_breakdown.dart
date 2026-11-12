import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'scan_widgets.dart';

/// Skor sebagai persen: 0,74 -> "74%".
String persen(double? v) => v == null ? '-' : '${(v * 100).round()}%';

/// Rincian skor risiko skrining dalam persen: skor akhir, lalu per foto
/// (mata dan telapak) bila ada. Dipakai di hasil skrining dan detail riwayat.
class ScoreBreakdown extends StatelessWidget {
  final double score;
  final double? palmScore;
  final double? eyeScore;
  final bool usesFusion;
  const ScoreBreakdown({
    super.key,
    required this.score,
    this.palmScore,
    this.eyeScore,
    this.usesFusion = false,
  });

  @override
  Widget build(BuildContext context) {
    final sumber = usesFusion
        ? 'gabungan mata + telapak'
        : eyeScore != null
            ? 'foto mata saja'
            : 'foto telapak saja';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Skor risiko skrining',
                  style: scanStyle(size: 12.5, color: AppColors.textSecondary),
                ),
              ),
              Text(
                persen(score),
                style: scanStyle(
                    size: 20, weight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dari $sumber',
              style: scanStyle(
                  size: 11, color: AppColors.textSecondary.withValues(alpha: 0.8)),
            ),
          ),
          if (eyeScore != null || palmScore != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.inactive),
            const SizedBox(height: 8),
            _Bar(label: 'Konjungtiva mata', value: eyeScore),
            const SizedBox(height: 6),
            _Bar(label: 'Telapak tangan', value: palmScore),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double? value;
  const _Bar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value;
    return Row(
      children: [
        SizedBox(
          width: 118,
          child: Text(label,
              style: scanStyle(size: 12, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: v ?? 0,
              minHeight: 6,
              backgroundColor: AppColors.inactive,
              valueColor: AlwaysStoppedAnimation(
                  v == null ? AppColors.inactive : AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(
            v == null ? 'tidak ada' : persen(v),
            textAlign: TextAlign.right,
            style: scanStyle(
                size: v == null ? 10 : 12.5,
                weight: FontWeight.w700,
                color: v == null ? AppColors.textSecondary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
