enum ScanFailureType {
  noPhoto,
  invalidImage,
  roiTooSmall,
  modelNotReady,
  tooDark,
  tooBright,
  blurry,
  unknown,
}

enum ScanPhotoKind { palm, eye }

/// Kegagalan skrining yang bisa ditampilkan UI dengan pesan yang jelas.
class ScanFailure implements Exception {
  const ScanFailure(this.type, {this.photo});

  final ScanFailureType type;

  /// Foto mana yang bermasalah (null bila tidak spesifik).
  final ScanPhotoKind? photo;

  @override
  String toString() => 'ScanFailure($type, $photo)';
}