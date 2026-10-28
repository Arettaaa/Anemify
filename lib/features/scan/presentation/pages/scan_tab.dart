import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import 'scan_how_it_works_page.dart';
import 'scan_intro_page.dart';

/// Tab Scan: punya navigator sendiri supaya bottom nav tetap terlihat.
/// Satu ScanBloc dipakai semua halaman di dalam tab ini.
class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScanBloc>()..add(const ScanStarted()),
      child: NavigatorPopHandler(
        onPopWithResult: (_) => _navKey.currentState?.maybePop(),
        child: Navigator(
          key: _navKey,
          onGenerateRoute: (_) =>
              MaterialPageRoute(builder: (_) => const _ScanEntry()),
        ),
      ),
    );
  }
}

class _ScanEntry extends StatefulWidget {
  const _ScanEntry();

  @override
  State<_ScanEntry> createState() => _ScanEntryState();
}

class _ScanEntryState extends State<_ScanEntry> {
  bool? _seen;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) {
        setState(() => _seen = p.getBool(kScanHowtoSeenKey) ?? false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_seen == null) return const Scaffold(backgroundColor: Colors.white);
    return _seen!
        ? const ScanIntroPage()
        : const ScanHowItWorksPage(isGate: true);
  }
}