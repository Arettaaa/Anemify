import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double height;
  const AppLogo({super.key, this.height = 28});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1, // di dalam Row tetap seukuran logo
      child: SvgPicture.asset(
        'assets/images/anemify_logo.svg',
        height: height,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}