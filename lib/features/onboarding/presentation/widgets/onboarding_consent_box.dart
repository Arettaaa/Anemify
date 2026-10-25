import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingConsentBox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String text;
  final String? title;
  final bool outlined;

  const OnboardingConsentBox({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.text,
    this.title,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: outlined ? AppColors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: outlined ? Border.all(color: AppColors.inactive) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: checked ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: checked ? AppColors.primary : AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.dmSans(
                      fontSize: 12.5,
                      height: 1.6,
                      color: AppColors.textSecondary,
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
}