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
import 'scan_palm_page.dart';

/// Langkah 1: foto konjungtiva. Foto dicek SEGERA setelah diambil; kalau
/// ditolak, alasannya tampil di halaman ini dan pengguna foto ulang sebelum
/// lanjut ke telapak tangan.
class ScanCapturePage extends StatefulWidget {
  const ScanCapturePage({super.key});

  @override
  State<ScanCapturePage> createState() => _ScanCapturePageState();
}

class _ScanCapturePageState extends State<ScanCapturePage> {
  Uint8List? _photo;
  bool _checking = false;
  ({String judul, String alasan, List<String> tips})? _reject;
  List<String> _warnings = const [];

  Future<void> _capture() async {
    // rootNavigator: kamera full screen di atas bottom nav
    final bytes =
        await Navigator.of(context, rootNavigator: true).push<Uint8List>(
      MaterialPageRoute(builder: (_) => const GuidedCameraPage(isEye: true)),
    );
    if (bytes == null || !mounted) return;
    final bloc = context.read<ScanBloc>();
    setState(() {
      _checking = true;
      _reject = null;
    });
    bloc.add(EyePhotoCaptured(bytes));
    final s = await bloc.stream.firstWhere(
      (s) =>
          (s.status == ScanStatus.ready && identical(s.eyePhoto, bytes)) ||
          s.status == ScanStatus.failure,
      orElse: () => bloc.state,
    );
    if (!mounted) return;
    if (s.status == ScanStatus.failure) {
      HapticFeedback.vibrate();
      setState(() {
        _checking = false;
        _reject = alasanTolak(s.failure!, s.failedPhoto ?? ScanPhotoKind.eye);
      });
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _checking = false;
      _photo = bytes;
      _warnings = [
        for (final w in s.photoWarnings[ScanPhotoKind.eye] ?? const <ScanWarning>[])
          pesanPeringatan(w),
      ];
    });
    // Tidak langsung pindah halaman: pengguna melihat dulu hasil jepretannya,
    // lalu menekan "Lanjut" sendiri (atau mengambil ulang).
  }

  /// Lanjut ke langkah telapak. Kalau foto telapak sudah ada (kasus ulang
  /// foto mata), langsung analisis lagi tanpa memotret ulang telapak.
  void _next() {
    final hasPalm = context.read<ScanBloc>().state.palmPhoto != null;
    pushScanPage(context, ScanPalmPage(autoAnalyze: hasPalm));
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
                    ? 'Lanjut ke telapak tangan'
                    : rejected != null
                        ? 'Ambil ulang foto'
                        : 'Ambil foto',
            icon: _checking
                ? Icons.hourglass_top_rounded
                : accepted
                    ? Icons.arrow_forward_rounded
                    : Icons.photo_camera_rounded,
            iconAfter: accepted,
            onPressed: _checking
                ? null
                : accepted
                    ? _next
                    : _capture,
          ),
          if (!_checking && (accepted || (rejected != null && _photo != null))) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: accepted ? _capture : _next,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.primarySoft),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(
                  accepted
                      ? Icons.photo_camera_outlined
                      : Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  accepted
                      ? 'Ambil ulang foto'
                      : 'Lanjut dengan foto sebelumnya',
                  style: scanStyle(
                      size: 15,
                      weight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
      children: [
        const ScanTitle(
          title: 'Foto bagian dalam mata',
          subtitle: TextSpan(text: 'Langkah 1 dari 2 · Konjungtiva mata'),
        ),
        const SizedBox(height: 16),
        const ScanStepBars(step: 1),
        const SizedBox(height: 16),
        ScanFrameBox(
          photo: _photo,
          painter: const CrescentPainter(),
          caption: 'Posisikan konjungtiva pada frame bulan sabit',
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
          title: 'Panduan foto mata',
          body: 'Pegang HP ±15–20 cm. Dengan tangan bersih, tarik kelopak bawah '
              'perlahan sampai bagian dalam yang kemerahan terlihat. Isi sabit '
              'dengan bagian itu saja, bulu mata di luar sabit. Cahaya terang, '
              'tanpa flash. Minta bantuan bila perlu.',
        ),
        const SizedBox(height: 14),
        const ContohFotoCard(isEye: true),
        const SizedBox(height: 14),
        const ScanCaptureFootnote(),
      ],
    );
  }
}
