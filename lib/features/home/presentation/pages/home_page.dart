import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/domain/usecases/history_usecases.dart';
import '../../../history/presentation/history_revision.dart';
import '../../../history/presentation/widgets/history_detail_sheet.dart';
import '../../../history/presentation/widgets/history_scan_card.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../profile/presentation/profile_revision.dart';
import '../../../profile/presentation/widgets/profile_switcher.dart';
import '../../../scan/presentation/widgets/risk_badge.dart';
import '../../../scan/presentation/widgets/scan_messages.dart';
import '../../../ttd/domain/entities/ttd_settings.dart';
import '../../../ttd/domain/usecases/ttd_usecases.dart';
import '../../../ttd/presentation/pages/ttd_reminder_page.dart';
import '../../../ttd/presentation/ttd_revision.dart';
import '../widgets/food_card.dart';
import '../widgets/habit_card.dart';
import '../widgets/home_header.dart';
import '../widgets/last_screening_card.dart';
import '../widgets/screening_hero_card.dart';
import '../widgets/section_header.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onStartScan;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenEducation;

  const HomePage({
    super.key,
    required this.onStartScan,
    required this.onOpenHistory,
    required this.onOpenEducation,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _name = '';
  HistoryEntry? _last;
  bool _lastLoaded = false;
  TtdSettings? _ttd;
  bool _takenToday = false;

  @override
  void initState() {
    super.initState();
    historyRevision.addListener(_loadLast);
    ttdRevision.addListener(_loadTtd);
    profileRevision.addListener(_onProfileChanged);
    _onProfileChanged();
  }

  @override
  void dispose() {
    historyRevision.removeListener(_loadLast);
    ttdRevision.removeListener(_loadTtd);
    profileRevision.removeListener(_onProfileChanged);
    super.dispose();
  }

  /// Profil diganti/diubah dari mana pun -> muat ulang semuanya.
  void _onProfileChanged() {
    _loadName();
    _loadLast();
    _loadTtd();
  }

  Future<void> _loadName() async {
    final active = await sl<GetActiveProfile>()();
    if (!mounted) return;
    setState(() => _name = active?.name ?? 'Teman');
  }

  Future<void> _loadLast() async {
    final all = await sl<GetScanHistory>()(); // terbaru dulu
    if (!mounted) return;
    setState(() {
      _last = all.isEmpty ? null : all.first;
      _lastLoaded = true;
    });
  }

  Future<void> _loadTtd() async {
    final s = await sl<GetTtdSettings>()();
    final logs = await sl<GetTtdLogs>()();
    if (!mounted) return;
    setState(() {
      _ttd = s;
      _takenToday = logs.containsKey(dateKey(DateTime.now()));
    });
  }

  void _openTtdSettings() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const TtdReminderPage()));

  Future<void> _toggleToday() async {
    await sl<SetTtdTaken>()(DateTime.now(), !_takenToday);
    notifyTtdChanged();
  }

  Widget _lastScreening() {
    if (!_lastLoaded) return const SizedBox(height: 82);

    final e = _last;
    if (e == null) {
      return LastScreeningCard(
        title: 'Belum ada skrining',
        subtitle: 'Mulai skrining pertamamu',
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
        onTap: widget.onStartScan,
      );
    }

    return LastScreeningCard(
      title: judulKategori(e.category),
      subtitle: '${formatTglPendek(e.createdAt)} · ${sumberFoto(e)}',
      trailing: RiskBadge(category: e.category),
      onTap: () => showHistoryDetail(context, e),
    );
  }

  Widget _ttdCard() {
    final s = _ttd;
    if (s == null) return const SizedBox(height: 72);

    if (!s.enabled) {
      return HabitCard(
        title: 'Atur pengingat TTD',
        note: 'Ketuk untuk mengatur jadwal minum TTD',
        onTap: _openTtdSettings,
      );
    }

    if (!s.isScheduled(DateTime.now())) {
      return HabitCard(
        title: 'Tidak ada jadwal TTD hari ini',
        time: s.timeLabel,
        note: s.frequencyLabel,
        onTap: _openTtdSettings,
      );
    }

    return HabitCard(
      title: _takenToday ? 'TTD hari ini sudah diminum' : 'Minum TTD hari ini',
      time: s.timeLabel,
      note: s.frequencyLabel,
      done: _takenToday,
      onToggle: _toggleToday,
      onTap: _openTtdSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            HomeHeader(
              name: _name,
              onProfileTap: () => openProfileSwitcher(context),
            ),
            const SizedBox(height: 20),
            ScreeningHeroCard(onStart: widget.onStartScan),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Skrining terakhir',
              actionLabel: 'Lihat riwayat',
              onAction: widget.onOpenHistory,
            ),
            const SizedBox(height: 14),
            _lastScreening(),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Kebiasaan kecil, manfaat besar',
              actionLabel: 'Atur',
              onAction: _openTtdSettings,
            ),
            const SizedBox(height: 14),
            _ttdCard(),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Isi piring, tambah energi',
              actionLabel: 'Jelajahi semua',
              onAction: widget.onOpenEducation,
            ),
            const SizedBox(height: 14),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FoodCard(
                    imageAsset: 'assets/foods/bayam.png',
                    name: 'Bayam',
                    subtitle: 'Sayuran hijau',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FoodCard(
                    imageAsset: 'assets/foods/telur.png',
                    name: 'Telur',
                    subtitle: 'Protein sehari-hari',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
