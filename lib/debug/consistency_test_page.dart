import 'dart:math' as math;

import 'package:anemify/core/di/injection.dart';
import 'package:anemify/features/scan/domain/entities/scan_failure.dart';
import 'package:anemify/features/scan/domain/repositories/scan_repository.dart';
import 'package:anemify/features/scan/presentation/widgets/guide_overlay.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Batas selisih skor (maks - min) yang dianggap konsisten. Ubah sesuai kebutuhan.
const double kMaxRange = 0.10;

class _Shot {
  const _Shot(this.eye, this.front, this.score, this.category);
  final bool eye;
  final bool front;
  final double score;
  final String category;
  String get type => eye ? 'Mata' : 'Palm';
  String get lens => front ? 'Depan' : 'Belakang';
}

/// #21 Uji konsistensi: foto berulang (3x) dan kamera depan vs belakang.
class ConsistencyTestPage extends StatefulWidget {
  const ConsistencyTestPage({super.key});

  @override
  State<ConsistencyTestPage> createState() => _ConsistencyTestPageState();
}

class _ConsistencyTestPageState extends State<ConsistencyTestPage> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _eye = false;
  bool _front = false;
  bool _busy = false;
  bool _switching = false;
  String? _error;
  final List<_Shot> _shots = [];
  final Map<String, Map<String, int>> _rejects = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) throw Exception('Tidak ada kamera');
      await sl<ScanRepository>().init();
      await _startCamera();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _startCamera() async {
    if (_switching || !mounted) return;
    _switching = true;
    final lens = _front ? CameraLensDirection.front : CameraLensDirection.back;
    final match = _cameras.where((c) => c.lensDirection == lens);
    if (match.isEmpty) {
      _toast('Kamera ${_front ? 'depan' : 'belakang'} tidak tersedia');
      setState(() => _front = !_front);
      _switching = false;
      return;
    }
    final old = _controller;
    setState(() => _controller = null);
    try {
      await old?.dispose();
      final c = CameraController(match.first, ResolutionPreset.high, enableAudio: false);
      await c.initialize();
      try {
        await c.setFlashMode(FlashMode.off);
      } catch (_) {
        // Kamera depan sering tidak punya flash.
      }
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _controller = c);
    } catch (e) {
      _toast('Kamera gagal dibuka: $e');
    } finally {
      _switching = false;
    }
  }

  Future<void> _shoot() async {
    final c = _controller;
    if (c == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await c.takePicture();
      final bytes = await file.readAsBytes();
      final repo = sl<ScanRepository>();
      final r = _eye
          ? await repo.classify(eyePhoto: bytes)
          : await repo.classify(palmPhoto: bytes);
      final isFront = c.description.lensDirection == CameraLensDirection.front;
      _shots.add(_Shot(_eye, isFront, r.score, r.category.key));
    } on ScanFailure catch (e) {
      final isFront = c.description.lensDirection == CameraLensDirection.front;
      final g = '${_eye ? 'Mata' : 'Palm'} - ${isFront ? 'Depan' : 'Belakang'}';
      final m = _rejects.putIfAbsent(g, () => {});
      m[e.type.name] = (m[e.type.name] ?? 0) + 1;
      _toast('Ditolak: ${e.type.name}');
    } catch (e) {
      _toast('Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  List<String> _summary() {
    final lines = <String>[];
    final groups = <String, List<_Shot>>{};
    for (final s in _shots) {
      groups.putIfAbsent('${s.type} - ${s.lens}', () => []).add(s);
    }
    final means = <String, double>{};
    groups.forEach((k, v) {
      final sc = v.map((e) => e.score).toList();
      final mn = sc.reduce(math.min);
      final mx = sc.reduce(math.max);
      final cats = v.map((e) => e.category).toSet();
      means[k] = sc.reduce((a, b) => a + b) / sc.length;
      final ok = (mx - mn) <= kMaxRange && cats.length == 1;
      final verdict = v.length < 3 ? 'butuh minimal 3 foto' : (ok ? 'KONSISTEN' : 'TIDAK KONSISTEN');
      lines.add('$k: n=${v.length}, skor ${mn.toStringAsFixed(3)}-${mx.toStringAsFixed(3)}, '
          'selisih ${(mx - mn).toStringAsFixed(3)}, kategori ${cats.join('/')} -> $verdict');
    });
    for (final t in ['Palm', 'Mata']) {
      final d = means['$t - Depan'];
      final b = means['$t - Belakang'];
      if (d != null && b != null) {
        lines.add('$t: selisih rata-rata depan vs belakang = ${(d - b).abs().toStringAsFixed(3)}');
      }
    }
    _rejects.forEach((g, m) {
      final total = m.values.fold(0, (a, b) => a + b);
      final ok = groups[g]?.length ?? 0;
      final detail = m.entries.map((e) => '${e.key} ${e.value}').join(', ');
      lines.add('$g: ditolak $total dari ${total + ok} foto ($detail)');
    });
    return lines;
  }

  Future<void> _copy() async {
    final out = StringBuffer('jenis,kamera,skor,kategori\n');
    for (final s in _shots) {
      out.writeln('${s.type},${s.lens},${s.score.toStringAsFixed(4)},${s.category}');
    }
    out.writeln();
    for (final l in _summary()) {
      out.writeln(l);
    }
    await Clipboard.setData(ClipboardData(text: out.toString()));
    _toast('Hasil tersalin');
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uji konsistensi (#21)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Salin hasil',
            onPressed: (_shots.isEmpty && _rejects.isEmpty) ? null : _copy,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus semua',
            onPressed: (_shots.isEmpty && _rejects.isEmpty)
                ? null
                : () => setState(() {
                      _shots.clear();
                      _rejects.clear();
                    }),
          ),
        ],
      ),
      body: _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Palm')),
                          ButtonSegment(value: true, label: Text('Mata')),
                        ],
                        selected: {_eye},
                        onSelectionChanged: (s) => setState(() => _eye = s.first),
                      ),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Belakang')),
                          ButtonSegment(value: true, label: Text('Depan')),
                        ],
                        selected: {_front},
                        onSelectionChanged: (_switching || _busy)
                            ? null
                            : (s) {
                                setState(() => _front = s.first);
                                _startCamera();
                              },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: (c == null || !c.value.isInitialized)
                        ? const CircularProgressIndicator()
                        : AspectRatio(
                            aspectRatio: 1 / c.value.aspectRatio,
                            child: Stack(
                              children: [
                                Positioned.fill(child: CameraPreview(c)),
                                Positioned.fill(child: GuideOverlay(isEye: _eye)),
                              ],
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: FilledButton.icon(
                    onPressed: (_busy || c == null) ? null : _shoot,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_busy ? 'Menganalisis...' : 'Ambil & analisis'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final l in _summary())
                        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(l)),
                      if (_shots.isNotEmpty) const Divider(),
                      for (final s in _shots.reversed)
                        Text('${s.type} ${s.lens}: ${s.score.toStringAsFixed(4)} (${s.category})'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}