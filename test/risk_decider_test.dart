import 'dart:io';

import 'package:anemify/features/scan/data/models/fusion_config.dart';
import 'package:anemify/features/scan/data/models/risk_decider.dart';
import 'package:anemify/features/scan/domain/entities/risk_category.dart';
import 'package:anemify/features/scan/domain/entities/scan_failure.dart';
import 'package:anemify/features/scan/domain/entities/scan_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cfg = FusionConfig.fromJsonString(
      File('assets/config/fusion_config.json').readAsStringSync());
  final decider = RiskDecider(cfg);

  test('dua foto konsisten -> kategori dari skor gabungan, tanpa peringatan', () {
    final r = decider.decide(palm: 0.8, eye: 0.7);
    expect(r.usesFusion, isTrue);
    expect(r.score, closeTo(cfg.fuse(0.8, 0.7), 1e-12));
    expect(r.category, cfg.fused.categorize(r.score));
    expect(r.warnings, isEmpty);
  });

  test('bertentangan & skor gabungan rendah -> dinaikkan ke perlu perhatian', () {
    final fused = cfg.fuse(0.1, 0.9);
    expect(cfg.fused.categorize(fused), RiskCategory.rendah); // prasyarat
    final r = decider.decide(palm: 0.1, eye: 0.9);
    expect(r.warnings, [ScanWarning.inconsistent]);
    expect(r.category, RiskCategory.perluPerhatian);
  });

  test('hanya palm -> batas palm_saja', () {
    final r = decider.decide(palm: 0.8);
    expect(r.category, cfg.palmOnly.categorize(0.8));
    expect(r.usesFusion, isFalse);
    expect(r.warnings, isEmpty);
  });

  test('hanya mata -> batas konjungtiva_saja + peringatan', () {
    final r = decider.decide(eye: 0.5);
    expect(r.category, cfg.konjOnly.categorize(0.5));
    expect(r.warnings, [ScanWarning.eyeOnly]);
  });

  test('tanpa foto -> ScanFailure.noPhoto', () {
    expect(
      () => decider.decide(),
      throwsA(isA<ScanFailure>().having((f) => f.type, 'type', ScanFailureType.noPhoto)),
    );
  });
}