import 'dart:convert';
import 'dart:math' as math;

import '../../domain/entities/risk_category.dart';

class CategoryThresholds {
  const CategoryThresholds({required this.lowMax, this.highMin});

  factory CategoryThresholds.fromJson(Map<String, dynamic> j) => CategoryThresholds(
        lowMax: (j['low_max'] as num).toDouble(),
        highMin: (j['high_min'] as num?)?.toDouble(),
      );

  final double lowMax;
  final double? highMin; // null = hanya 2 kategori

  RiskCategory categorize(double score) {
    if (score < lowMax) return RiskCategory.rendah;
    if (highMin == null || score < highMin!) return RiskCategory.perluPerhatian;
    return RiskCategory.tinggi;
  }
}

/// Isi fusion_config.json hasil notebook Anemify_Fusion_PDR.
class FusionConfig {
  const FusionConfig({
    required this.method,
    required this.prior,
    required this.clip,
    required this.fused,
    required this.palmOnly,
    required this.konjOnly,
    required this.palmModelFile,
    required this.konjModelFile,
  });

  factory FusionConfig.fromJsonString(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final cats = j['categories'] as Map<String, dynamic>;
    final models = j['models'] as Map<String, dynamic>;
    return FusionConfig(
      method: j['method'] as String,
      prior: (j['prior'] as num).toDouble(),
      clip: (j['clip'] as num).toDouble(),
      fused: CategoryThresholds.fromJson(cats['gabungan'] as Map<String, dynamic>),
      palmOnly: CategoryThresholds.fromJson(cats['palm_saja'] as Map<String, dynamic>),
      konjOnly: CategoryThresholds.fromJson(cats['konjungtiva_saja'] as Map<String, dynamic>),
      palmModelFile: (models['palm'] as Map<String, dynamic>)['file'] as String,
      konjModelFile: (models['konjungtiva'] as Map<String, dynamic>)['file'] as String,
    );
  }

  final String method; // 'product_decision_rule' atau 'sum_rule'
  final double prior;
  final double clip;
  final CategoryThresholds fused;
  final CategoryThresholds palmOnly;
  final CategoryThresholds konjOnly;
  final String palmModelFile;
  final String konjModelFile;

  /// Product Decision Rule (Herdiyeni & Santoni 2012, Pers. 13), dinormalisasi.
  double fuse(double pPalm, double pKonj) {
    if (method == 'sum_rule') return (pPalm + pKonj) / 2;
    final z = _logit(pPalm) + _logit(pKonj) - _logit(prior);
    return 1 / (1 + math.exp(-z));
  }

  double _logit(double p) {
    final q = p.clamp(clip, 1 - clip).toDouble();
    return math.log(q / (1 - q));
  }
}