import 'package:anemify/features/history/domain/entities/history_entry.dart';
import 'package:anemify/features/history/domain/repositories/history_repository.dart';
import 'package:anemify/features/scan/domain/entities/scan_result.dart';

class SaveScanToHistory {
  final HistoryRepository _repo;
  SaveScanToHistory(this._repo);
  Future<int> call(ScanResult result) =>
      _repo.save(HistoryEntry.fromScanResult(result));
}

class GetScanHistory {
  final HistoryRepository _repo;
  GetScanHistory(this._repo);
  Future<List<HistoryEntry>> call() => _repo.getAll();
}

class GetHistoryEntry {
  final HistoryRepository _repo;
  GetHistoryEntry(this._repo);
  Future<HistoryEntry?> call(int id) => _repo.getById(id);
}

class DeleteHistoryEntry {
  final HistoryRepository _repo;
  DeleteHistoryEntry(this._repo);
  Future<void> call(int id) => _repo.delete(id);
}

class ClearHistory {
  final HistoryRepository _repo;
  ClearHistory(this._repo);
  Future<void> call() => _repo.clear();
}