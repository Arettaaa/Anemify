import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/ttd/domain/entities/ttd_settings.dart';

/// Notifikasi lokal: pengingat TTD (per profil) & skrining mingguan.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _screeningId = 900;
  static int _ttdId(String profileId) => 1000 + (profileId.hashCode & 0x7FFF);

  static const _ttdDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'ttd_reminder',
      'Pengingat TTD',
      channelDescription: 'Pengingat minum Tablet Tambah Darah',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const _screeningDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'screening_reminder',
      'Pengingat skrining',
      channelDescription: 'Pengingat skrining mingguan',
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    if (_ready || kIsWeb) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_guessLocation()));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// WIB / WITA / WIT, atau lokasi lain dengan offset yang sama.
  String _guessLocation() {
    final offset = DateTime.now().timeZoneOffset;
    const indo = {7: 'Asia/Jakarta', 8: 'Asia/Makassar', 9: 'Asia/Jayapura'};
    if (offset.inMinutes % 60 == 0 && indo.containsKey(offset.inHours)) {
      return indo[offset.inHours]!;
    }
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (loc.currentTimeZone.offset == offset.inMilliseconds) return loc.name;
    }
    return 'UTC';
  }

  /// Minta izin notifikasi (Android 13+ / iOS). True kalau diizinkan.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await init();
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          true;
    }
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  Future<void> openSettings() => _plugin.openAppNotificationSettings();

  /// Jadwalkan ulang sesuai pengaturan terbaru profil ini.
  Future<void> applyTtd({
    required TtdSettings settings,
    required String profileId,
    required String name,
  }) async {
    if (kIsWeb) return;
    await init();

    final id = _ttdId(profileId);
    await _plugin.cancel(id: id);
    if (settings.enabled) {
      final weekly = settings.frequency == TtdFrequency.mingguan;
      await _plugin.zonedSchedule(
        id: id,
        title:
            name.isEmpty ? 'Waktunya minum TTD' : 'Waktunya minum TTD, $name',
        body: 'Sesuai anjuran tenaga kesehatan. Buka Anemify untuk mencatat.',
        scheduledDate: _next(settings.hour, settings.minute,
            weekday: weekly ? settings.weekday : null),
        notificationDetails: _ttdDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: weekly
            ? DateTimeComponents.dayOfWeekAndTime
            : DateTimeComponents.time,
      );
    }

    await _plugin.cancel(id: _screeningId);
    if (settings.weeklyScreening) {
      await _plugin.zonedSchedule(
        id: _screeningId,
        title: 'Waktunya skrining mingguan',
        body: 'Cek risiko anemia dengan foto mata dan telapak tangan.',
        scheduledDate: _next(8, 0, weekday: DateTime.monday),
        notificationDetails: _screeningDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _next(int hour, int minute, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (!d.isAfter(now) || (weekday != null && d.weekday != weekday)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }
}