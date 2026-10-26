import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../widgets/guide_overlay.dart';

/// Halaman kamera berpanduan untuk skrining.
///
/// Pemakaian (tim UI):
/// ```dart
/// final bytes = await Navigator.of(context).push<Uint8List>(
///   MaterialPageRoute(builder: (_) => const GuidedCameraPage(isEye: true)));
/// if (bytes != null) bloc.add(EyePhotoCaptured(bytes));
/// ```
/// Mengembalikan foto UTUH (jangan dipotong/dikompres), atau null bila batal.
/// Panduan digambar dari GuideGeometry = area yang dipotong sistem. Tampilan boleh
/// diberi gaya, tapi preview harus utuh (AspectRatio, tanpa BoxFit.cover/zoom).
class GuidedCameraPage extends StatefulWidget {
  const GuidedCameraPage({
    super.key,
    required this.isEye,
    this.instruction,
    this.preferFront = false,
  });

  final bool isEye;

  /// Teks petunjuk; null = teks bawaan sesuai jenis foto.
  final String? instruction;

  /// true = mulai dari kamera depan (pemakaian sendiri).
  final bool preferFront;

  static const eyeInstruction =
      'Pegang HP ±15–20 cm. Tarik kelopak mata bawah sampai bagian dalam yang kemerahan terlihat. '
      'Isi sabit dengan bagian kemerahan itu saja, bulu mata di luar sabit. Gunakan cahaya terang.';
  static const palmInstruction =
      'Buka telapak tangan dan posisikan bagian tengahnya memenuhi kotak. Gunakan cahaya terang.';

  @override
  State<GuidedCameraPage> createState() => _GuidedCameraPageState();
}

class _GuidedCameraPageState extends State<GuidedCameraPage> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  late bool _front = widget.preferFront;
  bool _opening = false;
  bool _busy = false;
  String? _error;

  bool get _canSwitch =>
      _cameras.any((c) => c.lensDirection == CameraLensDirection.front) &&
      _cameras.any((c) => c.lensDirection == CameraLensDirection.back);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// Kamera dilepas saat aplikasi ke background, dibuka lagi saat kembali.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final c = _controller;
      if (c == null) return;
      setState(() => _controller = null);
      c.dispose();
    } else if (state == AppLifecycleState.resumed && _controller == null && _cameras.isNotEmpty) {
      _open();
    }
  }

  Future<void> _init() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) throw CameraException('NoCamera', 'Tidak ada kamera');
      if (!_cameras.any((c) => c.lensDirection == CameraLensDirection.front)) _front = false;
      await _open();
    } on CameraException catch (e) {
      if (mounted) setState(() => _error = 'Kamera tidak tersedia (${e.code}).');
    }
  }

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    final dir = _front ? CameraLensDirection.front : CameraLensDirection.back;
    final cam = _cameras.firstWhere((c) => c.lensDirection == dir, orElse: () => _cameras.first);
    final old = _controller;
    if (mounted) setState(() => _controller = null);
    await old?.dispose();
    final c = CameraController(cam, ResolutionPreset.high, enableAudio: false);
    try {
      await c.initialize();
      try {
        await c.setFlashMode(FlashMode.off);
      } catch (_) {
        // Kamera depan sering tidak punya flash.
      }
      await _focusCenter(c);
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _controller = c;
        _error = null;
      });
    } on CameraException catch (e) {
      await c.dispose();
      if (mounted) {
        setState(() => _error = e.code.contains('AccessDenied')
            ? 'Izin kamera ditolak. Aktifkan izin kamera untuk Anemify di pengaturan HP.'
            : 'Kamera gagal dibuka (${e.code}).');
      }
    } finally {
      _opening = false;
    }
  }

  /// Fokus & exposure ke tengah panduan (kotak palm dan sabit sama-sama di tengah).
  Future<void> _focusCenter(CameraController c) async {
    try {
      await c.setFocusMode(FocusMode.auto);
      if (c.value.focusPointSupported) await c.setFocusPoint(const Offset(0.5, 0.5));
      if (c.value.exposurePointSupported) await c.setExposurePoint(const Offset(0.5, 0.5));
    } catch (_) {
      // Tidak semua HP mendukung titik fokus; kamera tetap bisa dipakai.
    }
  }

  void _switch() {
    if (_busy || _opening) return;
    setState(() => _front = !_front);
    _open();
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      final f = await c.takePicture();
      final bytes = await f.readAsBytes();
      if (mounted) Navigator.of(context).pop<Uint8List>(bytes);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memotret (${e.code}). Coba lagi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final Widget preview;
    if (_error != null) {
      preview = Padding(
        padding: const EdgeInsets.all(24),
        child: Text(_error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
      );
    } else if (c == null || !c.value.isInitialized) {
      preview = const CircularProgressIndicator();
    } else {
      preview = GestureDetector(
        onTap: () => _focusCenter(c),
        child: AspectRatio(
          aspectRatio: 1 / c.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [CameraPreview(c), GuideOverlay(isEye: widget.isEye)],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.isEye ? 'Foto mata' : 'Foto telapak tangan'),
        actions: [
          if (_canSwitch)
            IconButton(
              onPressed: (_busy || _opening) ? null : _switch,
              icon: const Icon(Icons.cameraswitch),
              tooltip: 'Ganti kamera',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: preview)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                widget.instruction ??
                    (widget.isEye ? GuidedCameraPage.eyeInstruction : GuidedCameraPage.palmInstruction),
                style: const TextStyle(color: Colors.white, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FilledButton.icon(
                onPressed: (c == null || _busy) ? null : _capture,
                icon: const Icon(Icons.camera_alt),
                label: Text(_busy ? 'Menyimpan...' : 'Ambil foto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}