import 'dart:typed_data';

import 'package:anemify/features/scan/data/preprocessing/roi_preprocessor.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _synthetic(int w, int h) {
  final b = Uint8List(w * h * 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      b[i] = (x * 3 + y) % 256;
      b[i + 1] = (x + y * 2) % 256;
      b[i + 2] = (x * y) % 256;
      final d2 = (x - 160) * (x - 160) + (y + 100) * (y + 100);
      b[i + 3] = (d2 >= 160 * 160 && d2 <= 250 * 250) ? 255 : 0;
    }
  }
  return b;
}

void main() {
  test('preprocessing sama dengan load_roi() di notebook', () {
    const s = RoiPreprocessor.size;
    final t = RoiPreprocessor().fromRgba(_synthetic(320, 180), 320, 180)!;
    expect(t.data.length, s * s * 4);

    double mean(int c) {
      var sum = 0.0;
      for (var p = 0; p < s * s; p++) {
        sum += t.data[p * 4 + c];
      }
      return sum / (s * s);
    }

    // Nilai acuan dari notebook (PIL)
    expect(mean(0), closeTo(129.079, 0.05));
    expect(mean(1), closeTo(132.287, 0.05));
    expect(mean(2), closeTo(124.476, 0.05));

    var roi = 0;
    for (var p = 0; p < s * s; p++) {
      if (t.data[p * 4 + 3] == 255) roi++;
    }
    expect(roi, closeTo(32972, 50));

    void px(int y, int x, List<int> e) {
      for (var c = 0; c < 4; c++) {
        expect(t.data[(y * s + x) * 4 + c], closeTo(e[c], c == 3 ? 0 : 1),
            reason: 'piksel ($y,$x) kanal $c');
      }
    }

    px(0, 0, [1, 0, 0, 255]);
    px(10, 112, [129, 132, 124, 0]);
    px(112, 112, [44, 55, 155, 255]);
    px(200, 30, [129, 132, 124, 0]);
    px(223, 223, [129, 132, 124, 0]);
  });
}