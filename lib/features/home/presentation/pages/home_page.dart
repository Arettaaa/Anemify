import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/food_card.dart';
import '../widgets/habit_card.dart';
import '../widgets/home_header.dart';
import '../widgets/last_screening_card.dart';
import '../widgets/screening_hero_card.dart';
import '../widgets/section_header.dart';
import '../../../profile/data/profile_storage.dart';
import '../../../profile/presentation/widgets/profile_switcher.dart';

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

  @override
  void initState() {
    super.initState();
    _loadName();
  }


  Future<void> _loadName() async {
    final active = await ProfileStorage.getActive();
    if (!mounted) return;
    setState(() => _name = active?.name ?? 'Teman');
  }

  Future<void> _openSwitcher() async {
    final changed = await openProfileSwitcher(context);
    if (changed) _loadName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 130),
          children: [
            HomeHeader(name: _name, onProfileTap: _openSwitcher),
            const SizedBox(height: 20),
            ScreeningHeroCard(onStart: widget.onStartScan),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Skrining terakhir',
              actionLabel: 'Lihat riwayat',
              onAction: widget.onOpenHistory,
            ),
            const SizedBox(height: 14),
            // TODO: ganti dengan data asli dari sqflite
            const LastScreeningCard(
              title: 'Risiko anemia',
              subtitle: '30 Sep · Data contoh',
              status: 'Normal',
            ),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Kebiasaan kecil, manfaat besar',
              actionLabel: 'Atur',
              onAction: () {},
            ),
            const SizedBox(height: 14),
            const HabitCard(
              title: 'Contoh catatan TTD hari ini',
              time: '19:00',
              note: 'Sesuai anjuran tenaga kesehatan',
            ),
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