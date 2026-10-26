import 'package:flutter/material.dart';

import 'pages/scan_intro_page.dart';

void openScanFlow(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ScanIntroPage()),
  );
}