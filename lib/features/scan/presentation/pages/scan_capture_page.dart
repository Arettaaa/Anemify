import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../widgets/scan_capture_widgets.dart';
import '../widgets/scan_guide_painters.dart';
import '../widgets/scan_widgets.dart';
import 'guided_camera_page.dart';
import 'scan_flow.dart';
import 'scan_palm_page.dart';

class ScanCapturePage extends StatefulWidget {
  const ScanCapturePage({super.key});

  @override
  State<ScanCapturePage> createState() => _ScanCapturePageState();
}

class _ScanCapturePageState extends State<ScanCapturePage> {
  Uint8List? _photo;

  Future<void> _capture() async {
    // rootNavigator: kamera full screen di atas bottom nav
    final bytes =
        await Navigator.of(context, rootNavigator: true).push<Uint8List>(
      MaterialPageRoute(builder: (_) => const GuidedCameraPage(isEye: true)),
    );
    if (bytes == null || !mounted) return;
        final bloc = context.read<ScanBloc>();
    bloc.add(EyePhotoCaptured(bytes));
    setState(() => _photo = bytes);
    // Kalau foto telapak sudah ada (ulang foto mata karena gagal),
    // langsung analisis lagi tanpa memotret ulang telapak (kontrak bagian 4).
    final hasPalm = bloc.state.palmPhoto != null;
    pushScanPage(context, ScanPalmPage(autoAnalyze: hasPalm));
  }

  @override
  Widget build(BuildContext context) {
    return ScanPageScaffold(
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
        const ScanGuideCard(
          title: 'Panduan foto mata',
          body: 'Pegang HP ±15–20 cm. Dengan tangan bersih, tarik kelopak bawah '
              'perlahan sampai bagian dalam yang kemerahan terlihat. Isi sabit '
              'dengan bagian itu saja, bulu mata di luar sabit. Cahaya terang, '
              'tanpa flash. Minta bantuan bila perlu.',
        ),
        const SizedBox(height: 16),
        ScanPrimaryButton(
          label: _photo == null ? 'Ambil foto' : 'Ambil ulang foto',
          icon: Icons.photo_camera_rounded,
          iconAfter: false,
          onPressed: _capture,
        ),
        const SizedBox(height: 14),
        const ScanCaptureFootnote(),
      ],
    );
  }
}