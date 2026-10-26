import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/scan_widgets.dart';
import 'scan_result_page.dart';

class ScanLoadingPage extends StatefulWidget {
  final XFile eyePhoto;
  final XFile palmPhoto;
  const ScanLoadingPage({
    super.key,
    required this.eyePhoto,
    required this.palmPhoto,
  });

  @override
  State<ScanLoadingPage> createState() => _ScanLoadingPageState();
}

class _ScanLoadingPageState extends State<ScanLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // TODO: ganti timer dengan state ScanBloc (processing -> success)
    _timer = Timer(const Duration(milliseconds: 2200), _next);
  }

  void _next() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ScanResultPage(
          eyePhoto: widget.eyePhoto,
          palmPhoto: widget.palmPhoto,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.sizeOf(context).width < 360 ? 16.0 : 24.0;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/anemify_logo.png', height: 28),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: Tween(begin: 0.94, end: 1.06).animate(
                                CurvedAnimation(
                                  parent: _pulse,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: const BoxDecoration(
                                  color: AppColors.pinkTint,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.crop_free_rounded,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Menyiapkan hasil simulasi…',
                              textAlign: TextAlign.center,
                              style: scanStyle(
                                size: 19,
                                weight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Quality gate berjalan lokal.\n'
                              'Tidak ada model TFLite pada prototipe ini.',
                              textAlign: TextAlign.center,
                              style: scanStyle(
                                size: 13,
                                height: 1.7,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}