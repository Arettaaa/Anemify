import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/scan_capture_widgets.dart';
import '../widgets/scan_guide_painters.dart';
import '../widgets/scan_widgets.dart';
import 'scan_loading_page.dart';

class ScanPalmPage extends StatefulWidget {
  final XFile eyePhoto;
  const ScanPalmPage({super.key, required this.eyePhoto});

  @override
  State<ScanPalmPage> createState() => _ScanPalmPageState();
}

class _ScanPalmPageState extends State<ScanPalmPage> {
  XFile? _photo;

  Future<void> _pick() async {
    final x = await pickScanPhoto(context);
    if (x == null || !mounted) return;
    setState(() => _photo = x);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanLoadingPage(
          eyePhoto: widget.eyePhoto,
          palmPhoto: x,
        ),
      ),
    );
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
          caption: 'Sejajarkan telapak dan pastikan garis tangan terlihat',
        ),
        const SizedBox(height: 16),
        const ScanGuideCard(
          title: 'Panduan foto tangan',
          body: 'Buka telapak dengan santai. Pastikan seluruh telapak '
              'dan garis-garisnya tampak tajam, tanpa bayangan atau '
              'filter kamera.',
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