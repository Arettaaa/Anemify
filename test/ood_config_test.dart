import 'dart:io';

import 'package:anemify/features/scan/data/models/ood_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cfg = OodConfig.fromJsonString(File('assets/config/ood_config.json').readAsStringSync());

  test('ambang dan nama model terbaca', () {
    expect(cfg.modelFile, 'ood_v1_fp32.tflite');
    expect(cfg.palmMax, closeTo(81.40, 0.01));
    expect(cfg.konjMax, closeTo(66.98, 0.01));
  });

  test('foto debug lolos detektornya sendiri, ditolak detektor modalitas lain', () {
    expect(cfg.testVectors, hasLength(6));
    for (final v in cfg.testVectors) {
      final isEye = v.file.startsWith('konj');
      expect(cfg.isTarget(isEye ? v.konj : v.palm, isEye: isEye), isTrue, reason: v.file);
      expect(cfg.isTarget(isEye ? v.palm : v.konj, isEye: !isEye), isFalse, reason: v.file);
    }
  });
}