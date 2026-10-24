import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/datasources/tflite_data_source.dart';
import '../../data/models/fusion_config.dart';
import '../../data/preprocessing/roi_preprocessor.dart';

/// Halaman sementara: membandingkan skor di HP dengan skor acuan Colab.
class DebugParityPage extends StatefulWidget {
  const DebugParityPage({super.key});

  @override
  State<DebugParityPage> createState() => _DebugParityPageState();
}

class _Row {
  _Row(this.file, this.kind, this.score, this.roi, this.ms);
  final String file;
  final String kind;
  final double? score;
  final double roi;
  final int ms;
}

class _DebugParityPageState extends State<DebugParityPage> {
  // Skor acuan dari Colab (sel 3A)
  static const _colab = {
    'konj_1.png': 0.8533, 'konj_2.png': 0.8248, 'konj_3.png': 0.2041,
    'palm_1.png': 0.9479, 'palm_2.png': 0.9933, 'palm_3.png': 0.0101,
  };

  final _rows = <_Row>[];
  String _status = 'Memuat model...';
  String? _fusionText;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      final cfg = FusionConfig.fromJsonString(
          await rootBundle.loadString('assets/config/fusion_config.json'));
      final ds = TfliteDataSource();
      await ds.load(palmFile: cfg.palmModelFile, konjFile: cfg.konjModelFile);

      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final files = manifest
          .listAssets()
          .where((p) => p.startsWith('assets/debug/'))
          .toList()
        ..sort();

      final pre = RoiPreprocessor();
      final scores = <String, double>{};
      for (final path in files) {
        final name = path.split('/').last;
        final isPalm = name.startsWith('palm');
        final sw = Stopwatch()..start();
        final bytes = (await rootBundle.load(path)).buffer.asUint8List();
        final t = pre.fromEncoded(bytes);
        final s = t == null ? null : (isPalm ? ds.predictPalm(t) : ds.predictKonj(t));
        sw.stop();
        if (s != null) scores[name] = s;
        setState(() => _rows.add(
            _Row(name, isPalm ? 'palm' : 'konj', s, t?.roiFraction ?? 0, sw.elapsedMilliseconds)));
      }

      final pp = scores['palm_1.png'], pk = scores['konj_1.png'];
      if (pp != null && pk != null) {
        final f = cfg.fuse(pp, pk);
        _fusionText = 'Contoh PDR (palm_1 + konj_1): ${f.toStringAsFixed(4)} '
            '-> ${cfg.fused.categorize(f).key}';
      }
      ds.close();
      setState(() => _status = 'Selesai (${files.length} file)');
    } catch (e, st) {
      setState(() => _status = 'ERROR: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cek paritas model')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_status),
          const SizedBox(height: 8),
          for (final r in _rows) _tile(r),
          if (_fusionText != null)
            Padding(padding: const EdgeInsets.only(top: 12), child: Text(_fusionText!)),
        ],
      ),
    );
  }

  Widget _tile(_Row r) {
    final ref = _colab[r.file];
    final diff = (r.score != null && ref != null) ? (r.score! - ref).abs() : null;
    final ok = diff != null && diff < 0.02;
    return Card(
      child: ListTile(
        leading: Icon(ok ? Icons.check_circle : Icons.error,
            color: ok ? Colors.green : Colors.red),
        title: Text('${r.file} (${r.kind})'),
        subtitle: Text(
          'HP ${r.score?.toStringAsFixed(4) ?? '-'} | Colab ${ref?.toStringAsFixed(4) ?? '-'}'
          ' | selisih ${diff?.toStringAsFixed(4) ?? '-'}\n'
          'porsi ROI ${r.roi.toStringAsFixed(3)} | ${r.ms} ms',
        ),
      ),
    );
  }
}