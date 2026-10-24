import 'dart:typed_data';

import 'package:anemify/features/scan/domain/entities/risk_category.dart';
import 'package:anemify/features/scan/domain/entities/scan_failure.dart';
import 'package:anemify/features/scan/domain/entities/scan_result.dart';
import 'package:anemify/features/scan/domain/repositories/scan_repository.dart';
import 'package:anemify/features/scan/domain/usecases/classify_anemia_risk.dart';
import 'package:anemify/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:anemify/features/scan/presentation/bloc/scan_event.dart';
import 'package:anemify/features/scan/presentation/bloc/scan_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ScanRepository {
  Uint8List? lastPalm;

  @override
  Future<void> init() async {}

  @override
  Future<ScanResult> classify({Uint8List? palmPhoto, Uint8List? eyePhoto}) async {
    lastPalm = palmPhoto;
    return const ScanResult(category: RiskCategory.tinggi, score: 0.9, palmScore: 0.9);
  }

  @override
  void dispose() {}
}

void main() {
  late _FakeRepo repo;
  late ScanBloc bloc;

  setUp(() {
    repo = _FakeRepo();
    bloc = ScanBloc(repository: repo, classify: ClassifyAnemiaRisk(repo));
  });
  tearDown(() => bloc.close());

  test('muat model -> foto palm -> analisis -> sukses', () async {
    bloc.add(const ScanStarted());
    await bloc.stream.firstWhere((s) => s.status == ScanStatus.ready);

    final palm = Uint8List.fromList([1, 2, 3]);
    bloc.add(PalmPhotoCaptured(palm));
    final withPhoto = await bloc.stream.firstWhere((s) => s.palmPhoto != null);
    expect(withPhoto.canSubmit, isTrue);

    bloc.add(const ScanSubmitted());
    final done = await bloc.stream.firstWhere(
        (s) => s.status == ScanStatus.success || s.status == ScanStatus.failure);
    expect(done.status, ScanStatus.success);
    expect(done.result!.category, RiskCategory.tinggi);
    expect(repo.lastPalm, palm);
  });

  test('analisis tanpa foto -> gagal noPhoto', () async {
    bloc.add(const ScanStarted());
    await bloc.stream.firstWhere((s) => s.status == ScanStatus.ready);
    bloc.add(const ScanSubmitted());
    final done = await bloc.stream.firstWhere((s) => s.status == ScanStatus.failure);
    expect(done.failure, ScanFailureType.noPhoto);
  });
}