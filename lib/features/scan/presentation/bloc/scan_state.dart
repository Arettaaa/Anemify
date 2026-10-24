import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';

enum ScanStatus { initial, loadingModel, ready, processing, success, failure }

class ScanState extends Equatable {
  const ScanState({
    this.status = ScanStatus.initial,
    this.modelReady = false,
    this.palmPhoto,
    this.eyePhoto,
    this.result,
    this.failure,
  });

  final ScanStatus status;
  final bool modelReady;
  final Uint8List? palmPhoto;
  final Uint8List? eyePhoto;
  final ScanResult? result; // terisi saat status == success
  final ScanFailureType? failure; // terisi saat status == failure

  bool get hasPhoto => palmPhoto != null || eyePhoto != null;
  bool get canSubmit => modelReady && hasPhoto && status != ScanStatus.processing;

  /// Perubahan biasa: hasil dan error lama selalu dibuang.
  ScanState copyWith({ScanStatus? status, bool? modelReady, Uint8List? palmPhoto, Uint8List? eyePhoto}) =>
      ScanState(
        status: status ?? this.status,
        modelReady: modelReady ?? this.modelReady,
        palmPhoto: palmPhoto ?? this.palmPhoto,
        eyePhoto: eyePhoto ?? this.eyePhoto,
      );

  ScanState withResult(ScanResult r) => ScanState(
      status: ScanStatus.success, modelReady: modelReady, palmPhoto: palmPhoto, eyePhoto: eyePhoto, result: r);

  ScanState withFailure(ScanFailureType f) => ScanState(
      status: ScanStatus.failure, modelReady: modelReady, palmPhoto: palmPhoto, eyePhoto: eyePhoto, failure: f);

  @override
  List<Object?> get props => [status, modelReady, palmPhoto, eyePhoto, result, failure];
}