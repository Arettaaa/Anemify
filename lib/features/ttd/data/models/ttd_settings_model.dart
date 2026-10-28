import '../../domain/entities/ttd_settings.dart';

class TtdSettingsModel {
  TtdSettingsModel._();

  static Map<String, dynamic> toJson(TtdSettings s) => {
        'enabled': s.enabled,
        'frequency': s.frequency.name,
        'weekday': s.weekday,
        'hour': s.hour,
        'minute': s.minute,
        'weeklyScreening': s.weeklyScreening,
        'startDate': s.startDate.millisecondsSinceEpoch,
      };

  static TtdSettings fromJson(Map<String, dynamic> j) => TtdSettings(
        enabled: j['enabled'] as bool? ?? false,
        frequency: TtdFrequency.values.firstWhere(
            (f) => f.name == j['frequency'],
            orElse: () => TtdFrequency.harian),
        weekday: j['weekday'] as int? ?? 1,
        hour: j['hour'] as int? ?? 19,
        minute: j['minute'] as int? ?? 0,
        weeklyScreening: j['weeklyScreening'] as bool? ?? false,
        startDate: DateTime.fromMillisecondsSinceEpoch(
            j['startDate'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      );
}