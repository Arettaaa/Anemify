import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.inactive),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Icon(Icons.arrow_back_rounded,
            size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}