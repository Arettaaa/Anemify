import 'package:anemify/features/scan/data/preprocessing/guide_cropper.dart';
import 'package:anemify/features/scan/data/preprocessing/roi_preprocessor.dart';
import 'package:anemify/features/scan/domain/entities/guide_geometry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('kotak panduan sesuai nilai acuan', () {
    expect(GuideGeometry.palmRect(400, 600), (left: 80, top: 180, width: 240, height: 240));
    expect(GuideGeometry.eyeRect(400, 600), (left: 110, top: 280, width: 180, height: 40));
    expect(GuideGeometry.palmRect(3000, 4000), (left: 600, top: 1100, width: 1800, height: 1800));
  });

  test('bentuk sabit (dua parabola, ujung lancip)', () {
    expect(GuideGeometry.inCrescent(0.5, 0.9), isTrue); // tengah bawah = ROI
    expect(GuideGeometry.inCrescent(0.5, 0.7), isTrue);
    expect(GuideGeometry.inCrescent(0.5, 0.3), isFalse); // di atas sabit
    expect(GuideGeometry.inCrescent(0.05, 0.15), isTrue); // dekat ujung, masih di dalam
    expect(GuideGeometry.inCrescent(0.05, 0.3), isFalse); // dekat ujung, sudah di luar
  });

  test('foto mata -> potongan sabit -> tensor', () {
    final photo = img.Image(width: 400, height: 600);
    img.fill(photo, color: img.ColorRgb8(200, 80, 90));
    final crop = GuideCropper.eye(photo);
    expect(crop.width, 180);
    expect(crop.height, 40);
    var roi = 0;
    for (var i = 3; i < crop.rgba.length; i += 4) {
      if (crop.rgba[i] == 255) roi++;
    }
    expect(roi, closeTo(2150, 10)); // ~30% dari kotak
    final t = RoiPreprocessor().fromRgba(crop.rgba, crop.width, crop.height)!;
    expect(t.roiFraction, closeTo(0.313, 0.01));
    expect([t.data[0], t.data[1], t.data[2]], [200, 80, 90]);
  });

  test('foto palm -> persegi penuh', () {
    final crop = GuideCropper.palm(img.Image(width: 400, height: 600));
    expect(crop.width, 240);
    expect(crop.height, 240);
    final t = RoiPreprocessor().fromRgba(crop.rgba, crop.width, crop.height)!;
    expect(t.roiFraction, 1.0);
  });
}