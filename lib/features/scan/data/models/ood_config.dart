import 'dart:convert';

typedef OodVector = ({String file, double palm, double konj});

/// ok = mirip data latih; unusual = zona abu-abu (lolos + peringatan); foreign = ditolak.
enum OodLevel { ok, unusual, foreign }

/// Isi ood_config.json (notebook Anemify_OOD + reject_thresholds hasil uji HP).
class OodConfig {
  const OodConfig({
    required this.modelFile,
    required this.palmMax,
    required this.konjMax,
    required this.palmReject,
    required this.konjReject,
    this.testVectors = const [],
  });

  factory OodConfig.fromJsonString(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final order = ((j['output'] as Map<String, dynamic>)['order'] as List).cast<String>();
    if (order.length != 2 || order[0] != 'palm' || order[1] != 'konjungtiva') {
      throw FormatException('Urutan output OOD tidak dikenal: $order');
    }
    final th = j['thresholds'] as Map<String, dynamic>;
    final rej = (j['reject_thresholds'] as Map<String, dynamic>?) ?? const {};
    final palmMax = (th['palm'] as num).toDouble();
    final konjMax = (th['konjungtiva'] as num).toDouble();
    return OodConfig(
      modelFile: j['model_file'] as String,
      palmMax: palmMax,
      konjMax: konjMax,
      palmReject: (rej['palm'] as num?)?.toDouble() ?? palmMax,
      konjReject: (rej['konjungtiva'] as num?)?.toDouble() ?? konjMax,
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

  /// Ambang dari dataset (persentil 99): di bawah ini = lolos normal.
  final double palmMax;
  final double konjMax;

  /// Batas tolak: di atas ini = bukan telapak/konjungtiva. Sama dengan ambang = mode ketat.
  final double palmReject;
  final double konjReject;
  final List<OodVector> testVectors;

  double maxFor({required bool isEye}) => isEye ? konjMax : palmMax;

  /// true = foto cukup mirip data latih (menurut ambang dataset).
  bool isTarget(double distance, {required bool isEye}) => distance <= maxFor(isEye: isEye);

  OodLevel level(double distance, {required bool isEye}) {
    if (distance > (isEye ? konjReject : palmReject)) return OodLevel.foreign;
    if (distance > maxFor(isEye: isEye)) return OodLevel.unusual;
    return OodLevel.ok;
  }
}