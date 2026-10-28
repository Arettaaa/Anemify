import 'package:flutter/foundation.dart';

/// Naik setiap profil aktif diganti / diubah / ditambah.
final profileRevision = ValueNotifier<int>(0);

void notifyProfileChanged() => profileRevision.value++;