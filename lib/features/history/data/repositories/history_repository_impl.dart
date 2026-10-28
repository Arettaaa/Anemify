import 'package:anemify/features/history/data/datasources/history_local_datasource.dart';
import 'package:anemify/features/history/domain/entities/history_entry.dart';
import 'package:anemify/features/history/domain/repositories/history_repository.dart';
import 'package:anemify/features/profile/domain/repositories/profile_repository.dart';

/// Semua operasi otomatis memakai profil yang sedang aktif.
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource _ds;
  final ProfileRepository _profiles;
  bool _orphansClaimed = false;

  HistoryRepositoryImpl(this._ds, this._profiles);

  Future<String?> _activeId() async => (await _profiles.getActive())?.id;

  @override
  Future<int> save(HistoryEntry entry) async {
    final pid = entry.profileId ?? await _activeId();
    return _ds.insert(entry.copyWith(profileId: pid));
  }

  @override
  Future<List<HistoryEntry>> getAll() async {
    final pid = await _activeId();
    if (pid == null) return [];
    if (!_orphansClaimed) {
      await _ds.claimOrphans(pid);
      _orphansClaimed = true;
    }
    return _ds.getAll(pid);
  }

  @override
  Future<HistoryEntry?> getById(int id) => _ds.getById(id);

  @override
  Future<void> delete(int id) => _ds.delete(id);

  @override
  Future<void> clear() async {
    final pid = await _activeId();
    if (pid != null) await _ds.clear(pid);
  }
}