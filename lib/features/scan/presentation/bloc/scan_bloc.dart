import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scan_failure.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/usecases/classify_anemia_risk.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanBloc({required ScanRepository repository, required ClassifyAnemiaRisk classify})
      : _repository = repository,
        _classify = classify,
        super(const ScanState()) {
    on<ScanStarted>(_onStarted);
    on<PalmPhotoCaptured>((e, emit) => emit(state.copyWith(palmPhoto: e.bytes, status: _idle)));
    on<EyePhotoCaptured>((e, emit) => emit(state.copyWith(eyePhoto: e.bytes, status: _idle)));
    on<ScanSubmitted>(_onSubmitted);
    on<ScanReset>((e, emit) => emit(ScanState(status: _idle, modelReady: state.modelReady)));
  }

  final ScanRepository _repository;
  final ClassifyAnemiaRisk _classify;

  /// Status "diam": ready kalau model sudah termuat, selain itu tetap status sekarang.
  ScanStatus get _idle => state.modelReady ? ScanStatus.ready : state.status;

  Future<void> _onStarted(ScanStarted e, Emitter<ScanState> emit) async {
    if (state.modelReady) return;
    emit(state.copyWith(status: ScanStatus.loadingModel));
    try {
      await _repository.init();
      emit(state.copyWith(status: ScanStatus.ready, modelReady: true));
    } catch (_) {
      emit(state.withFailure(ScanFailureType.modelNotReady));
    }
  }

  Future<void> _onSubmitted(ScanSubmitted e, Emitter<ScanState> emit) async {
    if (!state.modelReady) {
      emit(state.withFailure(ScanFailureType.modelNotReady));
      return;
    }
    emit(state.copyWith(status: ScanStatus.processing));
    try {
      final r = await _classify(palmPhoto: state.palmPhoto, eyePhoto: state.eyePhoto);
      emit(state.withResult(r));
    } on ScanFailure catch (f) {
      emit(state.withFailure(f.type));
    } catch (_) {
      emit(state.withFailure(ScanFailureType.unknown));
    }
  }
}