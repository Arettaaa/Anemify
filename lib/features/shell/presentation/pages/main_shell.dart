import 'package:flutter/material.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../scan/presentation/pages/scan_tab.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../widgets/app_bottom_nav.dart';
import '../../../education/presentation/pages/education_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _onTap(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(
            onStartScan: () => _onTap(2),
            onOpenHistory: () => _onTap(1),
            onOpenEducation: () => _onTap(3),
          ),
          HistoryPage(onStartScan: () => _onTap(2)), // Punya temanmu (Riwayat)
          const EducationPage(), // Punya kamu (Edukasi)
          const _PlaceholderPage('Pengaturan'), // Placeholder sisa
        ],
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: _onTap),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title (placeholder)')),
    );
  }
}
