enum ScanFailureType { noPhoto, invalidImage, roiTooSmall, modelNotReady }

/// Kegagalan skrining yang bisa ditampilkan UI dengan pesan yang jelas.
class ScanFailure implements Exception {
  const ScanFailure(this.type);

  final ScanFailureType type;

  @override
  String toString() => 'ScanFailure($type)';
}