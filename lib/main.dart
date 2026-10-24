import 'package:flutter/material.dart';

import 'features/scan/presentation/pages/debug_parity_page.dart';

void main() {
  runApp(const AnemifyApp());
}

class AnemifyApp extends StatelessWidget {
  const AnemifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anemify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF233C),
          primary: const Color(0xFFEF233C),
          onSurface: const Color(0xFF2B2D42),
        ),
      ),
      // SEMENTARA untuk cek paritas model; nanti diganti halaman utama
      home: const DebugParityPage(),
    );
  }
}