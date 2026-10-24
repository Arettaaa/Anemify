import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/entities/guide_geometry.dart';
import 'roi_preprocessor.dart';

/// Potongan foto: RGBA (alpha 255 = ROI), siap masuk RoiPreprocessor.fromRgba.
typedef RgbaCrop = ({Uint8List rgba, int width, int height});

/// Memotong foto kamera sesuai GuideGeometry (bentuk yang sama dengan overlay di layar).
class GuideCropper {
  const GuideCropper._();

  /// Palm: persegi di tengah, seluruh area = ROI.
  static RgbaCrop palm(img.Image photo) {
    final r = GuideGeometry.palmRect(photo.width, photo.height);
    final c = img.copyCrop(photo, x: r.left, y: r.top, width: r.width, height: r.height);
    final rgba = RoiPreprocessor.rgbaBytes(c);
    for (var i = 3; i < rgba.length; i += 4) {
      rgba[i] = 255;
    }
    return (rgba: rgba, width: c.width, height: c.height);
  }

  /// Mata: kotak panduan; piksel di luar sabit dibuat transparan (alpha 0).
  static RgbaCrop eye(img.Image photo) {
    final r = GuideGeometry.eyeRect(photo.width, photo.height);
    final c = img.copyCrop(photo, x: r.left, y: r.top, width: r.width, height: r.height);
    final rgba = RoiPreprocessor.rgbaBytes(c);
    final w = c.width, h = c.height;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final inRoi = GuideGeometry.inCrescent((x + 0.5) / w, (y + 0.5) / h);
        rgba[(y * w + x) * 4 + 3] = inRoi ? 255 : 0;
      }
    }
    return (rgba: rgba, width: w, height: h);
  }
}