import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../scan/presentation/widgets/scan_widgets.dart';
import '../../domain/entities/ttd_settings.dart';
import '../../domain/usecases/ttd_usecases.dart';
import '../../../profile/presentation/profile_revision.dart';
import '../pages/ttd_reminder_page.dart';
import '../ttd_revision.dart';
import 'ttd_calendar.dart';

const _kLogPreview = 10;

class TtdTab extends StatefulWidget {
  const TtdTab({super.key});

  @override
  State<TtdTab> createState() => _TtdTabState();
}

class _TtdTabState extends State<TtdTab> {
  TtdSettings? _settings;
  Map<String, DateTime> _logs = {};
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  
  @override
  void initState() {
    super.initState();
    ttdRevision.addListener(_load);
    profileRevision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    ttdRevision.removeListener(_load);
    profileRevision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final s = await sl<GetTtdSettings>()();
    final l = await sl<GetTtdLogs>()();
    if (!mounted) return;
    setState(() {
      _settings = s;
      _logs = l;
    });
  }

  void _openSettings() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const TtdReminderPage()));

  Future<void> _toggle(DateTime d) async {
    await sl<SetTtdTaken>()(d, !_logs.containsKey(dateKey(d)));
    notifyTtdChanged();
  }

  bool get _canNext {
    final now = DateTime.now();
    return DateTime(
      _month.year,
      _month.month + 1,
    ).isBefore(DateTime(now.year, now.month + 1));
  }

  bool get _canPrev {
    var first = _settings?.startDate ?? DateTime.now();
    for (final d in _logs.values) {
      if (d.isBefore(first)) first = d;
    }
    return DateTime(_month.year, _month.month)
        .isAfter(DateTime(first.year, first.month));
  }

  bool _showAllLogs = false;

  void _setMonth(DateTime m) => setState(() {
    _month = m;
    _showAllLogs = false;
  });

  @override
  Widget build(BuildContext context) {
    final s = _settings;
    if (s == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [if (!s.enabled) _notSetCard() else ..._content(s)],
    );
  }

  Widget _notSetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pinkTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.medication_outlined,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            'Jadwal TTD belum diatur',
            style: scanStyle(size: 15, weight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Atur frekuensi sesuai anjuran tenaga kesehatan untuk mulai mencatat konsumsi.',
            textAlign: TextAlign.center,
            style: scanStyle(
              size: 12.5,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ScanPrimaryButton(label: 'Atur jadwal', onPressed: _openSettings),
        ],
      ),
    );
  }

  List<Widget> _content(TtdSettings s) {
    final stats = sl<CalculateTtdStats>()(s, _logs, _month);
    final unit = s.frequency == TtdFrequency.harian ? 'hari' : 'kali';
    final monthLogs =
        _logs.entries
            .where(
              (e) =>
                  e.value.year == _month.year && e.value.month == _month.month,
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return [
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah yang konsisten',
                      style: scanStyle(
                        size: 11,
                        color: AppColors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${stats.streak}',
                          style: scanStyle(
                            size: 30,
                            weight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            unit,
                            style: scanStyle(size: 13, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'berturut-turut hingga hari ini / kemarin',
                      style: scanStyle(
                        size: 10.5,
                        height: 1.4,
                        color: AppColors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pinkTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kepatuhan bulan terpilih',
                      style: scanStyle(
                        size: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          stats.percent?.toString() ?? '–',
                          style: scanStyle(
                            size: 30,
                            weight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            '%',
                            style: scanStyle(
                              size: 14,
                              weight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats.taken} dari ${stats.scheduled} $unit terjadwal',
                      style: scanStyle(
                        size: 10.5,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.inactive),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _circleBtn(
                  Icons.arrow_back_rounded,
                  _canPrev
                      ? () => _setMonth(DateTime(_month.year, _month.month - 1))
                      : null,
                ),
                Expanded(
                  child: Text(
                    formatBulanTahun(_month),
                    textAlign: TextAlign.center,
                    style: scanStyle(size: 15, weight: FontWeight.w700),
                  ),
                ),
                _circleBtn(
                  Icons.arrow_forward_rounded,
                  _canNext
                      ? () => _setMonth(DateTime(_month.year, _month.month + 1))
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Checklist konsumsi',
                    style: scanStyle(size: 13, weight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s.frequencyLabel,
                    style: scanStyle(
                      size: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TtdCalendar(
              month: _month,
              settings: s,
              logs: _logs,
              onTapDay: _toggle,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _legend(AppColors.primary, null, 'Sudah diminum'),
                _legend(AppColors.surface, null, 'Terjadwal'),
                _legend(
                  Colors.transparent,
                  AppColors.inactive,
                  'Di luar jadwal',
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tap tanggal untuk mencatat atau memperbaiki log. Persentase = hari '
                'terjadwal yang tercatat ÷ hari terjadwal yang sudah lewat, termasuk '
                'hari ini. Hari mendatang tidak dihitung. Jadwal bukan resep; ikuti '
                'tenaga kesehatan.',
                style: scanStyle(
                  size: 12,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: Text(
              'Log konsumsi TTD',
              style: scanStyle(size: 17, weight: FontWeight.w700),
            ),
          ),
          GestureDetector(
            onTap: _openSettings,
            child: Row(
              children: [
                Text(
                  'Atur jadwal',
                  style: scanStyle(
                    size: 12.5,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
           if (monthLogs.isEmpty)
        Text('Belum ada catatan di bulan ini.',
            style: scanStyle(size: 12.5, color: AppColors.textSecondary))
      else ...[
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final e in _showAllLogs
                  ? monthLogs
                  : monthLogs.take(_kLogPreview)) ...[
                _logCard(e.value),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        if (monthLogs.length > _kLogPreview) _showMoreButton(monthLogs.length),
      ],
    ];
  }

    Widget _showMoreButton(int total) {
    return GestureDetector(
      onTap: () => setState(() => _showAllLogs = !_showAllLogs),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _showAllLogs
                  ? 'Tampilkan lebih sedikit'
                  : 'Lihat semua ($total catatan)',
              style: scanStyle(size: 13, weight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            AnimatedRotation(
              turns: _showAllLogs ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logCard(DateTime at) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inactive),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.pinkTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.done_all_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTglPendek(at),
                  style: scanStyle(size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dicatat ${formatTglPendek(at)} · ${formatJam(at)}',
                  style: scanStyle(size: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pinkTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Diminum',
              style: scanStyle(
                size: 11.5,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color fill, Color? border, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  border ??
                  (fill == AppColors.surface ? AppColors.inactive : fill),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: scanStyle(size: 10.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? AppColors.textSecondary.withOpacity(0.35)
              : AppColors.textPrimary,
        ),
      ),
    );
  }
}
