import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

TextStyle scanStyle({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.textPrimary,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  return GoogleFonts.dmSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

class ScanPageScaffold extends StatelessWidget {
  final List<Widget> children;
  final bool showBack;
  const ScanPageScaffold({
    super.key,
    required this.children,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 360 ? 16.0 : 24.0;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler:
            MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3),
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBack) ScanHeader(showBack: showBack),
                    const SizedBox(height: 24),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScanHeader extends StatelessWidget {
  final bool showBack;
  const ScanHeader({super.key, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/images/anemify_logo.png', height: 28),
        if (showBack) ...[
          const SizedBox(height: 16),
          Material(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.inactive),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.maybePop(context),
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ScanTitle extends StatelessWidget {
  final String title;
  final InlineSpan subtitle;
  const ScanTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 360;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: scanStyle(
            size: isSmall ? 26 : 30,
            weight: FontWeight.w700,
            letterSpacing: -0.7,
            height: 1.17,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          subtitle,
          style: scanStyle(
            size: 14,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class ScanPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool iconAfter;
  final VoidCallback? onPressed;

  const ScanPrimaryButton({
    super.key,
    required this.label,
    this.icon = Icons.arrow_forward_rounded,
    this.iconAfter = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final iconW = Icon(icon, size: 18, color: AppColors.white);
    final text = Flexible(
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: scanStyle(
          size: 15,
          weight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: iconAfter
              ? [text, const SizedBox(width: 8), iconW]
              : [iconW, const SizedBox(width: 8), text],
        ),
      ),
    );
  }
}