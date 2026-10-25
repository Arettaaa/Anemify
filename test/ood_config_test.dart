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

  test('tingkat OOD konsisten dengan ambang (berlaku untuk mode ketat maupun dua tingkat)', () {
    expect(cfg.palmReject, cfg.palmMax);
    for (final eye in [true, false]) {
      final soft = cfg.maxFor(isEye: eye);
      final hard = eye ? cfg.konjReject : cfg.palmReject;
      expect(hard, greaterThanOrEqualTo(soft));
      expect(cfg.level(soft - 1, isEye: eye), OodLevel.ok);
      expect(cfg.level(hard + 1, isEye: eye), OodLevel.foreign);
      if (hard > soft) expect(cfg.level((soft + hard) / 2, isEye: eye), OodLevel.unusual);
    }
  });
}