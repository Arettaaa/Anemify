import 'package:anemify/features/history/data/datasources/history_local_datasource.dart';
import 'package:anemify/features/history/domain/entities/history_entry.dart';
import 'package:anemify/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource _ds;
  HistoryRepositoryImpl(this._ds);

  @override
  Future<int> save(HistoryEntry entry) => _ds.insert(entry);

  @override
  Future<List<HistoryEntry>> getAll() => _ds.getAll();

  @override
  Future<HistoryEntry?> getById(int id) => _ds.getById(id);

  @override
  Future<void> delete(int id) => _ds.delete(id);

  @override
  Future<void> clear() => _ds.clear();
}