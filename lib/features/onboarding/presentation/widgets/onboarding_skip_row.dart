import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingSkipRow extends StatelessWidget {
  final VoidCallback? onSkip;
  final String? counter;

  const OnboardingSkipRow({super.key, this.onSkip, this.counter});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Kenalan dulu, yuk',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        if (counter != null)
          Text(
            counter!,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          )
        else
          GestureDetector(
            onTap: onSkip,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Lewati pengenalan',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}