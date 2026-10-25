import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/quality_metrics.dart';
import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/tflite_data_source.dart';
import '../models/fusion_config.dart';
import '../models/ood_config.dart';
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
  OodConfig? _ood;
  RiskDecider? _decider; // diisi paling akhir = tanda semua siap

  @override
  Future<void> init() async {
    if (_decider != null) return;
    final cfg = FusionConfig.fromJsonString(
        await rootBundle.loadString('assets/config/fusion_config.json'));
    final qcfg = QualityConfig.fromJsonString(
        await rootBundle.loadString('assets/config/quality_config.json'));
    final ocfg = OodConfig.fromJsonString(
        await rootBundle.loadString('assets/config/ood_config.json'));
    await _models.load(palmFile: cfg.palmModelFile, konjFile: cfg.konjModelFile);
    await _models.loadOod(ocfg.modelFile);
    _quality = QualityChecker(qcfg);
    _ood = ocfg;
    _decider = RiskDecider(cfg);
  }

  @override
  Future<ScanResult> classify({Uint8List? palmPhoto, Uint8List? eyePhoto}) async {
    final decider = _decider, quality = _quality, ood = _ood;
    if (decider == null || quality == null || ood == null) {
      throw const ScanFailure(ScanFailureType.modelNotReady);
    }
    final extra = <ScanWarning>[];
    double? palm, eye;
    QualityMetrics? pq, eq;
    if (palmPhoto != null) {
      final t = await compute(prepareTensorJob, (photo: palmPhoto, isEye: false));
      pq = _verify(quality, ood, t, ScanPhotoKind.palm, extra);
      palm = _models.predictPalm(t);
    }
    if (eyePhoto != null) {
      final t = await compute(prepareTensorJob, (photo: eyePhoto, isEye: true));
      eq = _verify(quality, ood, t, ScanPhotoKind.eye, extra);
      eye = _models.predictKonj(t);
    }
    return decider
        .decide(palm: palm, eye: eye)
        .withExtra(warnings: extra, palmQuality: pq, eyeQuality: eq);
  }

  /// Urutan: kualitas (gelap/terang/blur) -> OOD (bukan telapak/konjungtiva).
  /// Lolos -> metrik + jarak OOD dikembalikan, peringatan ditambahkan ke [extra].
  QualityMetrics _verify(
      QualityChecker c, OodConfig ood, RoiTensor t, ScanPhotoKind kind, List<ScanWarning> extra) {
    final isEye = kind == ScanPhotoKind.eye;
    var q = QualityChecker.measure(t);
    final v = c.check(q, isEye: isEye);
    if (v.failure != null) throw ScanFailure(v.failure!, photo: kind, metrics: q);
    final d = _models.predictOod(t);
    q = q.withOod(isEye ? d.konj : d.palm);
    if (!ood.isTarget(q.oodDistance!, isEye: isEye)) {
      throw ScanFailure(ScanFailureType.notTarget, photo: kind, metrics: q);
    }
    extra.addAll(v.warnings);
    return q;
  }

  @override
  void dispose() {
    _models.close();
    _quality = null;
    _ood = null;
    _decider = null;
  }
}