import '../../domain/entities/risk_category.dart';
import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';
import 'fusion_config.dart';

/// Aturan keputusan: skor model -> kategori + peringatan.
class RiskDecider {
  const RiskDecider(this.config, {this.inconsistencyGap = 0.5});

  final FusionConfig config;

  /// Selisih skor palm vs mata yang dianggap "tidak konsisten".
  final double inconsistencyGap;

  ScanResult decide({double? palm, double? eye}) {
    if (palm != null && eye != null) {
      final score = config.fuse(palm, eye);
      var category = config.fused.categorize(score);
      final warnings = <ScanWarning>[];
      if ((palm - eye).abs() > inconsistencyGap) {
        warnings.add(ScanWarning.inconsistent);
        // Skrining: bukti bertentangan tidak boleh berujung "risiko rendah".
        if (category == RiskCategory.rendah) category = RiskCategory.perluPerhatian;
      }
      return ScanResult(
          category: category, score: score, palmScore: palm, eyeScore: eye, warnings: warnings);
    }
    if (palm != null) {
      return ScanResult(category: config.palmOnly.categorize(palm), score: palm, palmScore: palm);
    }
    if (eye != null) {
      return ScanResult(
        category: config.konjOnly.categorize(eye),
        score: eye,
        eyeScore: eye,
        warnings: const [ScanWarning.eyeOnly],
      );
    }
    throw const ScanFailure(ScanFailureType.noPhoto);
  }
}