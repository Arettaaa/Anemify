import 'package:anemify/core/di/injection.dart';
import 'package:anemify/debug/consistency_test_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupInjection();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ConsistencyTestPage(),
  ));
}