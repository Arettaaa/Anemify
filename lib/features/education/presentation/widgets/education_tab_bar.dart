import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class EducationTabBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const EducationTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<EducationTabBar> createState() => _EducationTabBarState();
}

class _EducationTabBarState extends State<EducationTabBar> {
  late List<GlobalKey> _tabKeys;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());

    // Auto-center tab aktif saat pertama kali halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTab(widget.selectedIndex);
    });
  }

  @override
  void didUpdateWidget(covariant EducationTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelectedTab(widget.selectedIndex);
    }
  }

  /// Fungsi untuk menggeser tab yang dipilih ke tengah layar (center)
  void _scrollToSelectedTab(int index) {
    if (index >= 0 && index < _tabKeys.length) {
      final keyContext = _tabKeys[index].currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          alignment: 0.5, // 0.5 memastikan posisi item berada di tengah layar
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic, // Animasi pergeseran yang sangat halus
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(), // Scroll terasa alami & smooth
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(widget.tabs.length, (index) {
          final isSelected = widget.selectedIndex == index;
          return Padding(
            key: _tabKeys[index],
            padding: EdgeInsets.only(
              right: index == widget.tabs.length - 1 ? 0 : 8,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  widget.onTabSelected(index);
                  _scrollToSelectedTab(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    widget.tabs[index],
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF5A5C69),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
