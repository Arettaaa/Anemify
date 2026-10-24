import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/tflite_data_source.dart';
import '../models/fusion_config.dart';
import '../models/risk_decider.dart';
import '../preprocessing/guide_cropper.dart';
import '../preprocessing/roi_preprocessor.dart';

/// Dijalankan di isolate terpisah: decode foto besar + potong + resize itu berat.
/// Harus fungsi top-level supaya bisa dipakai compute().
RoiTensor prepareTensorJob(({Uint8List photo, bool isEye}) job) {
  final im = RoiPreprocessor.decodeOriented(job.photo);
  if (im == null) throw const ScanFailure(ScanFailureType.invalidImage);
  final c = job.isEye ? GuideCropper.eye(im) : GuideCropper.palm(im);
  final t = RoiPreprocessor().fromRgba(c.rgba, c.width, c.height);
  if (t == null) throw const ScanFailure(ScanFailureType.roiTooSmall);
  return t;
}

class ScanRepositoryImpl implements ScanRepository {
  ScanRepositoryImpl({TfliteDataSource? models}) : _models = models ?? TfliteDataSource();

  final TfliteDataSource _models;
  RiskDecider? _decider;

  @override
  Future<void> init() async {
    if (_decider != null) return;
    final cfg = FusionConfig.fromJsonString(
        await rootBundle.loadString('assets/config/fusion_config.json'));
    await _models.load(palmFile: cfg.palmModelFile, konjFile: cfg.konjModelFile);
    _decider = RiskDecider(cfg);
  }

  @override
  Future<ScanResult> classify({Uint8List? palmPhoto, Uint8List? eyePhoto}) async {
    final decider = _decider;
    if (decider == null) throw const ScanFailure(ScanFailureType.modelNotReady);
    double? palm, eye;
    if (palmPhoto != null) {
      palm = _models.predictPalm(await compute(prepareTensorJob, (photo: palmPhoto, isEye: false)));
    }
    if (eyePhoto != null) {
      eye = _models.predictKonj(await compute(prepareTensorJob, (photo: eyePhoto, isEye: true)));
    }
    return decider.decide(palm: palm, eye: eye);
  }

  @override
  void dispose() {
    _models.close();
    _decider = null;
  }
}