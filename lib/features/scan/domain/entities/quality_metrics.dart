import 'package:equatable/equatable.dart';

/// Ukuran kualitas foto, dihitung pada ROI 224x224 (sama dengan data latih).
class QualityMetrics extends Equatable {
  const QualityMetrics({
    required this.brightness,
    required this.saturation,
    this.sharpness,
    this.sharpnessHalf,
    this.hue,
  });

  /// Luminansi rata-rata ROI, 0..255.
  final double brightness;

  /// Saturasi (HSV) rata-rata ROI, 0..1.
  final double saturation;

  /// Varians Laplacian di dalam ROI; null bila ROI terlalu kecil untuk diukur.
  final double? sharpness;

  /// Sama dengan [sharpness], tetapi pada luminansi 112x112 (rata-rata blok 2x2)
  /// sehingga lebih tahan terhadap noise sensor saat cahaya redup.
  final double? sharpnessHalf;

  /// Hue warna rata-rata ROI dalam derajat (-180..180].
  /// Merah muda/magenta < 0, merah = 0, oranye/cokelat > 0.
  final double? hue;

  @override
  List<Object?> get props => [brightness, saturation, sharpness, sharpnessHalf, hue];
}