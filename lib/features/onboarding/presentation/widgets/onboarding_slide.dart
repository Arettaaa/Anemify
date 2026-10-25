import 'package:flutter/material.dart';
import '../models/onboarding_item.dart';
import 'onboarding_consent_box.dart';
import 'onboarding_hero_card.dart';
import 'onboarding_page_indicator.dart';
import 'onboarding_text_content.dart';

class OnboardingSlide extends StatelessWidget {
  final OnboardingItem item;
  final int index;
  final int total;
  final bool consent;
  final ValueChanged<bool> onConsentChanged;

  const OnboardingSlide({
    super.key,
    required this.item,
    required this.index,
    required this.total,
    required this.consent,
    required this.onConsentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingHeroCard(imageAsset: item.imageAsset, badge: item.badge),
          const SizedBox(height: 24),
          OnboardingPageIndicator(count: total, currentIndex: index),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            key: ValueKey(index),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - v)),
                child: child,
              ),
            ),
            child: OnboardingTextContent(
              eyebrow: item.eyebrow,
              title: item.title,
              description: item.description,
            ),
          ),
          if (item.consentText != null) ...[
            const SizedBox(height: 20),
            OnboardingConsentBox(
              checked: consent,
              onChanged: onConsentChanged,
              text: item.consentText!,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}