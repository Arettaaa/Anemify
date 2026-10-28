import 'package:flutter/material.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/education/presentation/pages/education_page.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingPage(),
    ),
  );
}
