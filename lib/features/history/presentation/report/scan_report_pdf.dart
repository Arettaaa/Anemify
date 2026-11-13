import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../scan/data/models/fusion_config.dart';
import '../../../scan/domain/entities/risk_category.dart';
import '../../../scan/presentation/widgets/scan_messages.dart';
import '../../../scan/presentation/widgets/scan_widgets.dart';
import '../../domain/entities/history_entry.dart';
import '../widgets/history_scan_card.dart';

final _primary = PdfColor.fromInt(0xFFEF233C);
final _primaryDark = PdfColor.fromInt(0xFFAB2B37);
final _dark = PdfColor.fromInt(0xFF2B2D42);
final _grey = PdfColor.fromInt(0xFF69758A);
final _line = PdfColor.fromInt(0xFFD9DDE4);
final _surface = PdfColor.fromInt(0xFFF6F7F9);
final _pink = PdfColor.fromInt(0xFFFFEBEC);
final _white = PdfColor.fromInt(0xFFFFFFFF);
final _green = PdfColor.fromInt(0xFF1B7F3B);
final _greenSoft = PdfColor.fromInt(0xFFC9FBD0);
final _amber = PdfColor.fromInt(0xFF8A4B00);
final _amberSoft = PdfColor.fromInt(0xFFFFF3C4);

/// Font PDF bawaan (Helvetica) hanya Latin-1: ganti karakter lain.
String _t(String s) => s
    .replaceAll('–', '-')
    .replaceAll('—', '-')
    .replaceAll('’', "'")
    .replaceAll('‘', "'")
    .replaceAll('“', '"')
    .replaceAll('”', '"')
    .replaceAll('…', '...')
    .replaceAll('≤', '<=')
    .replaceAll('≥', '>=')
    .replaceAll('·', '-')
    .replaceAll(RegExp(r'[^\u0000-ÿ]'), '');

/// Skor sebagai persen: 0,74 -> "74%".
String _persen(double? v) => v == null ? '-' : '${(v * 100).round()}%';

/// Nomor laporan: ANM-YYYYMMDD-HHMM-ID (ID riwayat bila ada).
String nomorLaporan(HistoryEntry e) {
  String two(int n) => n.toString().padLeft(2, '0');
  final d = e.createdAt;
  final id = e.id?.toString().padLeft(4, '0') ?? 'XXXX';
  return 'ANM-${d.year}${two(d.month)}${two(d.day)}-${two(d.hour)}${two(d.minute)}-$id';
}

/// Ambang kategori yang dipakai (gabungan / palm saja / mata saja) sebagai
/// teks persen, supaya pembaca tahu batas tiap kategori.
({String rendah, String perhatian, String tinggi}) _rentang(
    CategoryThresholds t) {
  final lo = (t.lowMax * 100).round();
  final hi = t.highMin == null ? null : (t.highMin! * 100).round();
  return (
    rendah: '< $lo%',
    perhatian: hi == null ? '>= $lo%' : '$lo% - ${hi - 1}%',
    tinggi: hi == null ? '-' : '>= $hi%',
  );
}

