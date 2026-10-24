import 'dart:typed_data';

import 'package:equatable/equatable.dart';

sealed class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

/// Muat model. Kirim sekali saat alur skrining dibuka.
class ScanStarted extends ScanEvent {
  const ScanStarted();
}

/// Foto palm utuh dari kamera.
class PalmPhotoCaptured extends ScanEvent {
  const PalmPhotoCaptured(this.bytes);
  final Uint8List bytes;

  @override
  List<Object?> get props => [bytes];
}

/// Foto mata utuh dari kamera.
class EyePhotoCaptured extends ScanEvent {
  const EyePhotoCaptured(this.bytes);
  final Uint8List bytes;

  @override
  List<Object?> get props => [bytes];
}

/// Jalankan analisis dengan foto yang ada (palm, mata, atau keduanya).
class ScanSubmitted extends ScanEvent {
  const ScanSubmitted();
}

/// Hapus foto dan hasil, mulai ulang (model tetap termuat).
class ScanReset extends ScanEvent {
  const ScanReset();
}