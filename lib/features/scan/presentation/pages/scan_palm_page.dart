import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scan_failure.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import '../widgets/scan_capture_widgets.dart';
import '../widgets/scan_guide_painters.dart';
import '../widgets/scan_messages.dart';
import '../widgets/scan_widgets.dart';
import 'guided_camera_page.dart';
import 'scan_flow.dart';
import 'scan_loading_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';

class ScanPalmPage extends StatefulWidget {
  /// true = foto telapak sudah ada, langsung analisis ulang.
  final bool autoAnalyze;
  const ScanPalmPage({super.key, this.autoAnalyze = false});

  @override
  State<ScanPalmPage> createState() => _ScanPalmPageState();
}

class _ScanPalmPageState extends State<ScanPalmPage> {
  Uint8List? _photo;

  /// true = analisis gagal bukan karena foto (mis. model belum siap),
  /// jadi cukup coba analisis lagi tanpa memotret ulang.
  bool _canRetry = false;

  @override
  void initState() {
    super.initState();
    _photo = context.read<ScanBloc>().state.palmPhoto;
    if (widget.autoAnalyze && _photo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _analyze();
      });
    }
  }

  Future<void> _capture() async {
    final bytes = await Navigator.of(context, rootNavigator: true)
        .push<Uint8List>(
          MaterialPageRoute(
            builder: (_) => const GuidedCameraPage(isEye: false),
          ),
        );
    if (bytes == null || !mounted) return;
    context.read<ScanBloc>().add(PalmPhotoCaptured(bytes));
    setState(() => _photo = bytes);
    _analyze();
  }

  Future<void> _analyze() async {
    setState(() => _canRetry = false);
    final failed = await pushScanPage<ScanState>(
      context,
      const ScanLoadingPage(),
    );
    if (failed == null || failed.failure == null || !mounted) return;

    showAppToast(
      context,
      pesanGagal(failed.failure!, failed.failedPhoto),
      type: ToastType.error,
    );
    if (failed.failedPhoto == ScanPhotoKind.eye) {
      Navigator.of(context).pop(); // ulangi foto mata saja
    } else if (failed.failedPhoto == null && _photo != null) {
      setState(() => _canRetry = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScanPageScaffold(
      children: [
        const ScanTitle(
          title: 'Foto telapak tangan',
          subtitle: TextSpan(text: 'Langkah 2 dari 2 · Palmar pallor'),
        ),
        const SizedBox(height: 16),
        const ScanStepBars(step: 2),
        const SizedBox(height: 16),
        ScanFrameBox(
          photo: _photo,
          painter: const HandPainter(),
          caption: 'Posisikan bagian tengah telapak di dalam kotak',
        ),
        const SizedBox(height: 16),
        const ScanGuideCard(
          title: 'Panduan foto tangan',
          body:
              'Buka telapak dengan santai dan posisikan bagian tengahnya '
              'memenuhi kotak. Pastikan tajam, tanpa bayangan atau filter kamera.',
        ),
        const SizedBox(height: 16),
        ScanPrimaryButton(
          label: _photo == null ? 'Ambil foto' : 'Ambil ulang foto',
          icon: Icons.photo_camera_rounded,
          iconAfter: false,
          onPressed: _capture,
        ),
        if (_canRetry) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _analyze,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.inactive),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
              label: Text(
                'Coba analisis lagi',
                style: scanStyle(size: 15, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        const ScanCaptureFootnote(),
      ],
    );
  }
}