import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_logo.dart';

class EducationHeader extends StatelessWidget {
  const EducationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo Anemify (SVG, sama dengan Beranda)
        const AppLogo(),
        const SizedBox(height: 20),

        // Judul Utama (DM Sans 26px Bold)
        Text(
          'Bekal untuk lebih sehat',
          style: GoogleFonts.dmSans(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.6,
            color: const Color(0xFF2B2D42),
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle
        Text(
          'Belajar sedikit hari ini, lebih peduli setiap hari.',
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}