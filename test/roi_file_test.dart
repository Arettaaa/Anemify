import 'dart:io';

import 'package:anemify/features/scan/data/preprocessing/roi_preprocessor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Porsi ROI dari Colab (sel 3A)
  const expected = {
    'konj_1.png': 0.225, 'konj_2.png': 0.350, 'konj_3.png': 0.261,
    'palm_1.png': 1.000, 'palm_2.png': 1.000, 'palm_3.png': 1.000,
  };
  for (final e in expected.entries) {
    test('porsi ROI ${e.key} sama dengan Colab', () {
      final bytes = File('assets/debug/${e.key}').readAsBytesSync();
      final t = RoiPreprocessor().fromEncoded(bytes);
      expect(t, isNotNull);
      print('${e.key}: porsi ROI ${t!.roiFraction.toStringAsFixed(3)} (Colab ${e.value})');
      expect(t.roiFraction, closeTo(e.value, 0.005));
    });
  }
}