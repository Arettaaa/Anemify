import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'floating_mascot.dart'; 

class OnboardingHeroCard extends StatelessWidget {
  final String imageAsset;
  final String badge;

  const OnboardingHeroCard({
    super.key,
    required this.imageAsset,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 345 / 320,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FloatingMascot(
              child: Transform.scale(
                scale: 1.08, // sedikit zoom biar tepi gambar ga kelihatan pas bergerak
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
            ),
            // gradient gelap tipis di bawah
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.6, 1.0],
                    colors: [
                      Colors.transparent,
                      AppColors.textPrimary.withOpacity(0.25),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      badge,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}