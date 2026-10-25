import 'package:anemify/features/history/data/datasources/history_local_datasource.dart';
import 'package:anemify/features/history/data/repositories/history_repository_impl.dart';
import 'package:anemify/features/history/domain/entities/history_entry.dart';
import 'package:anemify/features/scan/domain/entities/risk_category.dart';
import 'package:anemify/features/scan/domain/entities/scan_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late HistoryLocalDataSource ds;
  late HistoryRepositoryImpl repo;

  setUp(() {
    ds = HistoryLocalDataSource(dbPath: inMemoryDatabasePath);
    repo = HistoryRepositoryImpl(ds);
  });
  tearDown(() => ds.close());

  HistoryEntry entry(DateTime t, {RiskCategory c = RiskCategory.tinggi}) => HistoryEntry(
        createdAt: t,
        category: c,
        score: 0.9,
        palmScore: 0.8,
        eyeScore: 0.7,
        usesFusion: true,
        warnings: const [ScanWarning.inconsistent],
      );

  test('simpan lalu baca, semua field kembali utuh', () async {
    final id = await repo.save(entry(DateTime(2026, 10, 25, 15)));
    final got = (await repo.getById(id))!;
    expect(got.category, RiskCategory.tinggi);
    expect(got.score, 0.9);
    expect(got.palmScore, 0.8);
    expect(got.eyeScore, 0.7);
    expect(got.usesFusion, isTrue);
    expect(got.warnings, [ScanWarning.inconsistent]);
    expect(got.createdAt, DateTime(2026, 10, 25, 15));
  });

  test('getAll urut dari terbaru', () async {
    await repo.save(entry(DateTime(2026, 10, 1)));
    await repo.save(entry(DateTime(2026, 10, 3)));
    await repo.save(entry(DateTime(2026, 10, 2)));
    final all = await repo.getAll();
    expect(all.map((e) => e.createdAt.day), [3, 2, 1]);
  });

  test('skor opsional boleh null & warnings kosong', () async {
    final id = await repo.save(HistoryEntry(
      createdAt: DateTime(2026, 10, 25),
      category: RiskCategory.rendah,
      score: 0.2,
      palmScore: 0.2,
    ));
    final got = (await repo.getById(id))!;
    expect(got.eyeScore, isNull);
    expect(got.warnings, isEmpty);
  });

  test('delete & clear', () async {
    final a = await repo.save(entry(DateTime(2026, 10, 1)));
    await repo.save(entry(DateTime(2026, 10, 2)));
    await repo.delete(a);
    expect((await repo.getAll()).length, 1);
    await repo.clear();
    expect(await repo.getAll(), isEmpty);
  });
}