import 'dart:convert';

typedef OodVector = ({String file, double palm, double konj});

/// Isi ood_config.json (notebook Anemify_OOD): ambang jarak Mahalanobis per modalitas.
class OodConfig {
  const OodConfig({
    required this.modelFile,
    required this.palmMax,
    required this.konjMax,
    this.testVectors = const [],
  });

  factory OodConfig.fromJsonString(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final order = ((j['output'] as Map<String, dynamic>)['order'] as List).cast<String>();
    if (order.length != 2 || order[0] != 'palm' || order[1] != 'konjungtiva') {
      throw FormatException('Urutan output OOD tidak dikenal: $order');
    }
    final th = j['thresholds'] as Map<String, dynamic>;
    return OodConfig(
      modelFile: j['model_file'] as String,
      palmMax: (th['palm'] as num).toDouble(),
      konjMax: (th['konjungtiva'] as num).toDouble(),
      testVectors: [
        for (final v in (j['test_vectors'] as List? ?? const []))
          (
            file: v['file'] as String,
            palm: (v['palm'] as num).toDouble(),
            konj: (v['konjungtiva'] as num).toDouble(),
          ),
      ],
    );
  }

  final String modelFile;
  final double palmMax;
  final double konjMax;
  final List<OodVector> testVectors;

  double maxFor({required bool isEye}) => isEye ? konjMax : palmMax;

  /// true = foto cukup mirip data latih (telapak/konjungtiva dikenali).
  bool isTarget(double distance, {required bool isEye}) => distance <= maxFor(isEye: isEye);
}