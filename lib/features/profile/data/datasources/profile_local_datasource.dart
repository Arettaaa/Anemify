import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

/// Profil disimpan sebagai JSON di SharedPreferences.
class ProfileLocalDataSource {
  static const _kProfiles = 'profiles';
  static const _kActive = 'active_profile_id';

  Future<List<Profile>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfiles);

    if (raw == null) {
      // migrasi dari profil tunggal versi lama
      final oldName = prefs.getString('profile_name');
      if (oldName == null) return [];
      final p = Profile.create(
        name: oldName,
        age: prefs.getInt('profile_age') ?? 0,
        sex: Sex.perempuan,
        pregnant: prefs.getString('profile_category') == 'Ibu hamil',
      );
      await saveAll([p]);
      await setActiveId(p.id);
      return [p];
    }

    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Profile> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kProfiles,
      jsonEncode(list.map(ProfileModel.toJson).toList()),
    );
  }

  Future<String?> getActiveId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kActive);
  }

  Future<void> setActiveId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActive, id);
  }
}