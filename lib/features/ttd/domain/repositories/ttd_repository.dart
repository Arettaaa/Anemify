import '../entities/ttd_settings.dart';

/// Data TTD milik profil aktif.
abstract class TtdRepository {  Future<void> saveSettings(TtdSettings settings);

  /// dateKey -> waktu dicatat
  Future<Map<String, DateTime>> getLogs([String? profileId]);
  Future<void> setTaken(DateTime day, bool taken);
  Future<void> restoreLogs(String profileId, Map<String, DateTime> logs);
  /// Hapus pengaturan dan catatan TTD profil aktif.
  Future<void> clear();
  Future<TtdSettings> getSettings([String? profileId]);
}