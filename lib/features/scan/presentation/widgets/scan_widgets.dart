import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_logo.dart';
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

/// Kerangka halaman scan. Isi bisa digulir; [bottom] (biasanya tombol utama)
/// menempel di bawah layar supaya selalu terlihat tanpa menggulir. Saat isi
/// lebih panjang dari layar, muncul petunjuk kecil "gulir ke bawah".
class ScanPageScaffold extends StatefulWidget {
  final List<Widget> children;
  final bool showBack;
  final Widget? bottom;
  const ScanPageScaffold({
    super.key,
    required this.children,
    this.showBack = true,
    this.bottom,
  });

  @override
  State<ScanPageScaffold> createState() => _ScanPageScaffoldState();
}

class _ScanPageScaffoldState extends State<ScanPageScaffold> {
  final _ctrl = ScrollController();
  bool _moreBelow = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(covariant ScanPageScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  void _update() {
    if (!mounted || !_ctrl.hasClients) return;
    final p = _ctrl.position;
    final more = p.maxScrollExtent > 24 && p.pixels < p.maxScrollExtent - 24;
    if (more != _moreBelow) setState(() => _moreBelow = more);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 360 ? 16.0 : 24.0;
    final bottom = widget.bottom;

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
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: _ctrl,
                          padding: EdgeInsets.fromLTRB(
                              hPad, 16, hPad, bottom == null ? 32 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // logo selalu tampil, tombol back opsional
                              ScanHeader(showBack: widget.showBack),
                              const SizedBox(height: 24),
                              ...widget.children,
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: _moreBelow ? 1 : 0,
                              child: const _ScrollHint(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bottom != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 16),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        border: Border(top: BorderSide(color: AppColors.inactive)),
                      ),
                      child: bottom,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradasi putih + panah kecil di tepi bawah area gulir: "masih ada isi di bawah".
class _ScrollHint extends StatelessWidget {
  const _ScrollHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white.withValues(alpha: 0),
            AppColors.white.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.pinkTint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.keyboard_double_arrow_down_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Gulir ke bawah',
                style: scanStyle(
                    size: 11, weight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
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
        const AppLogo(),
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
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.white,
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