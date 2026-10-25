import 'package:anemify/features/scan/domain/entities/risk_category.dart';
import 'package:anemify/features/scan/domain/entities/scan_result.dart';

class HistoryEntry {
  final int? id;
  final DateTime createdAt;
  final RiskCategory category;
  final double score;
  final double? palmScore;
  final double? eyeScore;
  final bool usesFusion;
  final List<ScanWarning> warnings;

  const HistoryEntry({
    this.id,
    required this.createdAt,
    required this.category,
    required this.score,
    this.palmScore,
    this.eyeScore,
    this.usesFusion = false,
    this.warnings = const [],
  });

  factory HistoryEntry.fromScanResult(ScanResult r, {DateTime? now}) => HistoryEntry(
        createdAt: now ?? DateTime.now(),
        category: r.category,
        score: r.score,
        palmScore: r.palmScore,
        eyeScore: r.eyeScore,
        usesFusion: r.usesFusion,
        warnings: r.warnings,
      );
}