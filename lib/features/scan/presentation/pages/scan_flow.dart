import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/scan_bloc.dart';

const kScanCaptureRoute = 'scan_capture';

/// Push halaman scan berikutnya (di dalam tab Scan) dengan ScanBloc yang sama.
Future<T?> pushScanPage<T>(
  BuildContext context,
  Widget page, {
  bool replace = false,
  String? name,
}) {
  final bloc = context.read<ScanBloc>();
  final route = MaterialPageRoute<T>(
    settings: RouteSettings(name: name),
    builder: (_) => BlocProvider.value(value: bloc, child: page),
  );
  final nav = Navigator.of(context);
  return replace ? nav.pushReplacement(route) : nav.push(route);
}