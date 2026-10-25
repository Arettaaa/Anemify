import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/quality_metrics.dart';
import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/tflite_data_source.dart';
import '../models/fusion_config.dart';
import '../models/quality_config.dart';
import '../models/risk_decider.dart';
import '../preprocessing/guide_cropper.dart';
import '../preprocessing/quality_checker.dart';
import '../preprocessing/roi_preprocessor.dart';

/// Dijalankan di isolate terpisah: decode foto besar + potong + resize itu berat.
/// Harus fungsi top-level supaya bisa dipakai compute().
RoiTensor prepareTensorJob(({Uint8List photo, bool isEye}) job) {
  final kind = job.isEye ? ScanPhotoKind.eye : ScanPhotoKind.palm;
  final im = RoiPreprocessor.decodeOriented(job.photo);
  if (im == null) throw ScanFailure(ScanFailureType.invalidImage, photo: kind);
  final c = job.isEye ? GuideCropper.eye(im) : GuideCropper.palm(im);
  final t = RoiPreprocessor().fromRgba(c.rgba, c.width, c.height);
  if (t == null) throw ScanFailure(ScanFailureType.roiTooSmall, photo: kind);
  return t;
}

class ScanRepositoryImpl implements ScanRepository {
  ScanRepositoryImpl({TfliteDataSource? models}) : _models = models ?? TfliteDataSource();

  final TfliteDataSource _models;
  QualityChecker? _quality;
  RiskDecider? _decider; // diisi paling akhir = tanda semua siap

  @override
  Future<void> init() async {
    if (_decider != null) return;
    final cfg = FusionConfig.fromJsonString(
        await rootBundle.loadString('assets/config/fusion_config.json'));
    final qcfg = QualityConfig.fromJsonString(
        await rootBundle.loadString('assets/config/quality_config.json'));
    await _models.load(palmFile: cfg.palmModelFile, konjFile: cfg.konjModelFile);
    _quality = QualityChecker(qcfg);
    _decider = RiskDecider(cfg);
  }

  @override
  Future<ScanResult> classify({Uint8List? palmPhoto, Uint8List? eyePhoto}) async {
    final decider = _decider, quality = _quality;
    if (decider == null || quality == null) {
      throw const ScanFailure(ScanFailureType.modelNotReady);
    }
    final extra = <ScanWarning>[];
    double? palm, eye;
    QualityMetrics? pq, eq;
    if (palmPhoto != null) {
      final t = await compute(prepareTensorJob, (photo: palmPhoto, isEye: false));
      pq = QualityChecker.measure(t);
      extra.addAll(_verify(quality, pq, ScanPhotoKind.palm));
      palm = _models.predictPalm(t);
    }
    if (eyePhoto != null) {
      final t = await compute(prepareTensorJob, (photo: eyePhoto, isEye: true));
      eq = QualityChecker.measure(t);
      extra.addAll(_verify(quality, eq, ScanPhotoKind.eye));
      eye = _models.predictKonj(t);
    }
    return decider
        .decide(palm: palm, eye: eye)
        .withExtra(warnings: extra, palmQuality: pq, eyeQuality: eq);
  }

  List<ScanWarning> _verify(QualityChecker c, QualityMetrics q, ScanPhotoKind kind) {
    final v = c.check(q, isEye: kind == ScanPhotoKind.eye);
    if (v.failure != null) throw ScanFailure(v.failure!, photo: kind);
    return v.warnings;
  }

  @override
  void dispose() {
    _models.close();
    _quality = null;
    _decider = null;
  }
}