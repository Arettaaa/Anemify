import 'package:anemify/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfigurasi Status Bar (Atas) & Navigation Bar (Bawah)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  setupInjection();
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
        fontFamily: GoogleFonts.dmSans().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF233C),
          primary: const Color(0xFFEF233C),
          onSurface: const Color(0xFF2B2D42),
        ),
      ),
      // SEMENTARA untuk cek paritas model; nanti diganti halaman utama
      home: const SplashScreen(),
    );
  }
}
