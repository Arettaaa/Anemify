import 'dart:math' as math;
import 'dart:typed_data';

import '../../domain/entities/quality_metrics.dart';
import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';
import '../models/quality_config.dart';
import 'roi_preprocessor.dart';

typedef QualityVerdict = ({ScanFailureType? failure, List<ScanWarning> warnings});

class QualityChecker {
  const QualityChecker(this.config);

  final QualityConfig config;

  /// brightness, saturation, sharpness: rumus sama persis dengan fungsi metrics() di Colab.
  static QualityMetrics measure(RoiTensor t) {
    const s = RoiPreprocessor.size;
    final d = t.data;
    final lum = Float64List(s * s);
    final roi = List<bool>.filled(s * s, false);
    var n = 0;
    var lumSum = 0.0, satSum = 0.0, rSum = 0.0, gSum = 0.0, bSum = 0.0;
    for (var p = 0; p < s * s; p++) {
      final r = d[p * 4], g = d[p * 4 + 1], b = d[p * 4 + 2];
      lum[p] = 0.299 * r + 0.587 * g + 0.114 * b;
      if (d[p * 4 + 3] == 255) {
        roi[p] = true;
        n++;
        lumSum += lum[p];
        rSum += r;
        gSum += g;
        bSum += b;
        final mx = math.max(r, math.max(g, b));
        final mn = math.min(r, math.min(g, b));
        satSum += mx > 0 ? (mx - mn) / mx : 0.0;
      }
    }
    if (n == 0) return const QualityMetrics(brightness: 0, saturation: 0);

    // Setengah resolusi: rata-rata blok 2x2 (blok dihitung ROI bila keempat pikselnya ROI).
    const h = s ~/ 2;
    final lum2 = Float64List(h * h);
    final roi2 = List<bool>.filled(h * h, false);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < h; x++) {
        final p = 2 * y * s + 2 * x;
        roi2[y * h + x] = roi[p] && roi[p + 1] && roi[p + s] && roi[p + s + 1];
        lum2[y * h + x] = (lum[p] + lum[p + 1] + lum[p + s] + lum[p + s + 1]) / 4;
      }
    }

    return QualityMetrics(
      brightness: lumSum / n,
      saturation: satSum / n,
      sharpness: _laplacianVar(lum, roi, s),
      sharpnessHalf: _laplacianVar(lum2, roi2, h),
      hue: _signedHue(rSum / n, gSum / n, bSum / n),
    );
  }

  /// Varians Laplacian 4-tetangga, hanya di piksel yang dirinya dan keempat tetangganya ROI.
  static double? _laplacianVar(Float64List lum, List<bool> roi, int s) {
    final lap = <double>[];
    for (var y = 1; y < s - 1; y++) {
      for (var x = 1; x < s - 1; x++) {
        final p = y * s + x;
        if (roi[p] && roi[p - s] && roi[p + s] && roi[p - 1] && roi[p + 1]) {
          lap.add(4 * lum[p] - lum[p - s] - lum[p + s] - lum[p - 1] - lum[p + 1]);
        }
      }
    }
    if (lap.length <= 50) return null;
    final mean = lap.reduce((a, b) => a + b) / lap.length;
    var v = 0.0;
    for (final l in lap) {
      v += (l - mean) * (l - mean);
    }
    return v / lap.length;
  }

  /// Hue HSV dari warna rata-rata, dalam derajat (-180..180].
  static double _signedHue(double r, double g, double b) {
    final mx = math.max(r, math.max(g, b));
    final mn = math.min(r, math.min(g, b));
    final c = mx - mn;
    if (c < 1e-9) return 0;
    final double h;
    if (mx == r) {
      h = 60 * (g - b) / c;
    } else if (mx == g) {
      h = 60 * ((b - r) / c + 2);
    } else {
      h = 60 * ((r - g) / c + 4);
    }
    return h > 180 ? h - 360 : h;
  }

  /// Gelap/terang/blur -> ditolak (foto diulang). Kusam -> peringatan saja,
  /// karena konjungtiva pucat adalah tanda anemia dan tidak boleh disaring.
  QualityVerdict check(QualityMetrics q, {required bool isEye}) {
    final th = isEye ? config.konj : config.palm;
    const none = <ScanWarning>[];
    if (q.brightness < th.brightnessMin) return (failure: ScanFailureType.tooDark, warnings: none);
    if (q.brightness > th.brightnessMax) return (failure: ScanFailureType.tooBright, warnings: none);
    final sh = q.sharpness;
    if (sh != null && sh < th.sharpnessMin) return (failure: ScanFailureType.blurry, warnings: none);
    return (
      failure: null,
      warnings: q.saturation < th.saturationMin ? const [ScanWarning.dullColor] : none,
    );
  }
}