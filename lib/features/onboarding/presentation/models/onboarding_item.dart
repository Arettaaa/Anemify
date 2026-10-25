class OnboardingItem {
  final String eyebrow;
  final String title;
  final String description;
  final String badge;
  final String imageAsset;
  final String buttonLabel;
  final String? footnote;
  final String? consentText;

  const OnboardingItem({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.badge,
    required this.imageAsset,
    this.buttonLabel = 'Lanjut',
    this.footnote,
    this.consentText,
  });

  bool get requiresConsent => consentText != null;
}