import 'package:anemify/features/scan/domain/entities/risk_category.dart';
import 'package:anemify/features/scan/domain/entities/scan_result.dart';

class HistoryEntry {
  final int? id;
  final String? profileId;
  final DateTime createdAt;
  final RiskCategory category;
  final double score;
  final double? palmScore;
  final double? eyeScore;
  final bool usesFusion;
  final List<ScanWarning> warnings;

  const HistoryEntry({
    this.id,
    this.profileId,
    required this.createdAt,
    required this.category,
    required this.score,
    this.palmScore,
    this.eyeScore,
    this.usesFusion = false,
    this.warnings = const [],
  });

  factory HistoryEntry.fromScanResult(ScanResult r,
          {String? profileId, DateTime? now}) =>
      HistoryEntry(
        profileId: profileId,
        createdAt: now ?? DateTime.now(),
        category: r.category,
        score: r.score,
        palmScore: r.palmScore,
        eyeScore: r.eyeScore,
        usesFusion: r.usesFusion,
        warnings: r.warnings,
      );

  HistoryEntry copyWith({String? profileId}) => HistoryEntry(
        id: id,
        profileId: profileId ?? this.profileId,
        createdAt: createdAt,
        category: category,
        score: score,
        palmScore: palmScore,
        eyeScore: eyeScore,
        usesFusion: usesFusion,
        warnings: warnings,
      );
}