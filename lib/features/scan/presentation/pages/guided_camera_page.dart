import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/guide_overlay.dart';
import '../widgets/scan_widgets.dart';

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

class _GuidedCameraPageState extends State<GuidedCameraPage>
    with WidgetsBindingObserver {
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
    } else if (state == AppLifecycleState.resumed &&
        _controller == null &&
        _cameras.isNotEmpty) {
      _open();
    }
  }

  Future<void> _init() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraException('NoCamera', 'Tidak ada kamera');
      }
      if (!_cameras.any((c) => c.lensDirection == CameraLensDirection.front)) {
        _front = false;
      }
      await _open();
    } on CameraException catch (e) {
      if (mounted) setState(() => _error = 'Kamera tidak tersedia (${e.code}).');
    }
  }

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    final dir = _front ? CameraLensDirection.front : CameraLensDirection.back;
    final cam = _cameras.firstWhere((c) => c.lensDirection == dir,
        orElse: () => _cameras.first);
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
      if (c.value.focusPointSupported) {
        await c.setFocusPoint(const Offset(0.5, 0.5));
      }
      if (c.value.exposurePointSupported) {
        await c.setExposurePoint(const Offset(0.5, 0.5));
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memotret (${e.code}). Coba lagi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;

    final Widget preview;
    if (_error != null) {
      preview = Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: scanStyle(size: 14, height: 1.6, color: AppColors.white),
        ),
      );
    } else if (!ready) {
      preview = const CircularProgressIndicator(color: AppColors.white);
    } else {
      // JANGAN diubah: preview utuh + overlay dari GuideGeometry.
      // ClipRRect hanya membulatkan sudut, tidak crop/zoom.
      preview = GestureDetector(
        onTap: () => _focusCenter(c),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 1 / c.value.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [CameraPreview(c), GuideOverlay(isEye: widget.isEye)],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  _CircleBtn(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      widget.isEye ? 'Foto mata' : 'Foto telapak tangan',
                      textAlign: TextAlign.center,
                      style: scanStyle(
                        size: 16,
                        weight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  _canSwitch
                      ? _CircleBtn(
                          icon: Icons.cameraswitch_outlined,
                          onTap: (_busy || _opening) ? null : _switch,
                        )
                      : const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(child: preview),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      widget.isEye
                          ? Icons.remove_red_eye_outlined
                          : Icons.back_hand_outlined,
                      size: 18,
                      color: AppColors.primarySoft,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.instruction ??
                            (widget.isEye
                                ? GuidedCameraPage.eyeInstruction
                                : GuidedCameraPage.palmInstruction),
                        style: scanStyle(
                          size: 12.5,
                          height: 1.6,
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
              child: GestureDetector(
                onTap: (!ready || _busy) ? null : _capture,
                child: Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 3),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (!ready || _busy)
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.primary,
                    ),
                    child: _busy
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.photo_camera_rounded,
                            color: AppColors.white, size: 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.white),
      ),
    );
  }
}