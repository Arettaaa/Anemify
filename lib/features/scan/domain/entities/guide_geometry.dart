import 'dart:math' as math;

/// Kotak dalam piksel.
typedef PixelRect = ({int left, int top, int width, int height});

/// Elips dalam koordinat kotak panduan (u ke kanan, v ke bawah, 0..1).
typedef UnitEllipse = ({double cx, double cy, double rx, double ry});

/// SATU-SATUNYA definisi bentuk panduan kamera.
/// - UI memakainya untuk MENGGAMBAR overlay di atas preview kamera.
/// - Logika memakainya untuk MEMOTONG foto.
/// Syarat: preview ditampilkan utuh (tidak di-crop/zoom) dengan rasio yang sama dengan foto,
/// sehingga koordinat relatif 0..1 di layar = koordinat relatif 0..1 di foto.
class GuideGeometry {
  const GuideGeometry._();

  // Palm: persegi di tengah frame. Sisi = fraksi dari sisi terpendek frame.
  static const double palmSide = 0.6;

  // Mata: kotak panduan berisi sabit (konjungtiva kelopak bawah).
  static const double eyeBoxWidth = 0.7; // fraksi lebar frame
  static const double eyeBoxAspect = 0.45; // tinggi kotak = 0.45 x lebar kotak
  static const double eyeBoxCenterY = 0.5; // pusat vertikal kotak (fraksi tinggi frame)

  /// Sabit = di dalam elips luar DAN di luar elips dalam (dibatasi kotak).
  static const UnitEllipse eyeOuter = (cx: 0.5, cy: 0.0, rx: 0.5, ry: 1.0);
  static const UnitEllipse eyeInner = (cx: 0.5, cy: 0.0, rx: 0.44, ry: 0.62);

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

  /// (u, v) relatif terhadap kotak mata (0..1). True = termasuk ROI.
  static bool inCrescent(double u, double v) =>
      _e(eyeOuter, u, v) <= 1 && _e(eyeInner, u, v) > 1;

  static double _e(UnitEllipse o, double u, double v) {
    final a = (u - o.cx) / o.rx;
    final b = (v - o.cy) / o.ry;
    return a * a + b * b;
  }
}