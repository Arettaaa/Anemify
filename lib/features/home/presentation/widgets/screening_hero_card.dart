import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ScreeningHeroCard extends StatelessWidget {
  final VoidCallback onStart;

  const ScreeningHeroCard({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        color: AppColors.pinkTint,
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            // lingkaran dekoratif
            Positioned(
              right: -30,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // ikon mata & tangan
            Positioned(
              right: 0,
              top: 28,
              child: SizedBox(
                width: 100,
                height: 110,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: _tile(Icons.remove_red_eye_outlined, 60),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Transform.rotate(
                        angle: 0.12,
                        child: _tile(Icons.back_hand_outlined, 56),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'SKRINING TANPA JARUM',
                        style: GoogleFonts.dmSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kenali risikonya,\nmulai langkah sehatmu.',
                  style: GoogleFonts.dmSans(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cukup foto mata dan telapak tangan.\nMudah, nyaman, aman.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.crop_free_rounded, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Mulai skrining',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.primary, size: size * 0.5),
    );
  }
}