import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

Future<T?> showBlurSheet<T>(BuildContext context, {required Widget child}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false, // tap latar ditangani _BlurSheet
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (ctx, animation, _) =>
        _BlurSheet(animation: animation, child: child),
    transitionBuilder: (_, _, _, w) => w,
  );
}

class _BlurSheet extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _BlurSheet({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return Stack(
      children: [
        // latar: blur + gelap, fade sesuai animasi
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: AnimatedBuilder(
              animation: curved,
              builder: (_, _) {
                final t = curved.value;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6 * t, sigmaY: 6 * t),
                  child: Container(
                    color: AppColors.textPrimary.withValues(alpha: 0.25 * t),
                  ),
                );
              },
            ),
          ),
        ),
        // sheet: meluncur dari bawah
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                0,
                12,
                12 + mq.viewInsets.bottom + mq.padding.bottom,
              ),
              child: Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxHeight: mq.size.height * 0.85),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SheetHeader extends StatelessWidget {
  final String title;
  const SheetHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}