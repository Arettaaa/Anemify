import 'dart:convert';

class QualityThresholds {
  const QualityThresholds({
    required this.brightnessMin,
    required this.brightnessMax,
    required this.saturationMin,
    required this.sharpnessMin,
  });

  factory QualityThresholds.fromJson(Map<String, dynamic> j) => QualityThresholds(
        brightnessMin: (j['brightness_min'] as num).toDouble(),
        brightnessMax: (j['brightness_max'] as num).toDouble(),
        saturationMin: (j['saturation_min'] as num).toDouble(),
        sharpnessMin: (j['sharpness_min'] as num).toDouble(),
      );

  final double brightnessMin;
  final double brightnessMax;
  final double saturationMin;
  final double sharpnessMin;
}

/// Isi quality_config.json (batas dari persentil 0,5% / 99,5% ROI dataset).
class QualityConfig {
  const QualityConfig({required this.palm, required this.konj});

  factory QualityConfig.fromJsonString(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return QualityConfig(
      palm: QualityThresholds.fromJson(j['palm'] as Map<String, dynamic>),
      konj: QualityThresholds.fromJson(j['konjungtiva'] as Map<String, dynamic>),
    );
  }

  final QualityThresholds palm;
  final QualityThresholds konj;
}