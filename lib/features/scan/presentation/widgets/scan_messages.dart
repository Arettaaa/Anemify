import '../../domain/entities/risk_category.dart';
import '../../domain/entities/scan_failure.dart';
import '../../domain/entities/scan_result.dart';

const kScanDisclaimer =
    'Anemify adalah alat skrining awal, bukan diagnosis. Hasil tidak '
    'menggantikan pemeriksaan hemoglobin oleh tenaga kesehatan.';

String pesanGagal(ScanFailureType t, ScanPhotoKind? p) {
  final foto = p == ScanPhotoKind.eye ? 'mata' : 'telapak tangan';
  switch (t) {
    case ScanFailureType.noPhoto:
      return 'Ambil minimal satu foto (telapak atau mata) terlebih dahulu.';
    case ScanFailureType.invalidImage:
      return 'Foto $foto tidak dapat dibaca. Silakan ambil ulang.';
    case ScanFailureType.roiTooSmall:
      return 'Area foto $foto tidak cukup jelas. Posisikan sesuai panduan dan ambil ulang.';
    case ScanFailureType.tooDark:
      return 'Foto $foto terlalu gelap. Pindah ke tempat yang lebih terang (tanpa flash), lalu foto ulang.';
    case ScanFailureType.tooBright:
      return 'Foto $foto terlalu terang. Hindari cahaya langsung yang menyilaukan, lalu foto ulang.';
    case ScanFailureType.blurry:
      return 'Foto $foto kurang tajam. Tahan HP agar tidak bergerak dan tunggu fokus, lalu foto ulang.';
    case ScanFailureType.notTarget:
      return p == ScanPhotoKind.eye
          ? 'Konjungtiva tidak terdeteksi. Tarik kelopak mata bawah hingga bagian dalam yang kemerahan memenuhi sabit, lalu foto ulang.'
          : 'Telapak tangan tidak terdeteksi. Buka telapak tangan hingga memenuhi kotak panduan, lalu foto ulang.';
    case ScanFailureType.modelNotReady:
      return 'Model belum siap. Tunggu sebentar lalu coba lagi.';
    case ScanFailureType.unknown:
      return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}

String judulKategori(RiskCategory c) => switch (c) {
      RiskCategory.rendah => 'Risiko rendah',
      RiskCategory.perluPerhatian => 'Perlu perhatian',
      RiskCategory.tinggi => 'Risiko tinggi',
    };

String pesanKategori(RiskCategory c) => switch (c) {
      RiskCategory.rendah =>
        'Tidak ditemukan tanda kuat anemia pada foto. Tetap periksa ke tenaga kesehatan jika ada gejala.',
      RiskCategory.perluPerhatian =>
        'Ada kemungkinan anemia. Disarankan pemeriksaan kadar hemoglobin (Hb).',
      RiskCategory.tinggi =>
        'Tanda anemia cukup kuat. Segera lakukan pemeriksaan kadar hemoglobin (Hb) di fasilitas kesehatan.',
    };

String pesanPeringatan(ScanWarning w) => switch (w) {
      ScanWarning.inconsistent =>
        'Hasil foto telapak dan mata tidak konsisten. Sebaiknya ulangi pengambilan foto atau lakukan pemeriksaan Hb.',
      ScanWarning.eyeOnly =>
        'Hasil dari foto mata saja kurang informatif. Tambahkan foto telapak tangan untuk hasil yang lebih baik.',
      ScanWarning.dullColor =>
        'Warna foto kurang cerah, hasil mungkin kurang akurat. Sebaiknya foto ulang di tempat yang lebih terang.',
      ScanWarning.atypicalPhoto =>
        'Foto kurang jelas terdeteksi sebagai telapak tangan/konjungtiva. Hasil mungkin kurang akurat. Sebaiknya foto ulang sesuai panduan.',
    };