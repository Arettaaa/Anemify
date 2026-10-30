import '../entities/ttd_settings.dart';
import '../repositories/ttd_repository.dart';

class GetTtdSettings {
  final TtdRepository _repo;
  GetTtdSettings(this._repo);
  Future<TtdSettings> call([String? profileId]) => _repo.getSettings(profileId);
}

class SaveTtdSettings {
  final TtdRepository _repo;
  SaveTtdSettings(this._repo);
  Future<void> call(TtdSettings s) => _repo.saveSettings(s);
}

class GetTtdLogs {
  final TtdRepository _repo;
  GetTtdLogs(this._repo);
  Future<Map<String, DateTime>> call([String? profileId]) =>
      _repo.getLogs(profileId);
}

class ClearTtdData {
  final TtdRepository _repo;
  ClearTtdData(this._repo);
  Future<void> call() => _repo.clear();
}

class SetTtdTaken {
  final TtdRepository _repo;
  SetTtdTaken(this._repo);
  Future<void> call(DateTime day, bool taken) => _repo.setTaken(day, taken);
}

/// Kepatuhan bulan [month] (hari terjadwal yang sudah lewat, termasuk hari ini)
/// dan streak berturut-turut hingga hari ini / kemarin.
class CalculateTtdStats {
  const CalculateTtdStats();

  TtdStats call(TtdSettings s, Map<String, DateTime> logs, DateTime month) {
    final today = dayOnly(DateTime.now());

    var scheduled = 0, taken = 0;
    final next = DateTime(month.year, month.month + 1);
    for (var d = DateTime(month.year, month.month);
        d.isBefore(next) && !d.isAfter(today);
        d = addDays(d, 1)) {
      if (s.isScheduled(d)) {
        scheduled++;
        if (logs.containsKey(dateKey(d))) taken++;
      }
    }

    var streak = 0;
    var d = today;
    if (s.isScheduled(d) && !logs.containsKey(dateKey(d))) d = addDays(d, -1);
    for (var i = 0; i < 400 && !d.isBefore(s.startDate); i++) {
      if (s.isScheduled(d)) {
        if (logs.containsKey(dateKey(d))) {
          streak++;
        } else {
          break;
        }
      }
      d = addDays(d, -1);
    }
    return TtdStats(streak, taken, scheduled);
  }
}