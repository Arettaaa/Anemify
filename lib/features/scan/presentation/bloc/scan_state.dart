import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/entities/quality_metrics.dart';
import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';

enum ScanStatus {
  initial,
  loadingModel,
  ready,

  /// Foto baru sedang dicek kualitas & objeknya (segera setelah diambil).
  checkingPhoto,
  processing,
  success,
  failure,
}

class ScanState extends Equatable {
  const ScanState({
    this.status = ScanStatus.initial,
    this.modelReady = false,
    this.palmPhoto,
    this.eyePhoto,
    this.result,
    this.failure,
    this.failedPhoto,
    this.failedMetrics,
    this.photoWarnings = const {},
  });

  final ScanStatus status;
  final bool modelReady;

  /// Foto yang SUDAH lolos cek. Foto yang ditolak tidak pernah disimpan di sini.
  final Uint8List? palmPhoto;
  final Uint8List? eyePhoto;
  final ScanResult? result; // terisi saat status == success
  final ScanFailureType? failure; // terisi saat status == failure
  final ScanPhotoKind? failedPhoto; // foto yang perlu diulang (bila spesifik)
  final QualityMetrics? failedMetrics; // metrik foto yang ditolak (debug)

  /// Peringatan ringan per foto yang diterima (warna kusam, kurang khas).
  final Map<ScanPhotoKind, List<ScanWarning>> photoWarnings;

  bool get hasPhoto => palmPhoto != null || eyePhoto != null;
  bool get isBusy => status == ScanStatus.checkingPhoto || status == ScanStatus.processing;
  bool get canSubmit => modelReady && hasPhoto && !isBusy;

  /// Perubahan biasa: hasil dan error lama selalu dibuang.
  ScanState copyWith({
    ScanStatus? status,
    bool? modelReady,
    Uint8List? palmPhoto,
    Uint8List? eyePhoto,
    Map<ScanPhotoKind, List<ScanWarning>>? photoWarnings,
  }) =>
      ScanState(
        status: status ?? this.status,
        modelReady: modelReady ?? this.modelReady,
        palmPhoto: palmPhoto ?? this.palmPhoto,
        eyePhoto: eyePhoto ?? this.eyePhoto,
        photoWarnings: photoWarnings ?? this.photoWarnings,
      );

  ScanState withResult(ScanResult r) => ScanState(
        status: ScanStatus.success,
        modelReady: modelReady,
        palmPhoto: palmPhoto,
        eyePhoto: eyePhoto,
        photoWarnings: photoWarnings,
        result: r,
      );

  ScanState withFailure(ScanFailureType f, {ScanPhotoKind? photo, QualityMetrics? metrics}) =>
      ScanState(
        status: ScanStatus.failure,
        modelReady: modelReady,
        palmPhoto: palmPhoto,
        eyePhoto: eyePhoto,
        photoWarnings: photoWarnings,
        failure: f,
        failedPhoto: photo,
        failedMetrics: metrics,
      );

  @override
  List<Object?> get props => [
        status,
        modelReady,
        palmPhoto,
        eyePhoto,
        result,
        failure,
        failedPhoto,
        failedMetrics,
        photoWarnings,
      ];
}
