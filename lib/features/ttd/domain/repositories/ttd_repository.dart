import '../entities/ttd_settings.dart';

/// Data TTD milik profil aktif.
abstract class TtdRepository {
  Future<TtdSettings> getSettings();
  Future<void> saveSettings(TtdSettings settings);

  /// dateKey -> waktu dicatat
  Future<Map<String, DateTime>> getLogs();
  Future<void> setTaken(DateTime day, bool taken);
}