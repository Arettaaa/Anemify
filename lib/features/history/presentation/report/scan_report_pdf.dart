import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../scan/domain/entities/risk_category.dart';
import '../../../scan/presentation/widgets/scan_messages.dart';
import '../../../scan/presentation/widgets/scan_widgets.dart';
import '../../domain/entities/history_entry.dart';
import '../widgets/history_scan_card.dart';

final _primary = PdfColor.fromInt(0xFFEF233C);
final _dark = PdfColor.fromInt(0xFF2B2D42);
final _grey = PdfColor.fromInt(0xFF69758A);
final _line = PdfColor.fromInt(0xFFECEEF2);
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
    .replaceAll(RegExp(r'[^\u0000-\u00FF]'), '');

/// Bangun PDF laporan untuk satu hasil skrining.
Future<Uint8List> buildScanReport(HistoryEntry e, Profile? p) async {
  final now = DateTime.now();
  final c = e.category;
  final (String badge, PdfColor badgeBg, PdfColor badgeFg) = switch (c) {
    RiskCategory.rendah => ('Rendah', _greenSoft, _green),
    RiskCategory.perluPerhatian => ('Perhatian', _amberSoft, _amber),
    RiskCategory.tinggi => ('Tinggi', _primary, _white),
  };

  pw.TextStyle st(double size, {bool bold = false, PdfColor? color}) =>
      pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color ?? _dark,
        lineSpacing: 2,
      );

  String skor(double? v) => v == null ? '-' : '${(v * 100).round()}/100';

  pw.Widget info(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 130,
              child: pw.Text(_t(k), style: st(10, color: _grey)),
            ),
            pw.Expanded(child: pw.Text(_t(v), style: st(10, bold: true))),
          ],
        ),
      );

  pw.Widget heading(String s) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(_t(s), style: st(12, bold: true)),
      );

  pw.Widget scoreRow(String k, String v, {bool last = false}) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: last
            ? null
            : pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: _line)),
              ),
        child: pw.Row(children: [
          pw.Expanded(child: pw.Text(_t(k), style: st(10))),
          pw.Text(v, style: st(10, bold: true)),
        ]),
      );

  final doc = pw.Document(title: 'Laporan Skrining Anemify', author: 'Anemify');
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(44, 40, 44, 36),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.RichText(
                text: pw.TextSpan(children: [
                  pw.TextSpan(text: 'anemify', style: st(22, bold: true)),
                  pw.TextSpan(
                      text: '.', style: st(22, bold: true, color: _primary)),
                ]),
              ),
              pw.Spacer(),
              pw.Text('Laporan Skrining Anemia', style: st(10, color: _grey)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: _line, thickness: 1),
          pw.SizedBox(height: 10),
          info('Nama', p?.name ?? '-'),
          if (p != null) info('Usia', '${p.age} tahun'),
          if (p != null)
            info('Jenis kelamin',
                p.pregnant ? '${p.sex.label} (sedang hamil)' : p.sex.label),
          info('Tanggal skrining',
              '${formatTglPanjang(e.createdAt)}, pukul ${formatJam(e.createdAt)}'),
          info('Foto yang dianalisis', sumberFoto(e)),
          pw.SizedBox(height: 18),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            decoration: pw.BoxDecoration(
              color: _pink,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Column(children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _white,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text('HASIL SKRINING',
                    style: st(8, bold: true, color: _primary)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(_t(judulKategori(c)), style: st(24, bold: true)),
              pw.SizedBox(height: 8),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: badgeBg,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(badge, style: st(9, bold: true, color: badgeFg)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(_t(pesanKategori(c)),
                  textAlign: pw.TextAlign.center,
                  style: st(10, color: _grey)),
              pw.SizedBox(height: 8),
              pw.Text('Skor risiko skrining: ${skor(e.score)}',
                  style: st(9, color: _grey)),
            ]),
          ),
          pw.SizedBox(height: 18),
          heading('Rincian skor'),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _line),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(children: [
              scoreRow('Telapak tangan', skor(e.palmScore)),
              scoreRow('Mata (konjungtiva)', skor(e.eyeScore)),
              scoreRow(e.usesFusion ? 'Gabungan (dipakai)' : 'Skor akhir',
                  skor(e.score),
                  last: true),
            ]),
          ),
          if (e.warnings.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            heading('Catatan'),
            for (final w in e.warnings)
              pw.Bullet(
                  text: _t(pesanPeringatan(w)), style: st(10, color: _grey)),
          ],
          pw.SizedBox(height: 16),
          heading('Langkah selanjutnya'),
          pw.Text(_t(saranLanjutan(c)), style: st(10, color: _grey)),
          pw.Spacer(),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _surface,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(_t(kScanDisclaimer), style: st(9, color: _grey)),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            _t('Dibuat dengan aplikasi Anemify pada ${formatTglPanjang(now)} '
                'pukul ${formatJam(now)}. Foto tidak disimpan. Skor adalah '
                'skor risiko skrining, bukan kadar Hb.'),
            style: st(8, color: _grey),
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
        'Anemify_${who}_${d.year}${two(d.month)}${two(d.day)}_${two(d.hour)}${two(d.minute)}.pdf',
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
          side: const BorderSide(color: AppColors.inactive),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.download_rounded,
            size: 18, color: AppColors.textPrimary),
        label: Text(label, style: scanStyle(size: 15, weight: FontWeight.w700)),
      ),
    );
  }
}