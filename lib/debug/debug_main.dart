import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../features/scan/presentation/pages/debug_parity_page.dart';

/// Entry point khusus uji logika (halaman debug), terpisah dari UI utama.
/// Jalankan: flutter run -t lib/debug/debug_main.dart -d ce430ef
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupInjection();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DebugParityPage(),
  ));
}