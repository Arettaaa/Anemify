import 'package:anemify/features/history/domain/entities/history_entry.dart';

abstract class HistoryRepository {
  Future<int> save(HistoryEntry entry);
  Future<List<HistoryEntry>> getAll();
  Future<HistoryEntry?> getById(int id);
  Future<void> delete(int id);
  Future<void> clear();
}