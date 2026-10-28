import '../../domain/entities/profile.dart';

class ProfileModel {
  ProfileModel._();

  static Map<String, dynamic> toJson(Profile p) => {
        'id': p.id,
        'name': p.name,
        'age': p.age,
        'sex': p.sex.name,
        'pregnant': p.pregnant,
      };

  /// Kompatibel dengan format lama yang punya 'category' tanpa 'sex'.
  static Profile fromJson(Map<String, dynamic> j) {
    final oldCategory = j['category'] as String?;
    final sexName = j['sex'] as String?;
    return Profile(
      id: j['id'] as String,
      name: j['name'] as String,
      age: j['age'] as int,
      sex: Sex.values.firstWhere((s) => s.name == sexName,
          orElse: () => Sex.perempuan),
      pregnant: (j['pregnant'] as bool?) ?? oldCategory == 'Ibu hamil',
    );
  }
}