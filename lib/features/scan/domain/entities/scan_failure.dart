import 'quality_metrics.dart';

enum ScanFailureType {
  noPhoto,
  invalidImage,
  roiTooSmall,
  modelNotReady,
  tooDark,
  tooBright,
  blurry,
  notTarget,
  unknown,
}

enum ScanPhotoKind { palm, eye }

/// Kegagalan skrining yang bisa ditampilkan UI dengan pesan yang jelas.
class ScanFailure implements Exception {
  const ScanFailure(this.type, {this.photo, this.metrics});

  final ScanFailureType type;

  /// Foto mana yang bermasalah (null bila tidak spesifik).
  final ScanPhotoKind? photo;

  /// Metrik foto yang ditolak (untuk debug/kalibrasi; UI biasa tidak perlu).
  final QualityMetrics? metrics;

  @override
  String toString() => 'ScanFailure($type, $photo)';
}