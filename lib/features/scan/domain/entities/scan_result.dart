import 'package:equatable/equatable.dart';

import 'quality_metrics.dart';
import 'risk_category.dart';

/// Catatan tambahan pada hasil skrining (ditampilkan UI sebagai peringatan).
enum ScanWarning {
  /// Skor palm dan mata berbeda jauh; kategori minimal "perlu perhatian".
  inconsistent,

  /// Hanya foto mata yang dipakai; model mata saja kurang informatif.
  eyeOnly,

  /// Warna foto kusam (cahaya kurang); hasil mungkin kurang akurat.
  dullColor,

  /// Foto kurang mirip data latih (zona abu-abu OOD); hasil kurang pasti.
  atypicalPhoto,
}

/// Hasil skrining yang diterima lapisan UI.
class ScanResult extends Equatable {
  const ScanResult({
    required this.category,
    required this.score,
    this.palmScore,
    this.eyeScore,
    this.warnings = const [],
    this.palmQuality,
    this.eyeQuality,
  });

  final RiskCategory category;

  /// Skor penentu kategori: skor gabungan (PDR) bila dua foto, atau skor model tunggal.
  final double score;
  final double? palmScore;
  final double? eyeScore;
  final List<ScanWarning> warnings;
  final QualityMetrics? palmQuality;
  final QualityMetrics? eyeQuality;

  bool get usesFusion => palmScore != null && eyeScore != null;

  /// Salinan dengan peringatan tambahan (tanpa duplikat) dan data kualitas.
  ScanResult withExtra({
    List<ScanWarning> warnings = const [],
    QualityMetrics? palmQuality,
    QualityMetrics? eyeQuality,
  }) =>
      ScanResult(
        category: category,
        score: score,
        palmScore: palmScore,
        eyeScore: eyeScore,
        warnings: {...this.warnings, ...warnings}.toList(),
        palmQuality: palmQuality ?? this.palmQuality,
        eyeQuality: eyeQuality ?? this.eyeQuality,
      );

  @override
  List<Object?> get props =>
      [category, score, palmScore, eyeScore, warnings, palmQuality, eyeQuality];
}