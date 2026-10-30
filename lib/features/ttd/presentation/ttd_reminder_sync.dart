import '../../../core/di/injection.dart';
import '../../../core/services/notification_service.dart';
import '../../profile/domain/usecases/profile_usecases.dart';
import '../domain/usecases/ttd_usecases.dart';

Future<void> _queue = Future.value();

/// Jadwalkan ulang pengingat TTD semua profil.
/// Hari yang sudah dicentang "sudah diminum" tidak diberi notifikasi.
/// Dipanggil saat aplikasi dibuka dan setiap data TTD / profil berubah.
/// Antre (tidak jalan bersamaan) supaya jadwal tidak saling tumpang tindih.
Future<void> syncTtdReminders() {
  _queue = _queue.then((_) => _sync()).catchError((_) {});
  return _queue;
}

Future<void> _sync() async {
  final notif = NotificationService.instance;
  final profiles = await sl<GetProfiles>()();
  var screening = false;

  for (final p in profiles) {
    final s = await sl<GetTtdSettings>()(p.id);
    final logs = await sl<GetTtdLogs>()(p.id);
    await notif.applyTtd(
      settings: s,
      profile: p,
      takenDays: logs.keys.toSet(),
    );
    screening = screening || s.weeklyScreening;
  }

  await notif.applyWeeklyScreening(screening);
}