enum TtdFrequency { harian, mingguan }

const hariNama = {
  1: 'Senin', 2: 'Selasa', 3: 'Rabu', 4: 'Kamis',
  5: 'Jumat', 6: 'Sabtu', 7: 'Minggu',
};

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class TtdSettings {
  final bool enabled;
  final TtdFrequency frequency;
  final int weekday; // 1 = Senin ... 7 = Minggu
  final int hour;
  final int minute;
  final bool weeklyScreening;
  final DateTime startDate;

  const TtdSettings({
    required this.enabled,
    required this.frequency,
    required this.weekday,
    required this.hour,
    required this.minute,
    required this.weeklyScreening,
    required this.startDate,
  });

  factory TtdSettings.initial() => TtdSettings(
        enabled: false,
        frequency: TtdFrequency.harian,
        weekday: 1,
        hour: 19,
        minute: 0,
        weeklyScreening: false,
        startDate: dayOnly(DateTime.now()),
      );

  bool isScheduled(DateTime d) {
    if (!enabled) return false;
    final day = dayOnly(d);
    if (day.isBefore(startDate)) return false;
    return frequency == TtdFrequency.harian || day.weekday == weekday;
  }

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';

  String get frequencyLabel => frequency == TtdFrequency.harian
      ? 'Harian'
      : 'Mingguan · ${hariNama[weekday]}';

  TtdSettings copyWith({
    bool? enabled,
    TtdFrequency? frequency,
    int? weekday,
    int? hour,
    int? minute,
    bool? weeklyScreening,
    DateTime? startDate,
  }) =>
      TtdSettings(
        enabled: enabled ?? this.enabled,
        frequency: frequency ?? this.frequency,
        weekday: weekday ?? this.weekday,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        weeklyScreening: weeklyScreening ?? this.weeklyScreening,
        startDate: startDate ?? this.startDate,
      );
}

class TtdStats {
  final int streak;
  final int taken;
  final int scheduled;
  const TtdStats(this.streak, this.taken, this.scheduled);

  int? get percent => scheduled == 0 ? null : (taken * 100 / scheduled).round();
}