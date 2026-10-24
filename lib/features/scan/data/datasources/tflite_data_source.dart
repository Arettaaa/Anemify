import 'package:tflite_flutter/tflite_flutter.dart';

import '../preprocessing/roi_preprocessor.dart';

/// Menjalankan dua model TFLite (palm dan konjungtiva). Input [1,224,224,4], output [1,1].
class TfliteDataSource {
  Interpreter? _palm;
  Interpreter? _konj;

  Future<void> load({required String palmFile, required String konjFile}) async {
    _palm ??= await Interpreter.fromAsset('assets/models/$palmFile',
        options: InterpreterOptions()..threads = 4);
    _konj ??= await Interpreter.fromAsset('assets/models/$konjFile',
        options: InterpreterOptions()..threads = 4);
  }

  double predictPalm(RoiTensor t) => _run(_palm!, t);
  double predictKonj(RoiTensor t) => _run(_konj!, t);

  double _run(Interpreter it, RoiTensor t) {
    const s = RoiPreprocessor.size;
    final input = t.data.reshape([1, s, s, 4]);
    final output = [List<double>.filled(1, 0)];
    it.run(input, output);
    return output[0][0];
  }

  void close() {
    _palm?.close();
    _konj?.close();
    _palm = null;
    _konj = null;
  }
}