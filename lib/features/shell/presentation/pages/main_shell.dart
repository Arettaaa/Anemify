import 'package:flutter/material.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../scan/presentation/scan_flow.dart';
import '../widgets/app_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _onTap(int i) {
    if (i == 2) {
      openScanFlow(context);
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    // index nav -> index halaman (Scan tidak punya tab)
    final pageIndex = const {0: 0, 1: 1, 3: 2, 4: 3}[_index]!;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: pageIndex,
        children: [
          HomePage(
            onStartScan: () => _onTap(2),
            onOpenHistory: () => _onTap(1),
            onOpenEducation: () => _onTap(3),
          ),
          const _PlaceholderPage('Riwayat'), // TODO: HistoryPage()
          const _PlaceholderPage('Edukasi'), // TODO: EducationPage()
          const _PlaceholderPage('Pengaturan'), // TODO: SettingsPage()
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