import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../widgets/guide_overlay.dart';

/// Halaman kamera DEBUG dengan overlay panduan. Mengembalikan bytes foto lewat Navigator.pop.
class DebugCameraPage extends StatefulWidget {
  const DebugCameraPage({super.key, required this.isEye});

  final bool isEye;

  @override
  State<DebugCameraPage> createState() => _DebugCameraPageState();
}

class _DebugCameraPageState extends State<DebugCameraPage> {
  List<CameraDescription> _cams = [];
  CameraController? _c;
  int _idx = 0;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _cams = await availableCameras();
      final back = _cams.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      await _open(back >= 0 ? back : 0);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _open(int i) async {
    final old = _c;
    setState(() => _c = null);
    await old?.dispose();
    final c = CameraController(_cams[i], ResolutionPreset.high, enableAudio: false);
    await c.initialize();
    await c.setFlashMode(FlashMode.off); // sesuai protokol dataset: tanpa flash
    if (!mounted) {
      await c.dispose();
      return;
    }
    setState(() {
      _c = c;
      _idx = i;
    });
  }

  Future<void> _capture() async {
    final c = _c;
    if (c == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await c.takePicture();
      final bytes = await file.readAsBytes();
      if (mounted) Navigator.of(context).pop(bytes);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.isEye ? 'Foto mata' : 'Foto telapak'),
        actions: [
          if (_cams.length > 1)
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: () => _open((_idx + 1) % _cams.length),
            ),
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
          : c == null || !c.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Center(
                        // Preview ditampilkan UTUH (tanpa crop/zoom) agar koordinat panduan = koordinat foto
                        child: AspectRatio(
                          aspectRatio: 1 / c.value.aspectRatio,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [CameraPreview(c), GuideOverlay(isEye: widget.isEye)],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        widget.isEye
                            ? 'Pegang HP ±15–20 cm. Tarik kelopak mata bawah, lalu posisikan garis merah muda di dalam sabit tipis.'
                            : 'Buka telapak tangan dan posisikan bagian tengahnya di dalam kotak.',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: FloatingActionButton(
                        onPressed: _busy ? null : _capture,
                        child: _busy
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
    );
  }
}