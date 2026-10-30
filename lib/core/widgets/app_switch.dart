import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Switch gaya Anemify: jempol selalu putih,
/// jalur abu-abu saat mati, merah saat hidup.
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: const WidgetStatePropertyAll(AppColors.white),
      // ikon kosong supaya jempol sama besar saat mati & hidup
      thumbIcon: const WidgetStatePropertyAll(Icon(null)),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : const Color(0xFFD5D9E0),
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      overlayColor: WidgetStatePropertyAll(
        AppColors.primary.withValues(alpha: 0.08),
      ),
    );
  }
}