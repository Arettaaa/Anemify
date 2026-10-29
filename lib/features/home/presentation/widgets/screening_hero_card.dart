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
        child: Stack(
                   children: [
            Positioned(right: -64, top: -38, child: _ring(200, 0.10)),
            Positioned(right: -29, top: -3, child: _ring(130, 0.14)),
            Positioned(
              right: 24,
              top: 26,
              child: Transform.rotate(
                angle: -0.1,
                child: _tile(Icons.remove_red_eye_outlined, 64, AppColors.white),
              ),
            ),
            Positioned(
              right: 10,
              top: 84,
              child: Transform.rotate(
                angle: 0.12,
                child: _tile(Icons.back_hand_outlined, 60,
                    const Color(0xFFFFDDE0),
                    border: true),
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 22),              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 70),
                    child: Text(
                      'Kenali risikonya,\nmulai langkah sehatmu.',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(right: 90),
                    child: Text(
                      'Cukup foto mata dan telapak tangan.\nMudah, nyaman, aman.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.5,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _ring(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primarySoft.withValues(alpha: opacity),
        ),
      );

  Widget _tile(IconData icon, double size, Color bg, {bool border = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: border ? Border.all(color: AppColors.white, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.primary, size: size * 0.48),
    );
  }
}