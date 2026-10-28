enum Sex { perempuan, lakiLaki }

extension SexLabel on Sex {
  String get label => this == Sex.perempuan ? 'Perempuan' : 'Laki-laki';
}

class Profile {
  final String id;
  final String name;
  final int age;
  final Sex sex;
  final bool pregnant;

  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    this.pregnant = false,
  });

  /// Kehamilan hanya relevan untuk perempuan usia 10–55.
  static bool canBePregnant(Sex? sex, int? age) =>
      sex == Sex.perempuan && age != null && age >= 10 && age <= 55;

  factory Profile.create({
    required String name,
    required int age,
    required Sex sex,
    bool pregnant = false,
  }) =>
      Profile(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        age: age,
        sex: sex,
        pregnant: pregnant && canBePregnant(sex, age),
      );

  bool get isPregnant => pregnant && canBePregnant(sex, age);

  /// Label otomatis: Ibu hamil / Remaja (10–19) / Umum.
  String get category {
    if (isPregnant) return 'Ibu hamil';
    if (age >= 10 && age <= 19) return 'Remaja';
    return 'Umum';
  }

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
  String get subtitle => '$age tahun · ${sex.label}'
      '${category == 'Umum' ? '' : ' · $category'}';

  Profile copyWith({String? name, int? age, Sex? sex, bool? pregnant}) {
    final s = sex ?? this.sex;
    final a = age ?? this.age;
    return Profile(
      id: id,
      name: name ?? this.name,
      age: a,
      sex: s,
      pregnant: (pregnant ?? this.pregnant) && canBePregnant(s, a),
    );
  }
}