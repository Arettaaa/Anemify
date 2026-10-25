import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingTextContent extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  const OnboardingTextContent({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: -0.8,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          description,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            height: 1.8,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}