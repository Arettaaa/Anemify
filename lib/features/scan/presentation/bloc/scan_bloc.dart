import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';
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
    on<PalmPhotoCaptured>((e, emit) => _onPhoto(e.bytes, ScanPhotoKind.palm, emit));
    on<EyePhotoCaptured>((e, emit) => _onPhoto(e.bytes, ScanPhotoKind.eye, emit));
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

  /// Foto baru dicek SEGERA: lolos -> disimpan; ditolak -> failure dengan
  /// [failedPhoto] terisi, foto lama (kalau ada) tetap dipertahankan.
  Future<void> _onPhoto(Uint8List bytes, ScanPhotoKind kind, Emitter<ScanState> emit) async {
    final isEye = kind == ScanPhotoKind.eye;
    if (!state.modelReady) {
      // Model belum siap -> tidak bisa dicek; tolak dengan alasan yang jelas.
      emit(state.withFailure(ScanFailureType.modelNotReady, photo: kind));
      return;
    }
    emit(state.copyWith(status: ScanStatus.checkingPhoto));
    try {
      final check = await _repository.checkPhoto(photo: bytes, isEye: isEye);
      final warnings = Map<ScanPhotoKind, List<ScanWarning>>.from(state.photoWarnings)
        ..[kind] = check.warnings;
      emit(state.copyWith(
        status: ScanStatus.ready,
        palmPhoto: isEye ? null : bytes,
        eyePhoto: isEye ? bytes : null,
        photoWarnings: warnings,
      ));
    } on ScanFailure catch (f) {
      emit(state.withFailure(f.type, photo: f.photo ?? kind, metrics: f.metrics));
    } catch (_) {
      emit(state.withFailure(ScanFailureType.unknown, photo: kind));
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
      emit(state.withFailure(f.type, photo: f.photo, metrics: f.metrics));
    } catch (_) {
      emit(state.withFailure(ScanFailureType.unknown));
    }
  }
}
