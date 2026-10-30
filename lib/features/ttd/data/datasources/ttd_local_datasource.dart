import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/ttd_settings.dart';
import '../models/ttd_settings_model.dart';

/// Disimpan di SharedPreferences, terpisah per profil aktif.
class TtdLocalDataSource {
  final ProfileRepository _profiles;
  TtdLocalDataSource(this._profiles);

   Future<String> _pid([String? profileId]) async =>
      profileId ?? (await _profiles.getActive())?.id ?? 'default';

  Future<TtdSettings> getSettings([String? profileId]) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ttd_settings_${await _pid(profileId)}');
    if (raw == null) return TtdSettings.initial();
    return TtdSettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(TtdSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'ttd_settings_${await _pid()}', jsonEncode(TtdSettingsModel.toJson(s)));
  }

  Future<Map<String, DateTime>> getLogs([String? profileId]) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ttd_logs_${await _pid(profileId)}');
    if (raw == null) return {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m.map((k, v) =>
        MapEntry(k, DateTime.fromMillisecondsSinceEpoch(v as int)));
  }

    /// Hapus pengaturan dan catatan TTD profil aktif.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final pid = await _pid();
    await prefs.remove('ttd_settings_$pid');
    await prefs.remove('ttd_logs_$pid');
  }

  Future<void> setTaken(DateTime day, bool taken) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ttd_logs_${await _pid()}';
    final logs = await getLogs();
    final k = dateKey(day);
    if (taken) {
      final now = DateTime.now();
      logs[k] = DateTime(day.year, day.month, day.day, now.hour, now.minute);
    } else {
      logs.remove(k);
    }
    await prefs.setString(key,
        jsonEncode(logs.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch))));
  }
}