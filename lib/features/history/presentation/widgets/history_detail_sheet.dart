import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/blur_sheet.dart';
import '../../../scan/presentation/widgets/risk_badge.dart';
import '../../../scan/presentation/widgets/scan_messages.dart';
import '../../../scan/presentation/widgets/scan_widgets.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/history_usecases.dart';
import '../history_revision.dart';
import 'history_scan_card.dart';

Future<void> showHistoryDetail(BuildContext context, HistoryEntry e) =>
    showBlurSheet(context, child: HistoryDetailSheet(entry: e));

class HistoryDetailSheet extends StatelessWidget {
  final HistoryEntry entry;
  const HistoryDetailSheet({super.key, required this.entry});

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus hasil ini?',
            style: scanStyle(size: 17, weight: FontWeight.w700)),
        content: Text('Hasil skrining ini akan dihapus dari perangkat.',
            style: scanStyle(size: 13.5, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: scanStyle(size: 14, weight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: scanStyle(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (ok != true || entry.id == null) return;
    await sl<DeleteHistoryEntry>()(entry.id!);
    notifyHistoryChanged();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = entry.category;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetHeader(title: 'Detail hasil skrining'),
        const SizedBox(height: 8),
        Text(
          '${formatTglPanjang(entry.createdAt)} · ${formatJam(entry.createdAt)} · ${sumberFoto(entry)}',
          style: scanStyle(size: 12.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            color: AppColors.pinkTint,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(judulKategori(c),
                  textAlign: TextAlign.center,
                  style: scanStyle(
                      size: 26, weight: FontWeight.w700, letterSpacing: -0.6)),
              const SizedBox(height: 10),
              RiskBadge(category: c),
              const SizedBox(height: 12),
              Text(pesanKategori(c),
                  textAlign: TextAlign.center,
                  style: scanStyle(
                      size: 13, height: 1.6, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Text('Skor risiko skrining: ${(entry.score * 100).round()}/100',
                  style: scanStyle(
                      size: 11.5,
                      color: AppColors.textSecondary.withOpacity(0.8))),
            ],
          ),
        ),
        for (final w in entry.warnings) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(pesanPeringatan(w),
                style: scanStyle(size: 12, height: 1.5)),
          ),
        ],
        const SizedBox(height: 18),
        Text('Langkah selanjutnya',
            style: scanStyle(size: 16, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(saranLanjutan(c),
            style: scanStyle(
                size: 13.5, height: 1.7, color: AppColors.textSecondary)),
        const SizedBox(height: 14),
        Text(kScanDisclaimer,
            style: scanStyle(
                size: 11,
                height: 1.5,
                color: AppColors.textSecondary.withOpacity(0.8))),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _delete(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primarySoft),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: AppColors.primary),
            label: Text('Hapus dari riwayat',
                style: scanStyle(
                    size: 14.5,
                    weight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}