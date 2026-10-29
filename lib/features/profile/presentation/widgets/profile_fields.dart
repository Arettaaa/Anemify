import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile.dart';
/// Pilihan jenis kelamin (2 kartu).
class SexSelector extends StatelessWidget {
  final Sex? value;
  final ValueChanged<Sex> onChanged;

  const SexSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _card(Sex.perempuan, Icons.female_rounded)),
        const SizedBox(width: 8),
        Expanded(child: _card(Sex.lakiLaki, Icons.male_rounded)),
      ],
    );
  }

  Widget _card(Sex s, IconData icon) {
    final selected = value == s;
    return GestureDetector(
      onTap: () => onChanged(s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primarySoft : AppColors.inactive,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              s.label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle "Sedang hamil", hanya tampil bila relevan.
class PregnancySwitch extends StatelessWidget {
  final bool visible;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PregnancySwitch({
    super.key,
    required this.visible,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sedang hamil',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Untuk menyesuaikan edukasi & pengingat TTD.',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: value,
                      onChanged: onChanged,
                      activeThumbColor: AppColors.white,
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}