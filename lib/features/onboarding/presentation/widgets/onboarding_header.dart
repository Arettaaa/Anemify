import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingHeader extends StatelessWidget {
  final Widget? trailing;

  const OnboardingHeader({super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/anemify_logo.png', height: 28),
        trailing ?? const _NoLoginChip(),
      ],
    );
  }
}

class _NoLoginChip extends StatelessWidget {
  const _NoLoginChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline,
              size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'Tanpa login',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}