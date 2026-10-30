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

  /// Berapa hari ke depan pengingat TTD dijadwalkan. Jadwal diisi ulang
  /// setiap aplikasi dibuka / data TTD berubah.
  static const _daysAhead = 30;

  /// ID versi lama, hanya untuk dibatalkan.
  static int _legacyTtdId(String profileId) =>
      1000 + (profileId.hashCode & 0x7FFF);
  static int _weeklySlotId(String profileId, int slot) =>
      100000 + (_stableHash(profileId) & 0xFFFF) * 8 + slot;

  /// ID sekarang: satu slot per hari (0.._daysAhead-1) per profil.
  static int _ttdId(String profileId, int slot) =>
      3000000 + (_stableHash(profileId) & 0xFFFF) * 32 + slot;

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

  /// Jadwalkan ulang pengingat TTD profil ini untuk [_daysAhead] hari ke depan.
  /// Hari yang sudah dicatat minum ([takenDays], berisi dateKey) dilewati,
  /// jadi tidak ada notifikasi kalau TTD hari itu sudah diminum.
  /// Pesan menyesuaikan profil (remaja, ibu hamil, laki-laki, umum).
  Future<void> applyTtd({
    required TtdSettings settings,
    required Profile? profile,
    Set<String> takenDays = const {},
  }) async {
    if (kIsWeb) return;
    await init();

    final pid = profile?.id ?? 'default';
    await cancelTtd(pid);
    if (!settings.enabled) return;

    final audience = audienceOf(profile);
    final name = profile?.name ?? '';
    final now = tz.TZDateTime.now(tz.local);
    final today = dayOnly(DateTime.now());

    for (var i = 0; i < _daysAhead; i++) {
      final day = addDays(today, i);
      if (!settings.isScheduled(day)) continue;
      if (takenDays.contains(dateKey(day))) continue;

      final at = tz.TZDateTime(
        tz.local,
        day.year,
        day.month,
        day.day,
        settings.hour,
        settings.minute,
      );
      if (!at.isAfter(now)) continue;

      final m = ttdMessage(audience, name, day.weekday);
      await _plugin.zonedSchedule(
        id: _ttdId(pid, i),
        title: m.title,
        body: m.body,
        scheduledDate: at,
        notificationDetails: _ttdDetails(m.body),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Pengingat skrining mingguan (Senin 08.00), satu untuk seluruh aplikasi.
  Future<void> applyWeeklyScreening(bool enabled) async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancel(id: _screeningId);
    if (!enabled) return;
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

  /// Batalkan semua pengingat TTD milik profil ini (dipakai juga saat hapus profil).
  Future<void> cancelTtd(String profileId) async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancel(id: _legacyTtdId(profileId));
    for (var slot = 0; slot < 8; slot++) {
      await _plugin.cancel(id: _weeklySlotId(profileId, slot));
    }
    for (var slot = 0; slot < 32; slot++) {
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