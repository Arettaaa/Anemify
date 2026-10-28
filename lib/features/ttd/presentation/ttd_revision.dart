import 'package:flutter/foundation.dart';

/// Naik setiap data TTD / profil aktif berubah.
final ttdRevision = ValueNotifier<int>(0);
void notifyTtdChanged() => ttdRevision.value++;