/// Bangun PDF laporan formal untuk satu hasil skrining.
Future<Uint8List> buildScanReport(HistoryEntry e, Profile? p) async {
  final now = DateTime.now();
  final c = e.category;

  CategoryThresholds? thr;
  try {
    final cfg = FusionConfig.fromJsonString(
        await rootBundle.loadString('assets/config/fusion_config.json'));
    thr = e.usesFusion
        ? cfg.fused
        : e.eyeScore != null
            ? cfg.konjOnly
            : cfg.palmOnly;
  } catch (_) {
    // Tanpa config, tabel rentang kategori dilewati.
  }

  final (String badge, PdfColor badgeBg, PdfColor badgeFg) = switch (c) {
    RiskCategory.rendah => ('RENDAH', _greenSoft, _green),
    RiskCategory.perluPerhatian => ('PERLU PERHATIAN', _amberSoft, _amber),
    RiskCategory.tinggi => ('TINGGI', _primary, _white),
  };

  pw.TextStyle st(double size, {bool bold = false, PdfColor? color}) =>
      pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color ?? _dark,
        lineSpacing: 2,
      );

  pw.Widget judulBagian(String s) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const pw.EdgeInsets.only(bottom: 6),
        decoration: pw.BoxDecoration(
          color: _surface,
          border: pw.Border(left: pw.BorderSide(color: _primary, width: 3)),
        ),
        child: pw.Text(_t(s.toUpperCase()),
            style: st(9.5, bold: true, color: _dark)),
      );

  pw.Widget identitas(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(width: 92, child: pw.Text(_t(k), style: st(9, color: _grey))),
            pw.Text(': ', style: st(9, color: _grey)),
            pw.Expanded(child: pw.Text(_t(v), style: st(9, bold: true))),
          ],
        ),
      );

  pw.Widget sel(String s,
          {bool bold = false,
          PdfColor? color,
          PdfColor? bg,
          pw.TextAlign align = pw.TextAlign.left,
          double size = 9}) =>
      pw.Container(
        color: bg,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(_t(s),
            textAlign: align, style: st(size, bold: bold, color: color)),
      );

  pw.TableRow kepala(List<String> cols) => pw.TableRow(
        decoration: pw.BoxDecoration(color: _surface),
        children: [
          for (final s in cols) sel(s, bold: true, color: _grey, size: 8.5),
        ],
      );

  final sumber = sumberFoto(e);
  final r = thr == null ? null : _rentang(thr);
  final namaSkorAkhir = e.usesFusion
      ? 'Skor gabungan (mata + telapak)'
      : e.eyeScore != null
          ? 'Skor akhir (foto mata)'
          : 'Skor akhir (foto telapak)';

  final doc = pw.Document(
    title: 'Laporan Hasil Skrining Anemia - Anemify',
    author: 'Anemify',
    subject: nomorLaporan(e),
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 34, 40, 30),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ===== Kop laporan =====
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(children: [
                      pw.TextSpan(text: 'anemify', style: st(20, bold: true)),
                      pw.TextSpan(
                          text: '.', style: st(20, bold: true, color: _primary)),
                    ]),
                  ),
                  pw.Text(
                    'Skrining anemia non-invasif berbasis foto konjungtiva dan telapak tangan',
                    style: st(8, color: _grey),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('LAPORAN HASIL SKRINING',
                      style: st(11, bold: true, color: _primaryDark)),
                  pw.SizedBox(height: 2),
                  pw.Text('No. ${nomorLaporan(e)}', style: st(8.5, color: _grey)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(height: 3, color: _primary),
          pw.Container(height: 1, color: _line),
          pw.SizedBox(height: 12),

          // ===== Identitas =====
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _line),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            padding: const pw.EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      identitas('Nama', p?.name ?? '-'),
                      identitas('Usia', p == null ? '-' : '${p.age} tahun'),
                      identitas(
                          'Jenis kelamin',
                          p == null
                              ? '-'
                              : p.isPregnant
                                  ? '${p.sex.label} (sedang hamil)'
                                  : p.sex.label),
                      identitas('Kelompok', p?.category ?? '-'),
                    ],
                  ),
                ),
                pw.Container(width: 1, height: 58, color: _line),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      identitas('Tanggal skrining', formatTglPanjang(e.createdAt)),
                      identitas('Waktu', '${formatJam(e.createdAt)} WIB'),
                      identitas('Foto dianalisis', sumber),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // ===== Hasil =====
          judulBagian('Hasil skrining'),
          pw.Table(
            border: pw.TableBorder.all(color: _line, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(3.2),
              1: pw.FlexColumnWidth(1.3),
              2: pw.FlexColumnWidth(2.2),
              3: pw.FlexColumnWidth(3.3),
            },
            children: [
              kepala(const ['Pemeriksaan', 'Hasil', 'Kategori', 'Keterangan']),
              pw.TableRow(children: [
                sel('Konjungtiva mata'),
                sel(_persen(e.eyeScore), bold: true, align: pw.TextAlign.center),
                sel(e.eyeScore == null ? '-' : 'skor per foto', color: _grey),
                sel(e.eyeScore == null
                    ? 'Tidak difoto'
                    : 'Skor risiko dari warna konjungtiva (bagian dalam kelopak mata bawah)'),
              ]),
              pw.TableRow(children: [
                sel('Telapak tangan'),
                sel(_persen(e.palmScore), bold: true, align: pw.TextAlign.center),
                sel(e.palmScore == null ? '-' : 'skor per foto', color: _grey),
                sel(e.palmScore == null
                    ? 'Tidak difoto'
                    : 'Skor risiko dari warna telapak tangan (palmar pallor)'),
              ]),
              pw.TableRow(
                decoration: pw.BoxDecoration(color: _pink),
                children: [
                  sel(namaSkorAkhir, bold: true),
                  sel(_persen(e.score),
                      bold: true, align: pw.TextAlign.center, color: _primaryDark, size: 11),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Container(
                      padding:
                          const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: badgeBg,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(badge, style: st(8, bold: true, color: badgeFg)),
                    ),
                  ),
                  sel(e.usesFusion
                      ? 'Gabungan dua foto dengan aturan product decision rule; skor inilah yang menentukan kategori'
                      : 'Skor inilah yang menentukan kategori'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            _t('Hasil dinyatakan sebagai skor risiko skrining dalam persen (0-100%), '
                'yaitu perkiraan kemungkinan anemia menurut model dari foto yang diambil. '
                'Skor ini BUKAN kadar hemoglobin (Hb) dan bukan hasil pemeriksaan darah.'),
            style: st(8, color: _grey),
          ),
          pw.SizedBox(height: 12),

          // ===== Interpretasi =====
          judulBagian('Interpretasi kategori'),
          pw.Table(
            border: pw.TableBorder.all(color: _line, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.8),
              1: pw.FlexColumnWidth(1.3),
              2: pw.FlexColumnWidth(6.9),
            },
            children: [
              kepala(const ['Kategori', 'Rentang skor', 'Arti dan tindak lanjut']),
              for (final k in RiskCategory.values)
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: k == c ? _pink : null),
                  children: [
                    sel(judulKategori(k), bold: k == c),
                    sel(
                      r == null
                          ? '-'
                          : switch (k) {
                              RiskCategory.rendah => r.rendah,
                              RiskCategory.perluPerhatian => r.perhatian,
                              RiskCategory.tinggi => r.tinggi,
                            },
                      align: pw.TextAlign.center,
                      bold: k == c,
                    ),
                    sel('${pesanKategori(k)} ${saranLanjutan(k)}', size: 8.5),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _t('Baris yang diarsir adalah kategori hasil skrining ini. Rentang skor '
                'mengikuti ambang untuk ${sumber.toLowerCase()}.'),
            style: st(8, color: _grey),
          ),

          // ===== Catatan =====
          if (e.warnings.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            judulBagian('Catatan hasil'),
            for (final w in e.warnings)
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 4, bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('- ', style: st(9)),
                    pw.Expanded(child: pw.Text(_t(pesanPeringatan(w)), style: st(9))),
                  ],
                ),
              ),
          ],

          // ===== Keterangan =====
          pw.SizedBox(height: 12),
          judulBagian('Keterangan'),
          for (final (i, s) in const [
            'Anemify adalah alat skrining awal, bukan alat diagnosis. Hasil tidak menggantikan pemeriksaan hemoglobin (Hb) oleh tenaga kesehatan.',
            'Skor dihitung oleh model pembelajaran mesin dari warna area konjungtiva dan telapak tangan pada foto. Pencahayaan, kamera, dan warna kulit dapat memengaruhi hasil.',
            'Foto diproses sepenuhnya di perangkat dan tidak disimpan maupun dikirim ke server. Riwayat hanya menyimpan kategori dan skor.',
            'Hasil risiko rendah tidak menyingkirkan anemia. Bila ada keluhan (lemas, pucat, pusing, sesak), konsultasikan kebutuhan pemeriksaan darah.',
          ].indexed)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 4, bottom: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(width: 12, child: pw.Text('${i + 1}.', style: st(8.5, color: _grey))),
                  pw.Expanded(child: pw.Text(_t(s), style: st(8.5, color: _grey))),
                ],
              ),
            ),

          pw.Spacer(),

          // ===== Verifikasi (opsional) + tanda tangan =====
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: _surface,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    _t('Laporan ini dibuat otomatis oleh aplikasi Anemify pada '
                        '${formatTglPanjang(now)} pukul ${formatJam(now)} WIB dan sah '
                        'tanpa tanda tangan. Bawa laporan ini saat memeriksakan diri '
                        'agar tenaga kesehatan dapat menilai kebutuhan pemeriksaan Hb.'),
                    style: st(7.5, color: _grey),
                  ),
                ),
              ),
              pw.SizedBox(width: 14),
              pw.Container(
                width: 150,
                padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _line),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text('Anemify - skrining anemia di genggaman', style: st(7.5, color: _grey)),
              pw.Spacer(),
              pw.Text('Halaman 1 dari 1', style: st(7.5, color: _grey)),
            ],
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

