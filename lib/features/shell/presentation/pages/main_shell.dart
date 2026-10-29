import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini wajib ada

import '../../../education/presentation/pages/education_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../scan/presentation/pages/scan_tab.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../widgets/app_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _educationTabIndex = 0;
  String? _educationFoodName;

  final Set<int> _visited = {0};

  void _onTap(int i) {
    setState(() {
      _index = i;
      _visited.add(i);
    });
  }

  void _openEducation([int tabIndex = 0, String? foodName]) {
    setState(() {
      _educationTabIndex = tabIndex;
      _educationFoodName = foodName;
      _index = 3;
      _visited.add(3);
    });
  }

  Widget _tab(int i) {
    if (!_visited.contains(i)) return const SizedBox.shrink();

    switch (i) {
      case 0:
        return HomePage(
          onStartScan: () => _onTap(2),
          onOpenHistory: () => _onTap(1),
          onOpenEducation: _openEducation,
        );
      case 1:
        return HistoryPage(onStartScan: () => _onTap(2));
      case 2:
        return const ScanTab();
      case 3:
        return EducationPage(
          initialTabIndex: _educationTabIndex,
          initialFoodName: _educationFoodName,
        );
      case 4:
        return const SettingsPage();
      default:
        return const SettingsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white, // Memaksa bar bawah jadi putih
        systemNavigationBarIconBrightness:
            Brightness.dark, // Ikon navigasi jadi gelap
      ),
      child: Scaffold(
        body: IndexedStack(index: _index, children: List.generate(5, _tab)),
        bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: _onTap),
      ),
    );
  }
}
