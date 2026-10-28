import 'package:flutter/material.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../scan/presentation/pages/scan_tab.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../widgets/app_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// Tab yang sudah pernah dibuka. Yang belum, tidak dibangun dulu.
  final Set<int> _visited = {0};

  void _onTap(int i) => setState(() {
        _index = i;
        _visited.add(i);
      });

  Widget _tab(int i) {
    if (!_visited.contains(i)) return const SizedBox.shrink();
    switch (i) {
      case 0:
        return HomePage(
          onStartScan: () => _onTap(2),
          onOpenHistory: () => _onTap(1),
          onOpenEducation: () => _onTap(3),
        );
      case 1:
        return HistoryPage(onStartScan: () => _onTap(2));
      case 2:
        return const ScanTab();
      case 3:
        return const _PlaceholderPage('Edukasi'); // TODO: EducationPage()
      default:
        return const _PlaceholderPage('Pengaturan'); // TODO: SettingsPage()
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: List.generate(5, _tab),
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