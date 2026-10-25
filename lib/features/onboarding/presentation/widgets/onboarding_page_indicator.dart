import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 8),
          width: active ? 28 : 8,
          height: active ? 6 : 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.inactive,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}