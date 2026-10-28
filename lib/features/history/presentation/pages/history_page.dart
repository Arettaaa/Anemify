import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../profile/presentation/widgets/profile_switcher.dart';
import '../../../scan/domain/entities/risk_category.dart';
import '../../../scan/presentation/widgets/scan_widgets.dart';
import '../../../ttd/presentation/ttd_revision.dart';
import '../../../ttd/presentation/widgets/ttd_tab.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/history_usecases.dart';
import '../history_revision.dart';
import '../widgets/history_detail_sheet.dart';
import '../widgets/history_scan_card.dart';
import '../widgets/risk_trend_chart.dart';

class HistoryPage extends StatefulWidget {
  final VoidCallback onStartScan;
  const HistoryPage({super.key, required this.onStartScan});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryEntry> _all = [];
  bool _loading = true;
  String _name = 'Profil';
  int _tab = 0; // 0 hasil scan, 1 konsumsi TTD
  bool _monthly = true;
  DateTime _anchor = DateTime.now();
  RiskCategory? _filter;

  @override
  void initState() {
    super.initState();
    historyRevision.addListener(_load);
    ttdRevision.addListener(_loadName);
    _load();
    _loadName();
  }

  @override
  void dispose() {
    historyRevision.removeListener(_load);
    ttdRevision.removeListener(_loadName);
    super.dispose();
  }

  Future<void> _load() async {
    final all = await sl<GetScanHistory>()();
    if (!mounted) return;
    setState(() {
      _all = all;
      _loading = false;
    });
  }

  Future<void> _loadName() async {
    final p = await sl<GetActiveProfile>()();
    if (!mounted) return;
    setState(() => _name = p?.name ?? 'Profil');
  }

  Future<void> _switchProfile() async {
    final changed = await openProfileSwitcher(context);
    if (changed) {
      notifyTtdChanged(); // reload nama + data TTD
      _load();
    }
  }

  DateTime get _start {
    final a = _anchor;
    if (_monthly) return DateTime(a.year, a.month);
    final d = DateTime(a.year, a.month, a.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  DateTime get _end => _monthly
      ? DateTime(_start.year, _start.month + 1)
      : _start.add(const Duration(days: 7));

  bool get _canNext => _end.isBefore(DateTime.now());

  void _shift(int dir) => setState(() {
        _anchor = _monthly
            ? DateTime(_start.year, _start.month + dir)
            : _start.add(Duration(days: 7 * dir));
      });

  String get _periodLabel {
    if (_monthly) return formatBulanTahun(_start);
    final last = _end.subtract(const Duration(days: 1));
    return '${formatTglPendek(_start)} – ${formatTglPendek(last)}';
  }

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.sizeOf(context).width < 360 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
            children: [
              const AppLogo(),
              const SizedBox(height: 24),
              const ScanTitle(
                title: 'Perjalanan sehatmu',
                subtitle: TextSpan(text: 'Pantau setiap langkah sehatmu.'),
              ),
              const SizedBox(height: 18),
              Center(child: _profileChip()),
              const SizedBox(height: 16),
              _tabs(),
              const SizedBox(height: 24),
              if (_tab == 0) ..._scanSection() else const TtdTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileChip() {
    return GestureDetector(
      onTap: _switchProfile,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.inactive),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline_rounded,
                size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(_name, style: scanStyle(size: 13, weight: FontWeight.w700)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  // ---------- Tabs ----------
  Widget _tabs() {
    Widget tab(int i, IconData icon, String label) {
      final active = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 46,
            decoration: BoxDecoration(
              color: active ? AppColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 17,
                    color:
                        active ? AppColors.primary : AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(label,
                    style: scanStyle(
                        size: 13.5,
                        weight: FontWeight.w700,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        tab(0, Icons.crop_free_rounded, 'Hasil scan'),
        tab(1, Icons.done_all_rounded, 'Konsumsi TTD'),
      ]),
    );
  }

  // ---------- Hasil scan ----------
  List<Widget> _scanSection() {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ];
    }

    final period = _all
        .where((e) =>
            !e.createdAt.isBefore(_start) && e.createdAt.isBefore(_end))
        .toList();
    final chartData = [...period]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final list =
        period.where((e) => _filter == null || e.category == _filter).toList();

    return [
      Row(
        children: [
          Expanded(
            child: Text('Tren risiko anemia',
                style: scanStyle(size: 17, weight: FontWeight.w700)),
          ),
          _modeToggle(),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          _circleBtn(Icons.arrow_back_rounded, () => _shift(-1)),
          Expanded(
            child: Text(_periodLabel,
                textAlign: TextAlign.center,
                style: scanStyle(size: 15, weight: FontWeight.w700)),
          ),
          _circleBtn(Icons.arrow_forward_rounded,
              _canNext ? () => _shift(1) : null),
        ],
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.inactive),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${_monthly ? 'Bulan' : 'Minggu'} terpilih · Kategori risiko skrining, bukan kadar Hb',
                style: scanStyle(size: 11.5, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            RiskTrendChart(
              entries: chartData,
              start: _start,
              end: _end,
              monthly: _monthly,
            ),
            if (chartData.isEmpty) ...[
              const SizedBox(height: 8),
              Text('Belum ada skrining di periode ini.',
                  style: scanStyle(size: 12, color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
      const SizedBox(height: 18),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('Semua', null),
            _chip('Rendah', RiskCategory.rendah),
            _chip('Perhatian', RiskCategory.perluPerhatian),
            _chip('Tinggi', RiskCategory.tinggi),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Text('${list.length} hasil scan',
          style: scanStyle(size: 17, weight: FontWeight.w700)),
      const SizedBox(height: 12),
      if (list.isEmpty)
        _emptyState()
      else
        for (final e in list) ...[
          HistoryScanCard(
            entry: e,
            onTap: () => showHistoryDetail(context, e),
          ),
          const SizedBox(height: 12),
        ],
    ];
  }

  Widget _modeToggle() {
    Widget item(String label, bool monthly) {
      final active = _monthly == monthly;
      return GestureDetector(
        onTap: () => setState(() {
          _monthly = monthly;
          _anchor = DateTime.now();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.textPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: scanStyle(
                  size: 12,
                  weight: FontWeight.w600,
                  color: active ? AppColors.white : AppColors.textSecondary)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        item('Mingguan', false),
        item('Bulanan', true),
      ]),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 18,
            color: onTap == null
                ? AppColors.textSecondary.withOpacity(0.35)
                : AppColors.textPrimary),
      ),
    );
  }

  Widget _chip(String label, RiskCategory? c) {
    final active = _filter == c;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = c),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: active ? AppColors.textPrimary : AppColors.surface,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(label,
              style: scanStyle(
                  size: 13,
                  weight: FontWeight.w600,
                  color: active ? AppColors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_rounded,
              size: 32, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          Text('Belum ada hasil scan di sini.',
              style: scanStyle(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Mulai skrining untuk melihat perjalanan sehatmu.',
              textAlign: TextAlign.center,
              style: scanStyle(size: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          ScanPrimaryButton(
            label: 'Mulai skrining',
            icon: Icons.crop_free_rounded,
            iconAfter: false,
            onPressed: widget.onStartScan,
          ),
        ],
      ),
    );
  }
}