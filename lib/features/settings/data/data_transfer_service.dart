import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../history/data/datasources/history_local_datasource.dart';
import '../../history/domain/entities/history_entry.dart';
import '../../profile/domain/entities/profile.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import '../../scan/domain/entities/risk_category.dart';
import '../../scan/domain/entities/scan_result.dart';
import '../../ttd/domain/repositories/ttd_repository.dart';

/// Hasil impor, untuk ditampilkan ke pengguna.
class ImportSummary {
  final int profilesAdded;
  final int historyAdded;
  final int historySkipped; // sudah ada (dedup)
  final int ttdDays;
  const ImportSummary({
    required this.profilesAdded,
    required this.historyAdded,
    required this.historySkipped,
    required this.ttdDays,
  });
}

/// Ekspor & impor data lokal (SEMUA profil, bukan hanya yang aktif).
///
/// Format cadangan .json (version 1):
/// {
///   "app": "anemify", "version": 1, "exportedAt": ISO8601,
///   "profiles":  [{id, name, age, sex, pregnant}],
///   "history":   [{profileId, createdAt, category, score,
///                  palmScore, eyeScore, usesFusion, warnings}],
///   "ttdLogs":   {profileId: {"YYYY-MM-DD": epochMillis}}
/// }
/// Pengaturan pengingat TTD sengaja TIDAK ikut: itu preferensi perangkat,
/// bukan data kesehatan, dan diatur ulang di perangkat baru.
class DataTransferService {
  final ProfileRepository _profiles;
  final HistoryLocalDataSource _historyDs;
  final TtdRepository _ttd;

  DataTransferService(this._profiles, this._historyDs, this._ttd);

  // ---------- EKSPOR ----------

