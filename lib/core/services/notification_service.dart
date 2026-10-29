import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/profile/domain/entities/profile.dart';
import '../../features/ttd/domain/entities/ttd_settings.dart';
import 'ttd_messages.dart';

/// Notifikasi lokal: pengingat TTD (per profil) & skrining mingguan.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _screeningId = 900;

  /// ID lama (1 notifikasi per profil), dibatalkan saat jadwal diperbarui.
  static int _legacyTtdId(String profileId) =>
      1000 + (profileId.hashCode & 0x7FFF);

  /// 8 slot per profil: 0 = mingguan, 1..7 = harian per hari (Senin..Minggu).
  static int _ttdId(String profileId, int slot) =>
      100000 + (_stableHash(profileId) & 0xFFFF) * 8 + slot;

  /// Hash FNV-1a: hasilnya sama setiap aplikasi dibuka.
  static int _stableHash(String s) {
    var h = 0x811C9DC5;
    for (final c in s.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  static NotificationDetails _ttdDetails(String body) => NotificationDetails(
        android: AndroidNotificationDetails(
          'ttd_reminder',
          'Pengingat TTD',
          channelDescription: 'Pengingat minum Tablet Tambah Darah',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFFEF233C),
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(),
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
  /// Pesan menyesuaikan profil (remaja, ibu hamil, laki-laki, umum) dan
  /// berganti tiap hari dalam seminggu.
  Future<void> applyTtd({
    required TtdSettings settings,
    required Profile? profile,
  }) async {
    if (kIsWeb) return;
    await init();

    final pid = profile?.id ?? 'default';
    await cancelTtd(pid);

    if (settings.enabled) {
      final audience = audienceOf(profile);
      final name = profile?.name ?? '';
      final weekly = settings.frequency == TtdFrequency.mingguan;
      final days = weekly ? [settings.weekday] : [1, 2, 3, 4, 5, 6, 7];

      for (final day in days) {
        final m = ttdMessage(audience, name, day);
        await _plugin.zonedSchedule(
          id: _ttdId(pid, weekly ? 0 : day),
          title: m.title,
          body: m.body,
          scheduledDate: _next(settings.hour, settings.minute, weekday: day),
          notificationDetails: _ttdDetails(m.body),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
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

  /// Batalkan semua pengingat TTD milik profil ini (dipakai juga saat hapus profil).
  Future<void> cancelTtd(String profileId) async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancel(id: _legacyTtdId(profileId));
    for (var slot = 0; slot < 8; slot++) {
      await _plugin.cancel(id: _ttdId(profileId, slot));
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