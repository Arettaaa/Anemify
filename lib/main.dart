import 'package:anemify/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Aktifkan mode Edge-to-Edge agar efek overlay dialog mengalir ke paling bawah
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent, // Ubah jadi transparan
      systemNavigationBarDividerColor: Colors.transparent,
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
      home: const SplashScreen(),
    );
  }
}
