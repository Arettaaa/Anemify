import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bagian yang menempel di atas saat di-scroll (dipakai di CustomScrollView).
/// Latar putih; garis tipis muncul saat konten lewat di bawahnya.
class PinnedHeader extends StatelessWidget {
  final double height;
  final Widget child;

  const PinnedHeader({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedDelegate(height: height, child: child),
    );
  }
}

class _PinnedDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final stuck = shrinkOffset > 0 || overlapsContent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: stuck ? AppColors.inactive : Colors.transparent,
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedDelegate old) =>
      old.height != height || old.child != child;
}