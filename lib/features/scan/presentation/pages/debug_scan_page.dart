import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;

import '../../../../core/di/injection.dart';
import '../../data/preprocessing/guide_cropper.dart';
import '../../data/preprocessing/roi_preprocessor.dart';
import '../../domain/entities/quality_metrics.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import 'debug_camera_page.dart';
import 'debug_ood_page.dart';

/// Pratinjau area yang dipotong (PNG; di luar sabit transparan). Top-level untuk compute().
Uint8List? cropPreviewJob(({Uint8List photo, bool isEye}) job) {
  final im = RoiPreprocessor.decodeOriented(job.photo);
  if (im == null) return null;
  final c = job.isEye ? GuideCropper.eye(im) : GuideCropper.palm(im);
  final out = img.Image.fromBytes(
      width: c.width, height: c.height, bytes: c.rgba.buffer, numChannels: 4);
  return img.encodePng(out);
}

/// Halaman DEBUG: uji alur skrining lengkap dengan foto kamera asli.
class DebugScanPage extends StatelessWidget {
  const DebugScanPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => sl<ScanBloc>()..add(const ScanStarted()),
        child: const _DebugScanView(),
      );
}

class _DebugScanView extends StatefulWidget {
  const _DebugScanView();

  @override
  State<_DebugScanView> createState() => _DebugScanViewState();
}

class _DebugScanViewState extends State<_DebugScanView> {
  final _sw = Stopwatch();
  Uint8List? _palmPreview;
  Uint8List? _eyePreview;

  Future<void> _take(bool isEye) async {
    final bloc = context.read<ScanBloc>();
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => DebugCameraPage(isEye: isEye)),
    );
    if (bytes == null) return;
    bloc.add(isEye ? EyePhotoCaptured(bytes) : PalmPhotoCaptured(bytes));
    final preview = await compute(cropPreviewJob, (photo: bytes, isEye: isEye));
    if (!mounted) return;
    setState(() {
      if (isEye) {
        _eyePreview = preview;
      } else {
        _palmPreview = preview;
      }
    });
  }

  void _submit() {
    _sw
      ..reset()
      ..start();
    context.read<ScanBloc>().add(const ScanSubmitted());
  }

  void _reset() {
    setState(() {
      _palmPreview = null;
      _eyePreview = null;
    });
    context.read<ScanBloc>().add(const ScanReset());
  }

  String _q(QualityMetrics q) => 'terang ${q.brightness.toStringAsFixed(1)} | '
      'saturasi ${q.saturation.toStringAsFixed(3)} | '
      'tajam ${q.sharpness?.toStringAsFixed(1) ?? '-'} | '
      'tajam½ ${q.sharpnessHalf?.toStringAsFixed(1) ?? '-'} | '
      'hue ${q.hue?.toStringAsFixed(1) ?? '-'}° | '
      'OOD ${q.oodDistance?.toStringAsFixed(1) ?? '-'} | '
      'OOD cermin ${q.oodDistanceFlipped?.toStringAsFixed(1) ?? '-'}';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanBloc, ScanState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (_, s) {
        if (s.status == ScanStatus.success || s.status == ScanStatus.failure) _sw.stop();
      },
      builder: (context, s) {
        final r = s.result;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Uji skrining (debug)'),
            actions: [
              IconButton(
                icon: const Icon(Icons.fact_check),
                tooltip: 'Paritas OOD',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const DebugOodPage())),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Status: ${s.status.name}'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _PhotoBox('Telapak', _palmPreview, () => _take(false))),
                const SizedBox(width: 12),
                Expanded(child: _PhotoBox('Mata', _eyePreview, () => _take(true))),
              ]),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: s.canSubmit ? _submit : null,
                child: Text(s.status == ScanStatus.processing ? 'Menganalisis...' : 'Analisis'),
              ),
              TextButton(onPressed: _reset, child: const Text('Reset')),
              if (r != null) ...[
                Text('Kategori: ${r.category.key}', style: Theme.of(context).textTheme.titleLarge),
                Text('Skor penentu: ${r.score.toStringAsFixed(4)}'
                    '${r.usesFusion ? ' (gabungan PDR)' : ''}'),
                if (r.palmScore != null) Text('Skor palm: ${r.palmScore!.toStringAsFixed(4)}'),
                if (r.eyeScore != null) Text('Skor mata: ${r.eyeScore!.toStringAsFixed(4)}'),
                if (r.warnings.isNotEmpty)
                  Text('Peringatan: ${r.warnings.map((w) => w.name).join(', ')}'),
                Text('Waktu analisis: ${_sw.elapsedMilliseconds} ms'),
                if (r.palmQuality != null) Text('Kualitas palm: ${_q(r.palmQuality!)}'),
                if (r.eyeQuality != null) Text('Kualitas mata: ${_q(r.eyeQuality!)}'),
              ],
              if (s.status == ScanStatus.failure) ...[
                Text('Gagal: ${s.failure?.name} (foto: ${s.failedPhoto?.name ?? '-'})',
                    style: const TextStyle(color: Colors.red)),
                if (s.failedMetrics != null) Text('Metrik foto gagal: ${_q(s.failedMetrics!)}'),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox(this.label, this.preview, this.onTap);
  final String label;
  final Uint8List? preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: preview == null
                ? Center(child: Text('Ketuk untuk foto\n$label', textAlign: TextAlign.center))
                : Image.memory(preview!, fit: BoxFit.contain),
          ),
        ),
      );
}