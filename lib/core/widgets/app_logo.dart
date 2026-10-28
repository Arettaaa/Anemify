import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double height;
  const AppLogo({super.key, this.height = 28});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/anemify_logo.svg',
      height: height,
    );
  }
}