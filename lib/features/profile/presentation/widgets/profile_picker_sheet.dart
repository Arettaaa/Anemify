import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/blur_sheet.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/profile_usecases.dart';/// pop result: 'changed' | 'add' | 'edit' | null
class ProfilePickerSheet extends StatefulWidget {
  const ProfilePickerSheet({super.key});

  @override
  State<ProfilePickerSheet> createState() => _ProfilePickerSheetState();
}

class _ProfilePickerSheetState extends State<ProfilePickerSheet> {
  List<Profile> _profiles = [];
  String? _activeId;

  @override
  void initState() {
    super.initState();
    _load();
  }

    Future<void> _load() async {
    final all = await sl<GetProfiles>()();
    final active = await sl<GetActiveProfile>()();
    if (!mounted) return;
    setState(() {
      _profiles = all;
      _activeId = active?.id;
    });
  }

  Future<void> _select(Profile p) async {
    await sl<SetActiveProfile>()(p.id);
    if (!mounted) return;
    Navigator.of(context).pop('changed');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetHeader(title: 'Siapa yang ingin skrining?'),
        const SizedBox(height: 20),
        for (final p in _profiles) ...[
          _ProfileTile(
            profile: p,
            selected: p.id == _activeId,
            onTap: () => _select(p),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.of(context).pop('add'),
          child: CustomPaint(
            painter: _DashedBorderPainter(),
            child: SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded,
                      size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Tambah profil keluarga',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop('edit'),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Ubah profil aktif',
              style: GoogleFonts.dmSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final Profile profile;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.pinkTint : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primarySoft : AppColors.inactive,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Text(
                profile.initial,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile.subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded,
                  size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(16),
      ));
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
        d += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}