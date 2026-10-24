import 'package:equatable/equatable.dart';

import 'risk_category.dart';

/// Catatan tambahan pada hasil skrining (ditampilkan UI sebagai peringatan).
enum ScanWarning {
  /// Skor palm dan mata berbeda jauh; kategori minimal "perlu perhatian".
  inconsistent,

  /// Hanya foto mata yang dipakai; model mata saja kurang informatif.
  eyeOnly,
}

/// Hasil skrining yang diterima lapisan UI.
class ScanResult extends Equatable {
  const ScanResult({
    required this.category,
    required this.score,
    this.palmScore,
    this.eyeScore,
    this.warnings = const [],
  });

  final RiskCategory category;

  /// Skor penentu kategori: skor gabungan (PDR) bila dua foto, atau skor model tunggal.
  final double score;
  final double? palmScore;
  final double? eyeScore;
  final List<ScanWarning> warnings;

  bool get usesFusion => palmScore != null && eyeScore != null;

  @override
  List<Object?> get props => [category, score, palmScore, eyeScore, warnings];
}