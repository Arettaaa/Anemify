import 'dart:io';
import 'dart:typed_data';

import 'package:anemify/features/scan/data/models/quality_config.dart';
import 'package:anemify/features/scan/data/preprocessing/quality_checker.dart';
import 'package:anemify/features/scan/data/preprocessing/roi_preprocessor.dart';
import 'package:anemify/features/scan/domain/entities/scan_failure.dart';
import 'package:anemify/features/scan/domain/entities/scan_result.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _synthetic(int w, int h) {
  final b = Uint8List(w * h * 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      b[i] = (x * 3 + y) % 256;
      b[i + 1] = (x + y * 2) % 256;
      b[i + 2] = (x * y) % 256;
      final d2 = (x - 160) * (x - 160) + (y + 100) * (y + 100);
      b[i + 3] = (d2 >= 160 * 160 && d2 <= 250 * 250) ? 255 : 0;
    }
  }
  return b;
}

/// Gambar 224x224 penuh ROI dengan warna dari fungsi f(x, y, kanal).
RoiTensor _img224(int Function(int x, int y, int c) f) {
  const s = 224;
  final b = Uint8List(s * s * 4);
  for (var y = 0; y < s; y++) {
    for (var x = 0; x < s; x++) {
      final i = (y * s + x) * 4;
      for (var c = 0; c < 3; c++) {
        b[i + c] = f(x, y, c);
      }
      b[i + 3] = 255;
    }
  }
  return RoiPreprocessor().fromRgba(b, s, s)!;
}

void main() {
  final checker = QualityChecker(QualityConfig.fromJsonString(
      File('assets/config/quality_config.json').readAsStringSync()));

  test('metrik sama dengan Python (gambar sintetis)', () {
    final q = QualityChecker.measure(RoiPreprocessor().fromRgba(_synthetic(320, 180), 320, 180)!);
    expect(q.brightness, closeTo(130.6106, 0.05));
    expect(q.saturation, closeTo(0.5587, 0.002));
    expect(q.sharpness!, closeTo(373.86, 1.0));
  });

  test('gambar polos: kecerahan & saturasi tepat, ketajaman 0', () {
    final q = QualityChecker.measure(_img224((x, y, c) => [200, 80, 90][c]));
    expect(q.brightness, closeTo(117.02, 1e-6));
    expect(q.saturation, closeTo(0.6, 1e-9));
    expect(q.sharpness, 0);
  });

  test('terlalu gelap / terlalu terang / blur -> ditolak', () {
    QualityVerdict v(RoiTensor t) => checker.check(QualityChecker.measure(t), isEye: true);
    expect(v(_img224((x, y, c) => 20)).failure, ScanFailureType.tooDark);
    expect(v(_img224((x, y, c) => 250)).failure, ScanFailureType.tooBright);
    expect(v(_img224((x, y, c) => [150, 90, 100][c])).failure, ScanFailureType.blurry); // polos = tanpa tekstur
  });

  test('warna kusam -> peringatan saja, bukan penolakan', () {
    final v = checker.check(
        QualityChecker.measure(_img224((x, y, c) => (x + y).isEven ? 100 : 140)),
        isEye: true);
    expect(v.failure, isNull);
    expect(v.warnings, [ScanWarning.dullColor]);
  });

  test('foto wajar -> lolos tanpa peringatan', () {
    final v = checker.check(
        QualityChecker.measure(RoiPreprocessor().fromRgba(_synthetic(320, 180), 320, 180)!),
        isEye: true);
    expect(v.failure, isNull);
    expect(v.warnings, isEmpty);
  });

  test('tajam½ dan hue dihitung benar', () {
    final pink = QualityChecker.measure(_img224((x, y, c) => [200, 80, 90][c]));
    expect(pink.sharpnessHalf, 0);
    expect(pink.hue, closeTo(-5.0, 1e-9)); // merah muda -> negatif
    final brown = QualityChecker.measure(_img224((x, y, c) => [140, 90, 60][c]));
    expect(brown.hue, closeTo(22.5, 1e-9)); // cokelat -> positif
  });
}