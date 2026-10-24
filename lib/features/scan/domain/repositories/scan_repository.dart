import 'dart:typed_data';

import '../entities/scan_result.dart';

/// Kontrak skrining. UI/BLoC hanya mengenal ini, bukan TFLite.
abstract class ScanRepository {
  /// Muat model dan konfigurasi (sekali).
  Future<void> init();

  /// Foto utuh dari kamera (bytes JPEG/PNG). Minimal salah satu tidak null.
  /// Foto dipotong sesuai GuideGeometry sebelum masuk model.
  Future<ScanResult> classify({Uint8List? palmPhoto, Uint8List? eyePhoto});

  void dispose();
}