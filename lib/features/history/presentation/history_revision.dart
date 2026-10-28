import 'package:flutter/foundation.dart';

/// Naik setiap riwayat berubah (simpan/hapus). Halaman yang menampilkan riwayat mendengarkan ini.
final historyRevision = ValueNotifier<int>(0);

void notifyHistoryChanged() => historyRevision.value++;