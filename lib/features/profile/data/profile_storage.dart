import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  final String id;
  final String name;
  final int age;
  final String category;

  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.category,
  });

  factory Profile.create({
    required String name,
    required int age,
    required String category,
  }) =>
      Profile(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        age: age,
        category: category,
      );

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
  String get subtitle => '$age tahun · $category';

  Profile copyWith({String? name, int? age, String? category}) => Profile(
        id: id,
        name: name ?? this.name,
        age: age ?? this.age,
        category: category ?? this.category,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'age': age, 'category': category};

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        name: j['name'] as String,
        age: j['age'] as int,
        category: j['category'] as String,
      );
}

class ProfileStorage {
  ProfileStorage._();

  static const _kProfiles = 'profiles';
  static const _kActive = 'active_profile_id';

  static Future<List<Profile>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfiles);

    if (raw == null) {
      // migrasi dari profil lama (single profile)
      final oldName = prefs.getString('profile_name');
      if (oldName == null) return [];
      final p = Profile.create(
        name: oldName,
        age: prefs.getInt('profile_age') ?? 0,
        category: prefs.getString('profile_category') ?? 'Umum',
      );
      await _saveAll([p]);
      await prefs.setString(_kActive, p.id);
      return [p];
    }

    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Profile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Profile?> getActive() async {
    final all = await getAll();
    if (all.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kActive);
    return all.firstWhere((p) => p.id == id, orElse: () => all.first);
  }

  static Future<void> add(Profile p, {bool setActive = false}) async {
    final all = await getAll();
    await _saveAll([...all, p]);
    if (setActive || all.isEmpty) await setActiveId(p.id);
  }

  static Future<void> update(Profile p) async {
    final all = await getAll();
    await _saveAll([for (final x in all) x.id == p.id ? p : x]);
  }

  static Future<void> setActiveId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActive, id);
  }

  static Future<void> _saveAll(List<Profile> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kProfiles,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }
}