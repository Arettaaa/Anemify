import 'dart:typed_data';

import '../entities/scan_failure.dart';
import '../entities/scan_result.dart';
import '../repositories/scan_repository.dart';

class ClassifyAnemiaRisk {
  const ClassifyAnemiaRisk(this._repository);

  final ScanRepository _repository;

  Future<ScanResult> call({Uint8List? palmPhoto, Uint8List? eyePhoto}) {
    if (palmPhoto == null && eyePhoto == null) {
      throw const ScanFailure(ScanFailureType.noPhoto);
    }
    return _repository.classify(palmPhoto: palmPhoto, eyePhoto: eyePhoto);
  }
}