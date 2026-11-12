import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/risk_category.dart';
import '../../domain/entities/scan_result.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/presentation/report/scan_report_pdf.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../widgets/scan_messages.dart';
import '../widgets/score_breakdown.dart';
import '../widgets/scan_widgets.dart';
import 'scan_flow.dart';

class ScanResultPage extends StatelessWidget {
  final ScanResult result;
  const ScanResultPage({super.key, required this.result});

  void _finish(BuildContext context) {
    context.read<ScanBloc>().add(const ScanReset());
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _rescan(BuildContext context) {
    context.read<ScanBloc>().add(const ScanReset());
    Navigator.of(context)
        .popUntil((r) => r.settings.name == kScanCaptureRoute || r.isFirst);
  }

  Future<void> _openFaskes() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${Uri.encodeComponent('puskesmas klinik laboratorium cek hb terdekat')}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) await launchUrl(uri);
  }

  List<String> _nextSteps(RiskCategory c) => switch (c) {
        RiskCategory.tinggi => const [
            'Periksakan diri ke puskesmas atau klinik untuk cek kadar Hb — '
                'sebaiknya dalam waktu dekat.',
            'Unduh laporan PDF di halaman ini dan tunjukkan ke petugas '
                'kesehatan saat periksa.',
            'Jangan memulai atau mengubah pengobatan sendiri berdasarkan '
                'hasil aplikasi.',
          ],
        RiskCategory.perluPerhatian => const [
            'Jadwalkan pemeriksaan kadar hemoglobin (Hb) di fasilitas '
                'kesehatan terdekat.',
            'Bawa laporan PDF dari halaman ini saat periksa.',
            'Lengkapi menu dengan sumber zat besi dan vitamin C; ikuti '
                'anjuran TTD dari tenaga kesehatan.',
          ],
        RiskCategory.rendah => const [
            'Pertahankan menu dengan sumber zat besi dan vitamin C.',
            'Ikuti anjuran TTD dari tenaga kesehatan.',
            'Tetap periksakan diri bila ada keluhan, meski kategori '
                'tampak rendah.',
          ],
      };

  ({String badge, Color bg, Color fg}) _style(RiskCategory c) => switch (c) {
        RiskCategory.rendah => (
            badge: 'Rendah',
            bg: AppColors.successSoft,
            fg: AppColors.success,
          ),
        RiskCategory.perluPerhatian => (
            badge: 'Perhatian',
            bg: AppColors.warningSoft,
            fg: AppColors.warning,
          ),
        RiskCategory.tinggi => (
            badge: 'Tinggi',
            bg: AppColors.primary,
            fg: AppColors.white,
          ),
      };

  Widget _mapsNote() => Text(
        'Membuka Google Maps; lokasi diatur oleh Maps. Foto dan hasil scan tidak dikirim.',
        style:
            scanStyle(size: 11, color: AppColors.textSecondary.withValues(alpha: 0.7)),
      );

  @override
  Widget build(BuildContext context) {
    final st = _style(result.category);
    final c = result.category;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(context);
      },
      child: ScanPageScaffold(
        showBack: false,
        children: [
          const ScanTitle(
            title: 'Satu langkah lebih peduli',
            subtitle: TextSpan(
              text: 'Tinjau kategori risiko dan langkah selanjutnya.',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.pinkTint,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'HASIL SKRINING',
                    style: scanStyle(
                      size: 10.5,
                      weight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  judulKategori(c),
                  textAlign: TextAlign.center,
                  style: scanStyle(
                      size: 30, weight: FontWeight.w700, letterSpacing: -0.7),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: st.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration:
                            BoxDecoration(color: st.fg, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        st.badge,
                        style: scanStyle(
                            size: 12, weight: FontWeight.w700, color: st.fg),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  pesanKategori(c),
                  textAlign: TextAlign.center,
                  style: scanStyle(
                      size: 13.5, height: 1.7, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                ScoreBreakdown(
                  score: result.score,
                  palmScore: result.palmScore,
                  eyeScore: result.eyeScore,
                  usesFusion: result.usesFusion,
                ),
              ],
            ),
          ),
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final w in result.warnings) ...[
              _WarningCard(text: pesanPeringatan(w)),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 18),
          _NextStepsCard(steps: _nextSteps(c)),
          if (c == RiskCategory.perluPerhatian) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _openFaskes,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.primarySoft),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.search_rounded,
                    size: 18, color: AppColors.primary),
                label: Text(
                  'Cari tempat cek Hb',
                  style: scanStyle(
                      size: 15,
                      weight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _mapsNote(),
          ],
          if (c == RiskCategory.tinggi) ...[
            const SizedBox(height: 20),
            ScanPrimaryButton(
              label: 'Cari Faskes Terdekat',
              icon: Icons.search_rounded,
              iconAfter: false,
              onPressed: _openFaskes,
            ),
            const SizedBox(height: 8),
            _mapsNote(),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pinkTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Sesak berat, nyeri dada, pingsan, atau perdarahan aktif? '
                'Segera cari pertolongan darurat. Jangan menunggu scan ulang.',
                style: scanStyle(
                    size: 13, height: 1.7, color: AppColors.primary),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              kScanDisclaimer,
              style: scanStyle(
                  size: 12, height: 1.7, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          ScanPrimaryButton(
            label: 'Selesai',
            icon: Icons.done_all_rounded,
            iconAfter: false,
            onPressed: () => _finish(context),
          ),
          const SizedBox(height: 12),
          ReportPdfButton(
            entry: HistoryEntry.fromScanResult(result),
            outlined: true,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _rescan(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.inactive),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.refresh_rounded,
                  size: 18, color: AppColors.textPrimary),
              label: Text('Skrining ulang',
                  style: scanStyle(size: 15, weight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Hasil tersimpan di riwayat. Foto tidak disimpan.',
              textAlign: TextAlign.center,
              style: scanStyle(
                size: 11,
                height: 1.5,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu "Apa yang harus saya lakukan?" — langkah bernomor, konkret.
class _NextStepsCard extends StatelessWidget {
  final List<String> steps;
  const _NextStepsCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pinkTint, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apa yang harus saya lakukan?',
            style: scanStyle(size: 16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.pinkTint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: scanStyle(
                        size: 12.5,
                        weight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      steps[i],
                      style: scanStyle(
                          size: 13.5,
                          height: 1.6,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String text;
  const _WarningCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: scanStyle(
                  size: 12.5, height: 1.6, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}