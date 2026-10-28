import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../history/domain/usecases/history_usecases.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import '../widgets/scan_widgets.dart';
import 'scan_flow.dart';
import 'scan_result_page.dart';

/// Kirim ScanSubmitted. Sukses -> simpan riwayat + ke hasil. Gagal -> pop(state).
class ScanLoadingPage extends StatefulWidget {
  const ScanLoadingPage({super.key});

  @override
  State<ScanLoadingPage> createState() => _ScanLoadingPageState();
}

class _ScanLoadingPageState extends State<ScanLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    context.read<ScanBloc>().add(const ScanSubmitted());
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.sizeOf(context).width < 360 ? 16.0 : 24.0;
    return BlocListener<ScanBloc, ScanState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, s) {
        if (s.status == ScanStatus.success && s.result != null) {
          sl<SaveScanToHistory>()(s.result!); // kontrak bagian 10
          pushScanPage(context, ScanResultPage(result: s.result!),
              replace: true);
        } else if (s.status == ScanStatus.failure) {
          Navigator.of(context).pop(s);
        }
      },
      child: PopScope(
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
                      const AppLogo(),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: Tween(begin: 0.94, end: 1.06).animate(
                                  CurvedAnimation(
                                      parent: _pulse, curve: Curves.easeInOut),
                                ),
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: const BoxDecoration(
                                    color: AppColors.pinkTint,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.crop_free_rounded,
                                      size: 36, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Menganalisis foto…',
                                textAlign: TextAlign.center,
                                style: scanStyle(
                                    size: 19,
                                    weight: FontWeight.w700,
                                    letterSpacing: -0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Dicek kualitasnya lalu dianalisis di perangkatmu.\n'
                                'Foto tidak dikirim ke server.',
                                textAlign: TextAlign.center,
                                style: scanStyle(
                                    size: 13,
                                    height: 1.7,
                                    color: AppColors.textSecondary),
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
      ),
    );
  }
}