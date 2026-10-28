import 'package:anemify/features/history/domain/entities/history_entry.dart';
import 'package:anemify/features/scan/domain/entities/risk_category.dart';
import 'package:anemify/features/scan/domain/entities/scan_result.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class HistoryLocalDataSource {
  static const _table = 'scan_history';
  static const _version = 2; // v2: + profile_id

  /// Isi [dbPath] dengan inMemoryDatabasePath untuk test.
  final String? dbPath;
  Database? _db;

  HistoryLocalDataSource({this.dbPath});

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final path =
        dbPath ?? p.join(await getDatabasesPath(), 'anemify_history.db');
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profile_id TEXT,
            created_at INTEGER NOT NULL,
            category TEXT NOT NULL,
            score REAL NOT NULL,
            palm_score REAL,
            eye_score REAL,
            uses_fusion INTEGER NOT NULL DEFAULT 0,
            warnings TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_history_profile ON $_table(profile_id)');
      },
      onUpgrade: (db, oldV, _) async {
        if (oldV < 2) {
          await db.execute('ALTER TABLE $_table ADD COLUMN profile_id TEXT');
          await db.execute(
              'CREATE INDEX idx_history_profile ON $_table(profile_id)');
        }
      },
    );
  }

  Future<int> insert(HistoryEntry e) async {
    final db = await _database;
    return db.insert(_table, _toMap(e));
  }

  /// Data lama (sebelum v2) belum punya profil -> diklaim profil ini.
  Future<void> claimOrphans(String profileId) async {
    final db = await _database;
    await db.update(_table, {'profile_id': profileId},
        where: 'profile_id IS NULL');
  }

  Future<List<HistoryEntry>> getAll(String profileId) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'created_at DESC, id DESC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<HistoryEntry?> getById(int id) async {
    final db = await _database;
    final rows =
        await db.query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : _fromMap(rows.first);
  }

  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear(String profileId) async {
    final db = await _database;
    await db.delete(_table, where: 'profile_id = ?', whereArgs: [profileId]);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Map<String, Object?> _toMap(HistoryEntry e) => {
        'profile_id': e.profileId,
        'created_at': e.createdAt.millisecondsSinceEpoch,
        'category': e.category.name,
        'score': e.score,
        'palm_score': e.palmScore,
        'eye_score': e.eyeScore,
        'uses_fusion': e.usesFusion ? 1 : 0,
        'warnings': e.warnings.map((w) => w.name).join(','),
      };

  HistoryEntry _fromMap(Map<String, Object?> m) {
    final warn = (m['warnings'] as String? ?? '');
    return HistoryEntry(
      id: m['id'] as int,
      profileId: m['profile_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      category: RiskCategory.values.byName(m['category'] as String),
      score: (m['score'] as num).toDouble(),
      palmScore: (m['palm_score'] as num?)?.toDouble(),
      eyeScore: (m['eye_score'] as num?)?.toDouble(),
      usesFusion: (m['uses_fusion'] as int) == 1,
      warnings: warn.isEmpty
          ? const []
          : warn
              .split(',')
              .map((n) => ScanWarning.values.where((w) => w.name == n))
              .where((found) => found.isNotEmpty)
              .map((found) => found.first)
              .toList(),
    );
  }
}