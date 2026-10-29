import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _ds;
  ProfileRepositoryImpl(this._ds);

  @override
  Future<List<Profile>> getAll() => _ds.getAll();

  @override
  Future<Profile?> getActive() async {
    final all = await _ds.getAll();
    if (all.isEmpty) return null;
    final id = await _ds.getActiveId();
    return all.firstWhere((p) => p.id == id, orElse: () => all.first);
  }

  @override
  Future<void> add(Profile profile, {bool setActive = false}) async {
    final all = await _ds.getAll();
    await _ds.saveAll([...all, profile]);
    if (setActive || all.isEmpty) await _ds.setActiveId(profile.id);
  }

  @override
  Future<void> update(Profile profile) async {
    final all = await _ds.getAll();
    await _ds.saveAll([for (final p in all) p.id == profile.id ? profile : p]);
  }

  @override
  Future<void> setActive(String id) => _ds.setActiveId(id);

  @override
  Future<void> delete(String id) async {
    final all = await _ds.getAll();
    final rest = all.where((p) => p.id != id).toList();
    await _ds.saveAll(rest);
    final activeId = await _ds.getActiveId();
    if (activeId == id && rest.isNotEmpty) {
      await _ds.setActiveId(rest.first.id);
    }
  }
}