  Future<bool> hasAnyData() async {
    for (final p in await _profiles.getAll()) {
      if ((await _historyDs.getAll(p.id)).isNotEmpty) return true;
      if ((await _ttd.getLogs(p.id)).isNotEmpty) return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> buildPayload() async {
    final profiles = await _profiles.getAll();
    final history = <Map<String, dynamic>>[];
    final ttdLogs = <String, Map<String, int>>{};

    for (final p in profiles) {
      for (final h in await _historyDs.getAll(p.id)) {
        history.add({
          'profileId': p.id,
          'createdAt': h.createdAt.toIso8601String(),
          'category': h.category.name,
          'score': h.score,
          'palmScore': h.palmScore,
          'eyeScore': h.eyeScore,
          'usesFusion': h.usesFusion,
          'warnings': [for (final w in h.warnings) w.name],
        });
      }
      final logs = await _ttd.getLogs(p.id);
      if (logs.isNotEmpty) {
        ttdLogs[p.id] =
            logs.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch));
      }
    }

    return {
      'app': 'anemify',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profiles': [
        for (final p in profiles)
          {
            'id': p.id,
            'name': p.name,
            'age': p.age,
            'sex': p.sex.name,
            'pregnant': p.pregnant,
          },
      ],
      'history': history,
      'ttdLogs': ttdLogs,
    };
  }

  /// Tulis cadangan .json ke berkas sementara; bagikan lewat share sheet.
  Future<File> writeJsonFile(String fileName) async {
    final payload = await buildPayload();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    return file;
  }

  // ---------- IMPOR ----------

  Future<ImportSummary> importFromJson(String raw) async {
    final Map<String, dynamic> j;
    try {
      j = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Berkas bukan JSON yang valid.');
    }
    if (j['app'] != 'anemify') {
      throw const FormatException('Berkas ini bukan cadangan Anemify.');
    }
    if (j['version'] != 1) {
      throw FormatException(
          'Versi cadangan (${j['version']}) tidak dikenali aplikasi ini.');
    }

    // 1. Profil: tambah yang belum ada (dicocokkan lewat id).
    final existing = await _profiles.getAll();
    final knownIds = {for (final p in existing) p.id};
    var profilesAdded = 0;
    for (final e in (j['profiles'] as List? ?? const [])) {
      final m = e as Map<String, dynamic>;
      final id = m['id'] as String;
      if (knownIds.contains(id)) continue;
      await _profiles.add(Profile(
        id: id,
        name: m['name'] as String,
        age: m['age'] as int,
        sex: Sex.values.firstWhere((s) => s.name == m['sex'],
            orElse: () => Sex.perempuan),
        pregnant: (m['pregnant'] as bool?) ?? false,
      ));
      knownIds.add(id);
      profilesAdded++;
    }

    // 2. Riwayat: dedup per (profil, waktu, skor) supaya impor ulang aman.
    final activeId = (await _profiles.getActive())?.id;
    final seen = <String>{};
    for (final id in knownIds) {
      for (final h in await _historyDs.getAll(id)) {
        seen.add('$id|${h.createdAt.millisecondsSinceEpoch}|${h.score}');
      }
    }
    var added = 0, skipped = 0;
    for (final e in (j['history'] as List? ?? const [])) {
      final m = e as Map<String, dynamic>;
      var pid = m['profileId'] as String?;
      if (pid == null || !knownIds.contains(pid)) pid = activeId;
      if (pid == null) continue;
      final createdAt = DateTime.parse(m['createdAt'] as String);
      final score = (m['score'] as num).toDouble();
      final key = '$pid|${createdAt.millisecondsSinceEpoch}|$score';
      if (!seen.add(key)) {
        skipped++;
        continue;
      }
      await _historyDs.insert(HistoryEntry(
        profileId: pid,
        createdAt: createdAt,
        category: RiskCategory.values.firstWhere(
            (c) => c.name == m['category'],
            orElse: () => RiskCategory.perluPerhatian),
        score: score,
        palmScore: (m['palmScore'] as num?)?.toDouble(),
        eyeScore: (m['eyeScore'] as num?)?.toDouble(),
        usesFusion: (m['usesFusion'] as bool?) ?? false,
        warnings: [
          for (final n in (m['warnings'] as List? ?? const []))
            ...ScanWarning.values.where((w) => w.name == n),
        ],
      ));
      added++;
    }

    // 3. Log TTD: digabung, catatan di perangkat ini menang.
    var ttdDays = 0;
    final ttdMap = j['ttdLogs'] as Map<String, dynamic>? ?? const {};
    for (final entry in ttdMap.entries) {
      if (!knownIds.contains(entry.key)) continue;
      final logs = (entry.value as Map<String, dynamic>).map((k, v) =>
          MapEntry(k, DateTime.fromMillisecondsSinceEpoch(v as int)));
      await _ttd.restoreLogs(entry.key, logs);
      ttdDays += logs.length;
    }

    return ImportSummary(
      profilesAdded: profilesAdded,
      historyAdded: added,
      historySkipped: skipped,
      ttdDays: ttdDays,
    );
  }

  // ---------- PDF RINGKASAN ----------

  /// PDF ringkasan seluruh profil: identitas + tabel riwayat + jumlah TTD.
  Future<Uint8List> buildSummaryPdf() async {
    final profiles = await _profiles.getAll();
    final perProfile = <(Profile, List<HistoryEntry>, int)>[];
    for (final p in profiles) {
      perProfile.add((
        p,
        await _historyDs.getAll(p.id),
        (await _ttd.getLogs(p.id)).length,
      ));
    }

    const red = PdfColor.fromInt(0xFFEA3D4A);
    const grey = PdfColor.fromInt(0xFF6B7280);
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    String tgl(DateTime d) =>
        '${two(d.day)}-${two(d.month)}-${d.year} ${two(d.hour)}.${two(d.minute)}';
    String persen(double? v) => v == null ? '-' : '${(v * 100).round()}%';
    String kategori(RiskCategory c) => switch (c) {
          RiskCategory.rendah => 'Rendah',
          RiskCategory.perluPerhatian => 'Perhatian',
          RiskCategory.tinggi => 'Tinggi',
        };

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 36),
      build: (ctx) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('anemify.',
                style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: red)),
            pw.Spacer(),
            pw.Text('RINGKASAN DATA - ${tgl(now)} WIB',
                style: const pw.TextStyle(fontSize: 9, color: grey)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: 2, color: red),
        pw.SizedBox(height: 14),
        pw.Text(
          'Dokumen ini adalah ringkasan data skrining yang tersimpan di '
          'perangkat pengguna. Skor adalah skor risiko skrining, BUKAN kadar '
          'hemoglobin (Hb), dan bukan diagnosis medis.',
          style: const pw.TextStyle(fontSize: 9, color: grey),
        ),
        pw.SizedBox(height: 14),
        for (final (p, entries, ttdCount) in perProfile) ...[
          pw.Text('${p.name} - ${p.age} tahun - ${p.sex.label}'
              '${p.isPregnant ? ' - Hamil' : ''}',
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (entries.isEmpty)
            pw.Text('Belum ada riwayat skrining.',
                style: const pw.TextStyle(fontSize: 9, color: grey))
          else
            pw.TableHelper.fromTextArray(
              headers: const [
                'Tanggal',
                'Kategori',
                'Skor',
                'Konjungtiva',
                'Telapak'
              ],
              data: [
                for (final h in entries)
                  [
                    tgl(h.createdAt),
                    kategori(h.category),
                    persen(h.score),
                    persen(h.eyeScore),
                    persen(h.palmScore),
                  ],
              ],
              headerStyle: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: red),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            ),
          pw.SizedBox(height: 6),
          pw.Text('Catatan konsumsi TTD: $ttdCount hari tercatat.',
              style: const pw.TextStyle(fontSize: 9, color: grey)),
          pw.SizedBox(height: 14),
        ],
        pw.Divider(color: grey, thickness: 0.5),
        pw.Text(
          'Dokumen dibuat otomatis oleh aplikasi Anemify untuk keperluan '
          'cadangan/konsultasi. Untuk memulihkan data ke perangkat lain, '
          'gunakan file cadangan .json.',
          style: const pw.TextStyle(fontSize: 8, color: grey),
        ),
      ],
    ));

    return doc.save();
  }
}
