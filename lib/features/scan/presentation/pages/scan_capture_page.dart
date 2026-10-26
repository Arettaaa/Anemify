import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/scan_capture_widgets.dart';
import '../widgets/scan_guide_painters.dart';
import '../widgets/scan_widgets.dart';
import 'scan_palm_page.dart';

class ScanCapturePage extends StatefulWidget {
  const ScanCapturePage({super.key});

  @override
  State<ScanCapturePage> createState() => _ScanCapturePageState();
}

class _ScanCapturePageState extends State<ScanCapturePage> {
  XFile? _photo;

  Future<void> _pick() async {
    final x = await pickScanPhoto(context);
    if (x == null || !mounted) return;
    setState(() => _photo = x);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScanPalmPage(eyePhoto: x)),
    );
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
          body: 'Dengan tangan bersih, tarik kelopak bawah perlahan. '
              'Jangan sentuh bola mata. Posisikan konjungtiva pada '
              'bulan sabit. Minta bantuan bila perlu.',
        ),
        const SizedBox(height: 16),
        ScanPrimaryButton(
          label: 'Ambil atau pilih foto',
          icon: Icons.photo_camera_rounded,
          iconAfter: false,
          onPressed: _pick,
        ),
        const SizedBox(height: 14),
        const ScanCaptureFootnote(),
      ],
    );
  }
}