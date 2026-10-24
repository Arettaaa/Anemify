import 'dart:convert';
import 'dart:io';

import 'package:anemify/features/scan/data/models/fusion_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PDR di Dart sama dengan notebook (test_vectors)', () {
    final raw = File('assets/config/fusion_config.json').readAsStringSync();
    final cfg = FusionConfig.fromJsonString(raw);
    final vectors = (jsonDecode(raw)['test_vectors'] as List).cast<Map<String, dynamic>>();
    expect(vectors, isNotEmpty);
    for (final v in vectors) {
      final p = cfg.fuse((v['p_palm'] as num).toDouble(), (v['p_konj'] as num).toDouble());
      print('palm ${v['p_palm']} + konj ${v['p_konj']} -> Dart ${p.toStringAsFixed(6)} | notebook ${v['p_gabungan']} | ${cfg.fused.categorize(p).key}');
      expect(p, closeTo((v['p_gabungan'] as num).toDouble(), 1e-6), reason: '$v');
      expect(cfg.fused.categorize(p).key, v['kategori'], reason: '$v');
    }
  });
}