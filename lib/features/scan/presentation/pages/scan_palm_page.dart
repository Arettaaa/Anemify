import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import '../widgets/scan_capture_widgets.dart';
import '../widgets/scan_example_photos.dart';
import '../widgets/scan_guide_painters.dart';
import '../widgets/scan_messages.dart';
import '../widgets/scan_widgets.dart';
import 'guided_camera_page.dart';
import 'scan_flow.dart';
import 'scan_loading_page.dart';

/// Langkah 2: foto telapak tangan. Foto dicek segera setelah diambil; lolos ->
/// langsung analisis. Ditolak -> alasan tampil di sini, foto ulang.
class ScanPalmPage extends StatefulWidget {
  /// true = foto telapak sudah ada, langsung analisis ulang.
  final bool autoAnalyze;
  const ScanPalmPage({super.key, this.autoAnalyze = false});

  @override
  State<ScanPalmPage> createState() => _ScanPalmPageState();
}

class _ScanPalmPageState extends State<ScanPalmPage> {
  Uint8List? _photo;
  Uint8List? _shown; // foto terakhir yang dijepret (lolos atau ditolak), untuk pratinjau
  bool _checking = false;
  ({String judul, String alasan, List<String> tips})? _reject;
  List<String> _warnings = const [];

  /// true = analisis gagal bukan karena foto (mis. model belum siap),
  /// jadi cukup coba analisis lagi tanpa memotret ulang.
  bool _canRetry = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<ScanBloc>().state;
    _photo = s.palmPhoto;
    _warnings = [
      for (final w in s.photoWarnings[ScanPhotoKind.palm] ?? const <ScanWarning>[])
        pesanPeringatan(w),
    ];
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
    final bloc = context.read<ScanBloc>();
    setState(() {
      _checking = true;
      _reject = null;
      _canRetry = false;
      _shown = bytes;
    });
    bloc.add(PalmPhotoCaptured(bytes));
    final s = await bloc.stream.firstWhere(
      (s) =>
          (s.status == ScanStatus.ready && identical(s.palmPhoto, bytes)) ||
          s.status == ScanStatus.failure,
      orElse: () => bloc.state,
    );
    if (!mounted) return;
    if (s.status == ScanStatus.failure) {
      HapticFeedback.vibrate();
      setState(() {
        _checking = false;
        _reject = alasanTolak(s.failure!, s.failedPhoto ?? ScanPhotoKind.palm);
      });
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _checking = false;
      _photo = bytes;
      _warnings = [
        for (final w in s.photoWarnings[ScanPhotoKind.palm] ?? const <ScanWarning>[])
          pesanPeringatan(w),
      ];
    });
    // Tidak langsung analisis: pengguna melihat dulu hasil jepretannya,
    // lalu menekan "Analisis sekarang" sendiri (atau mengambil ulang).
  }

  Future<void> _analyze() async {
    setState(() => _canRetry = false);
    final failed = await pushScanPage<ScanState>(
      context,
      const ScanLoadingPage(),
    );
    if (failed == null || failed.failure == null || !mounted) return;

    // Foto sudah lolos cek sebelum sampai sini, jadi kegagalan di tahap ini
    // hampir selalu bukan karena foto (model belum siap / kesalahan lain).
    final f = failed.failure!;
    if (failed.failedPhoto == ScanPhotoKind.eye) {
      Navigator.of(context).pop(); // ulangi foto mata saja
      return;
    }
    HapticFeedback.vibrate();
    setState(() {
      _reject = alasanTolak(f, failed.failedPhoto ?? ScanPhotoKind.palm);
      _canRetry = failed.failedPhoto == null && _photo != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rejected = _reject;
    final accepted = rejected == null && _photo != null;
    return ScanPageScaffold(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScanPrimaryButton(
            label: _checking
                ? 'Memeriksa foto…'
                : accepted
                    ? 'Analisis sekarang'
                    : rejected != null
                        ? 'Ambil ulang foto'
                        : 'Ambil foto',
            icon: _checking
                ? Icons.hourglass_top_rounded
                : accepted
                    ? Icons.auto_awesome_rounded
                    : Icons.photo_camera_rounded,
            iconAfter: accepted,
            onPressed: _checking
                ? null
                : accepted
                    ? _analyze
                    : _capture,
          ),
          if (accepted && !_checking) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _capture,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.primarySoft),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.photo_camera_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Ambil ulang foto',
                  style: scanStyle(
                      size: 15, weight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ),
          ],
          if (_canRetry) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _analyze,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.primarySoft),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Coba analisis lagi',
                  style: scanStyle(
                      size: 15, weight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
      children: [
        const ScanTitle(
          title: 'Foto telapak tangan',
          subtitle: TextSpan(text: 'Langkah 2 dari 2 · Palmar pallor'),
        ),
        const SizedBox(height: 16),
        const ScanStepBars(step: 2),
        const SizedBox(height: 16),
        ScanFrameBox(
          photo: _shown ?? _photo,
          rejected: _reject != null,
          painter: const HandPainter(),
          caption: 'Posisikan bagian tengah telapak di dalam kotak',
        ),
        const SizedBox(height: 16),
        if (rejected != null) ...[
          ScanRejectCard(
            judul: rejected.judul,
            alasan: rejected.alasan,
            tips: rejected.tips,
          ),
          const SizedBox(height: 16),
        ] else if (_photo != null) ...[
          ScanAcceptedCard(warnings: _warnings),
          const SizedBox(height: 16),
        ],
        const ScanGuideCard(
          title: 'Panduan foto tangan',
          body:
              'Buka telapak dengan santai dan posisikan bagian tengahnya '
              'memenuhi kotak. Pastikan tajam, tanpa bayangan atau filter kamera.',
        ),
        const SizedBox(height: 14),
        const ContohFotoCard(isEye: false),
        const SizedBox(height: 14),
        const ScanCaptureFootnote(),
      ],
    );
  }
}
