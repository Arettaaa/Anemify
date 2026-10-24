import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Input model Anemify: tensor RGBA 224x224 (urutan HWC), RGB 0..255, alpha 0 atau 255.
/// Harus identik dengan load_roi() + to_rgba() di notebook v3.
class RoiTensor {
  const RoiTensor({required this.data, required this.roiFraction});

  /// Panjang 224 * 224 * 4.
  final Float32List data;

  /// Porsi piksel ROI di frame 224x224 (0..1), untuk cek kualitas.
  final double roiFraction;
}

class RoiPreprocessor {
  static const int size = 224;
  static const int _alphaThreshold = 12; // Python: alpha > 12
  static const int _minRoiPixels = 20; // Python: mask.sum() < 20 -> tidak valid

  /// Dari file PNG/JPG. Orientasi EXIF (foto kamera) diluruskan dulu.
  /// Alpha dibaca langsung per piksel supaya transparansi PNG (termasuk PNG berpalet) tidak hilang.
  RoiTensor? fromEncoded(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final im = img.bakeOrientation(decoded);
    final w = im.width, h = im.height;
    final rgba = Uint8List(w * h * 4);
    for (final p in im) {
      final i = (p.y * w + p.x) * 4;
      rgba[i] = (p.rNormalized * 255).round();
      rgba[i + 1] = (p.gNormalized * 255).round();
      rgba[i + 2] = (p.bNormalized * 255).round();
      rgba[i + 3] = (p.aNormalized * 255).round(); // tanpa kanal alpha -> 255
    }
    return fromRgba(rgba, w, h);
  }

  /// [rgba]: w*h*4 byte. Piksel dengan alpha > 12 dianggap ROI.
  RoiTensor? fromRgba(Uint8List rgba, int w, int h) {
    // 1. Mask, kotak pembatas ROI, dan jumlah warna ROI
    var n = 0;
    var x0 = w, y0 = h, x1 = -1, y1 = -1;
    var sr = 0.0, sg = 0.0, sb = 0.0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = (y * w + x) * 4;
        if (rgba[i + 3] > _alphaThreshold) {
          n++;
          sr += rgba[i];
          sg += rgba[i + 1];
          sb += rgba[i + 2];
          if (x < x0) x0 = x;
          if (x > x1) x1 = x;
          if (y < y0) y0 = y;
          if (y > y1) y1 = y;
        }
      }
    }
    if (n < _minRoiPixels) return null;
    final fill = [(sr / n).floor(), (sg / n).floor(), (sb / n).floor()];

    // 2. Potong ke kotak pembatas, isi latar dengan warna rata-rata ROI
    final cw = x1 - x0 + 1, ch = y1 - y0 + 1;
    final rgb = Uint8List(cw * ch * 3);
    final mask = Uint8List(cw * ch);
    for (var y = 0; y < ch; y++) {
      for (var x = 0; x < cw; x++) {
        final si = ((y + y0) * w + (x + x0)) * 4;
        final di = y * cw + x;
        final inRoi = rgba[si + 3] > _alphaThreshold;
        for (var c = 0; c < 3; c++) {
          rgb[di * 3 + c] = inRoi ? rgba[si + c] : fill[c];
        }
        mask[di] = inRoi ? 255 : 0;
      }
    }

    // 3. Resize ke 224x224 dengan cara PIL BILINEAR
    final rgb224 = _resize(rgb, cw, ch, 3, size, size);
    final mask224 = _resize(mask, cw, ch, 1, size, size);

    // 4. Susun tensor RGBA float
    final out = Float32List(size * size * 4);
    var roiCount = 0;
    for (var p = 0; p < size * size; p++) {
      out[p * 4] = rgb224[p * 3].toDouble();
      out[p * 4 + 1] = rgb224[p * 3 + 1].toDouble();
      out[p * 4 + 2] = rgb224[p * 3 + 2].toDouble();
      final inRoi = mask224[p] > 127;
      out[p * 4 + 3] = inRoi ? 255.0 : 0.0;
      if (inRoi) roiCount++;
    }
    return RoiTensor(data: out, roiFraction: roiCount / (size * size));
  }

  // ---- Resize setara PIL Image.BILINEAR (filter segitiga, antialias saat mengecil) ----

  static List<({int start, Float64List weights})> _coeffs(int inSize, int outSize) {
    final scale = inSize / outSize;
    final fscale = scale > 1.0 ? scale : 1.0;
    final support = fscale; // support bilinear = 1.0 * fscale
    final result = <({int start, Float64List weights})>[];
    for (var x = 0; x < outSize; x++) {
      final center = (x + 0.5) * scale;
      var xmin = (center - support + 0.5).toInt();
      if (xmin < 0) xmin = 0;
      var xmax = (center + support + 0.5).toInt();
      if (xmax > inSize) xmax = inSize;
      final wts = Float64List(xmax - xmin);
      var sum = 0.0;
      for (var i = xmin; i < xmax; i++) {
        final t = ((i - center + 0.5) / fscale).abs();
        final v = t < 1.0 ? 1.0 - t : 0.0;
        wts[i - xmin] = v;
        sum += v;
      }
      if (sum > 0) {
        for (var k = 0; k < wts.length; k++) {
          wts[k] /= sum;
        }
      }
      result.add((start: xmin, weights: wts));
    }
    return result;
  }

  /// Horizontal dulu, lalu vertikal; dibulatkan ke 0..255 setiap tahap (seperti PIL).
  static Uint8List _resize(Uint8List src, int w, int h, int ch, int ow, int oh) {
    var cur = src;
    var curW = w;
    if (ow != w) {
      final cx = _coeffs(w, ow);
      final out = Uint8List(h * ow * ch);
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < ow; x++) {
          final c = cx[x];
          for (var k = 0; k < ch; k++) {
            var acc = 0.0;
            for (var j = 0; j < c.weights.length; j++) {
              acc += c.weights[j] * cur[(y * w + c.start + j) * ch + k];
            }
            out[(y * ow + x) * ch + k] = _clip8(acc);
          }
        }
      }
      cur = out;
      curW = ow;
    }
    if (oh != h) {
      final cy = _coeffs(h, oh);
      final out = Uint8List(oh * curW * ch);
      for (var y = 0; y < oh; y++) {
        final c = cy[y];
        for (var x = 0; x < curW; x++) {
          for (var k = 0; k < ch; k++) {
            var acc = 0.0;
            for (var j = 0; j < c.weights.length; j++) {
              acc += c.weights[j] * cur[((c.start + j) * curW + x) * ch + k];
            }
            out[(y * curW + x) * ch + k] = _clip8(acc);
          }
        }
      }
      cur = out;
    }
    return cur;
  }

  static int _clip8(double v) {
    final r = (v + 0.5).floor();
    return r < 0 ? 0 : (r > 255 ? 255 : r);
  }
}