/// Buat PDF lalu buka menu share Android (simpan ke File/Drive, kirim WA, dll).
Future<void> shareScanReport(HistoryEntry e) async {
  final profile = await sl<GetActiveProfile>()();
  final bytes = await buildScanReport(e, profile);
  String two(int n) => n.toString().padLeft(2, '0');
  final d = e.createdAt;
  final who = (profile?.name ?? 'anemify')
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
  await Printing.sharePdf(
    bytes: bytes,
    filename:
        'Laporan_Anemify_${who}_${d.year}${two(d.month)}${two(d.day)}_${two(d.hour)}${two(d.minute)}.pdf',
  );
}

/// Tombol "Unduh laporan PDF" dengan status loading.
class ReportPdfButton extends StatefulWidget {
  final HistoryEntry entry;
  final bool outlined;

  const ReportPdfButton({
    super.key,
    required this.entry,
    this.outlined = false,
  });

  @override
  State<ReportPdfButton> createState() => _ReportPdfButtonState();
}

class _ReportPdfButtonState extends State<ReportPdfButton> {
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      await shareScanReport(widget.entry);
    } catch (_) {
      if (mounted) {
        showAppToast(context, 'Laporan PDF gagal dibuat. Coba lagi.',
            type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _busy ? 'Menyiapkan PDF…' : 'Unduh laporan PDF';
    if (!widget.outlined) {
      return ScanPrimaryButton(
        label: label,
        icon: Icons.download_rounded,
        iconAfter: false,
        onPressed: _busy ? null : _run,
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _busy ? null : _run,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.primarySoft),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.download_rounded,
            size: 18, color: AppColors.primary),
        label: Text(label,
            style: scanStyle(
                size: 15, weight: FontWeight.w700, color: AppColors.primary)),
      ),
    );
  }
}
