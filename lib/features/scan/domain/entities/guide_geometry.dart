import 'dart:math' as math;

/// Kotak dalam piksel.
typedef PixelRect = ({int left, int top, int width, int height});

/// SATU-SATUNYA definisi bentuk panduan kamera.
/// - UI memakainya untuk MENGGAMBAR overlay di atas preview kamera.
/// - Logika memakainya untuk MEMOTONG foto.
/// Syarat: preview ditampilkan utuh (tidak di-crop/zoom) dengan rasio yang sama dengan foto,
/// sehingga koordinat relatif 0..1 di layar = koordinat relatif 0..1 di foto.
class GuideGeometry {
  const GuideGeometry._();

  // Palm: persegi di tengah frame. Sisi = fraksi dari sisi terpendek frame.
  static const double palmSide = 0.6;

  // Mata: kotak panduan berisi sabit tipis (konjungtiva kelopak bawah).
  static const double eyeBoxWidth = 0.45; // fraksi lebar frame
  static const double eyeBoxAspect = 0.22; // tinggi kotak = 0.22 x lebar kotak (= kedalaman lengkung bawah)
  static const double eyeBoxCenterY = 0.5; // pusat vertikal kotak (fraksi tinggi frame)

  /// Ketebalan sabit di tengah, sebagai fraksi tinggi kotak.
  static const double eyeThickness = 0.45;

  static PixelRect palmRect(int w, int h) {
    final side = (palmSide * math.min(w, h)).round();
    return (
      left: ((w - side) / 2).round(),
      top: ((h - side) / 2).round(),
      width: side,
      height: side,
    );
  }

  static PixelRect eyeRect(int w, int h) {
    final bw = (eyeBoxWidth * w).round();
    final bh = math.min((eyeBoxAspect * bw).round(), h);
    final top = (eyeBoxCenterY * h - bh / 2).round().clamp(0, h - bh).toInt();
    return (left: ((w - bw) / 2).round(), top: top, width: bw, height: bh);
  }

  /// Sabit = daerah di antara dua parabola yang bertemu di ujung kiri (0,0) dan kanan (1,0),
  /// sehingga ujungnya lancip. Koordinat kotak: u ke kanan, v ke bawah, 0..1.
  /// Batas bawah: puncak di v = 1 (tengah bawah kotak).
  static double eyeLowerV(double u) => 1 - (2 * u - 1) * (2 * u - 1);

  /// Batas atas: parabola yang lebih landai.
  static double eyeUpperV(double u) => (1 - eyeThickness) * eyeLowerV(u);

  /// (u, v) relatif terhadap kotak mata (0..1). True = termasuk ROI.
  static bool inCrescent(double u, double v) => v > eyeUpperV(u) && v <= eyeLowerV(u);
}