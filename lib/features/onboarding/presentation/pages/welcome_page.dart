import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_primary_button.dart';

class WelcomePage extends StatelessWidget {
  final String name;

  const WelcomePage({super.key, required this.name});

  void _goHome(BuildContext context) {
    // TODO: ganti Placeholder() dengan HomePage()
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Placeholder()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OnboardingHeader(
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.successSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 14, color: AppColors.success),
                              const SizedBox(width: 6),
                              Text(
                                'Profil siap',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: 345 / 352,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.asset(
                            'assets/images/welcome_mascot.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'SELAMAT DATANG, ${name.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Teman sehatmu,\nmulai hari ini.',
                        style: GoogleFonts.dmSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ami akan mendampingi skrining mata dan telapak tanganmu dengan langkah yang ringan dan jelas.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          height: 1.7,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      OnboardingPrimaryButton(
                        label: 'Lanjut ke Beranda',
                        onPressed: () => _goHome(context),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Skrining awal, bukan diagnosis medis.',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}