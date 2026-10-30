import '../../domain/entities/ttd_settings.dart';
import '../../domain/repositories/ttd_repository.dart';
import '../datasources/ttd_local_datasource.dart';

class TtdRepositoryImpl implements TtdRepository {
  final TtdLocalDataSource _ds;
  TtdRepositoryImpl(this._ds);

  @override
  Future<TtdSettings> getSettings([String? profileId]) =>
      _ds.getSettings(profileId);

  @override
  Future<void> saveSettings(TtdSettings settings) => _ds.saveSettings(settings);
  
  @override
  Future<Map<String, DateTime>> getLogs([String? profileId]) =>
      _ds.getLogs(profileId);

  @override
  Future<void> setTaken(DateTime day, bool taken) => _ds.setTaken(day, taken);

  @override
  Future<void> clear() => _ds.clear();
}