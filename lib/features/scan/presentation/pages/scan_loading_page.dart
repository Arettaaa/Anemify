import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../history/domain/usecases/history_usecases.dart';
import '../../../history/presentation/history_revision.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import '../widgets/scan_widgets.dart';
import 'scan_flow.dart';
import 'scan_result_page.dart';
import '../../domain/entities/scan_failure.dart';

/// Kirim ScanSubmitted. Sukses -> simpan riwayat + ke hasil. Gagal -> pop(state).
class ScanLoadingPage extends StatefulWidget {
  const ScanLoadingPage({super.key});

  @override
  State<ScanLoadingPage> createState() => _ScanLoadingPageState();
}

class _ScanLoadingPageState extends State<ScanLoadingPage>
    with TickerProviderStateMixin {
  static const _steps = [
    'Memeriksa kualitas foto…',
    'Menganalisis foto…',
    'Menyiapkan hasil…',
  ];

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (t) {
      if (!mounted || _step >= _steps.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _step++);
    });
  }

  /// Tunggu model siap dulu (kalau belum), baru analisis.
    /// Tunggu model siap dulu (kalau belum), baru analisis.
  Future<void> _start() async {
    final bloc = context.read<ScanBloc>();
    if (!bloc.state.modelReady) {
      if (bloc.state.status != ScanStatus.loadingModel) {
        bloc.add(const ScanStarted());
      }
      await bloc.stream
          .firstWhere((s) => s.modelReady || s.status == ScanStatus.failure)
          .timeout(const Duration(seconds: 20), onTimeout: () => bloc.state);
      if (!mounted) return;
      if (!bloc.state.modelReady) {
        // Gagal dimuat -> listener sudah menutup halaman.
        // Timeout -> tutup di sini supaya pengguna tidak terjebak.
        if (bloc.state.status != ScanStatus.failure) {
          Navigator.of(context).pop(
            bloc.state.withFailure(ScanFailureType.modelNotReady),
          );
        }
        return;
      }
    }
    bloc.add(const ScanSubmitted());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spin.dispose();
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.sizeOf(context).width < 360 ? 16.0 : 24.0;
    return BlocListener<ScanBloc, ScanState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, s) {
        if (s.status == ScanStatus.success && s.result != null) {
          sl<SaveScanToHistory>()(s.result!)
              .then((_) => notifyHistoryChanged()); // kontrak bagian 10
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
                              _ScanLoader(spin: _spin, scan: _scan),
                              const SizedBox(height: 32),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                transitionBuilder: (child, a) =>
                                    FadeTransition(
                                  opacity: a,
                                  child: SlideTransition(
                                    position: Tween(
                                      begin: const Offset(0, 0.3),
                                      end: Offset.zero,
                                    ).animate(a),
                                    child: child,
                                  ),
                                ),
                                child: Text(
                                  _steps[_step],
                                  key: ValueKey(_step),
                                  textAlign: TextAlign.center,
                                  style: scanStyle(
                                      size: 19,
                                      weight: FontWeight.w700,
                                      letterSpacing: -0.3),
                                ),
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

class _ScanLoader extends StatelessWidget {
  final Animation<double> spin;
  final Animation<double> scan;
  const _ScanLoader({required this.spin, required this.scan});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: spin,
            child: CustomPaint(
              size: const Size.square(132),
              painter: _RingPainter(),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.pinkTint,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: Icon(Icons.crop_free_rounded,
                      size: 48, color: AppColors.primary),
                ),
                AnimatedBuilder(
                  animation: scan,
                  builder: (_, _) {
                    final t = Curves.easeInOut.transform(scan.value);
                    return Positioned(
                      left: 12,
                      right: 12,
                      top: 12 + 22 * t,
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cincin tipis + busur merah berekor (diputar oleh RotationTransition).
class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: r);

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = AppColors.pinkTint,
    );

    const sweep = math.pi * 1.35;
    canvas.drawArc(
      rect,
      0,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: sweep,
          colors: [AppColors.primary.withValues(alpha: 0), AppColors.primary],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}