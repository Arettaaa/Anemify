import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/tflite_data_source.dart';
import '../models/fusion_config.dart';
import '../models/risk_decider.dart';
import '../preprocessing/guide_cropper.dart';
import '../preprocessing/roi_preprocessor.dart';

class ScanRepositoryImpl implements ScanRepository {
  ScanRepositoryImpl({TfliteDataSource? models, RoiPreprocessor? preprocessor})
      : _models = models ?? TfliteDataSource(),
        _pre = preprocessor ?? RoiPreprocessor();

  final TfliteDataSource _models;
  final RoiPreprocessor _pre;
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
    final palm =
        palmPhoto == null ? null : _models.predictPalm(_tensor(palmPhoto, GuideCropper.palm));
    final eye =
        eyePhoto == null ? null : _models.predictKonj(_tensor(eyePhoto, GuideCropper.eye));
    return decider.decide(palm: palm, eye: eye);
  }

  RoiTensor _tensor(Uint8List photo, RgbaCrop Function(img.Image) crop) {
    final im = RoiPreprocessor.decodeOriented(photo);
    if (im == null) throw const ScanFailure(ScanFailureType.invalidImage);
    final c = crop(im);
    final t = _pre.fromRgba(c.rgba, c.width, c.height);
    if (t == null) throw const ScanFailure(ScanFailureType.roiTooSmall);
    return t;
  }

  @override
  void dispose() => _models.close();
}