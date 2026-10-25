import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../data/datasources/tflite_data_source.dart';
import '../../data/models/ood_config.dart';
import '../../data/preprocessing/roi_preprocessor.dart';

/// Halaman DEBUG: jarak OOD di HP vs nilai acuan Colab (ood_config.json -> test_vectors).
class DebugOodPage extends StatefulWidget {
  const DebugOodPage({super.key});

  @override
  State<DebugOodPage> createState() => _DebugOodPageState();
}

class _DebugOodPageState extends State<DebugOodPage> {
  final _rows = <String>[];
  String _status = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final ds = TfliteDataSource();
    try {
      final cfg = OodConfig.fromJsonString(await rootBundle.loadString('assets/config/ood_config.json'));
      await ds.loadOod(cfg.modelFile);
      var allOk = true;
      for (final v in cfg.testVectors) {
        final bytes = (await rootBundle.load('assets/debug/${v.file}')).buffer.asUint8List();
        final t = RoiPreprocessor().fromEncoded(bytes);
        if (t == null) {
          _rows.add('${v.file}: gagal diproses');
          allOk = false;
          continue;
        }
        final d = ds.predictOod(t);
        final rp = (d.palm - v.palm).abs() / v.palm, rk = (d.konj - v.konj).abs() / v.konj;
        final ok = rp < 0.01 && rk < 0.01;
        allOk &= ok;
        _rows.add('${ok ? '✅' : '❌'} ${v.file}\n'
            '   palm HP ${d.palm.toStringAsFixed(2)} | Colab ${v.palm.toStringAsFixed(2)}\n'
            '   konj HP ${d.konj.toStringAsFixed(2)} | Colab ${v.konj.toStringAsFixed(2)}');
      }
      _status = allOk ? 'Semua cocok (selisih < 1%)' : 'Ada yang tidak cocok';
    } catch (e) {
      _status = 'Error: $e';
    } finally {
      ds.close();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Paritas OOD (debug)')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(_status, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final r in _rows) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(r)),
          ],
        ),
      );
}