import 'dart:typed_data';

import '../entities/quality_metrics.dart';
import '../entities/scan_result.dart';

/// Hasil pemeriksaan satu foto (lolos cek kualitas dan cek objek).
class PhotoCheck {
  const PhotoCheck({required this.metrics, this.warnings = const []});

  final QualityMetrics metrics;

  /// Peringatan ringan (warna kusam, foto kurang khas); foto tetap diterima.
  final List<ScanWarning> warnings;
}

/// Kontrak skrining. UI/BLoC hanya mengenal ini, bukan TFLite.
abstract class ScanRepository {
  /// Muat model dan konfigurasi (sekali).
  Future<void> init();

  /// Periksa satu foto segera setelah diambil: gelap/terang/buram/bukan objek.
  /// Melempar [ScanFailure] bila foto harus diulang; selain itu foto diterima.
  Future<PhotoCheck> checkPhoto({required Uint8List photo, required bool isEye});

  /// Foto utuh dari kamera (bytes JPEG/PNG). Minimal salah satu tidak null.
  /// Foto dipotong sesuai GuideGeometry sebelum masuk model.
  Future<ScanResult> classify({Uint8List? palmPhoto, Uint8List? eyePhoto});

  void dispose();
}
