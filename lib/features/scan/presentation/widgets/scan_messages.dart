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

/// Penjelasan penolakan foto untuk kartu di halaman ambil foto:
/// judul singkat, apa yang terdeteksi, dan cara memperbaikinya.
({String judul, String alasan, List<String> tips}) alasanTolak(
    ScanFailureType t, ScanPhotoKind? p) {
  final isEye = p == ScanPhotoKind.eye;
  final foto = isEye ? 'mata' : 'telapak tangan';
  final objek = isEye ? 'konjungtiva' : 'telapak tangan';
  return switch (t) {
    ScanFailureType.tooDark => (
        judul: 'Foto terlalu gelap',
        alasan: 'Cahaya pada foto $foto kurang, sehingga warna $objek tidak bisa dinilai.',
        tips: [
          'Pindah ke dekat jendela atau ruangan yang terang.',
          'Jangan pakai flash; cahaya flash membuat warna tidak alami.',
          'Pastikan tidak ada bayangan yang menutupi $objek.',
        ],
      ),
    ScanFailureType.tooBright => (
        judul: 'Foto terlalu terang',
        alasan: 'Sebagian foto $foto terlalu silau, sehingga warna $objek hilang.',
        tips: [
          'Hindari cahaya matahari atau lampu yang langsung mengarah ke kamera.',
          'Matikan flash.',
          'Geser sedikit posisi agar tidak memantulkan cahaya.',
        ],
      ),
    ScanFailureType.blurry => (
        judul: 'Foto kurang tajam',
        alasan: 'Foto $foto buram, biasanya karena HP bergerak atau belum fokus.',
        tips: [
          'Tahan HP dengan dua tangan atau sandarkan siku.',
          'Tunggu kamera fokus (gambar tampak jelas) sebelum menekan tombol.',
          'Bersihkan lensa kamera dengan kain lembut.',
        ],
      ),
    ScanFailureType.notTarget => (
        judul: isEye ? 'Konjungtiva tidak terdeteksi' : 'Telapak tangan tidak terdeteksi',
        alasan: isEye
            ? 'Bagian di dalam frame sabit tidak dikenali sebagai konjungtiva (bagian dalam kelopak mata bawah).'
            : 'Bagian di dalam kotak tidak dikenali sebagai telapak tangan.',
        tips: isEye
            ? [
                'Tarik kelopak mata bawah perlahan sampai bagian dalam yang kemerahan terlihat.',
                'Isi frame sabit hanya dengan bagian kemerahan itu, bukan bola mata atau bulu mata.',
                'Dekatkan HP sekitar 15-20 cm dari mata.',
              ]
            : [
                'Buka telapak tangan dengan santai menghadap kamera.',
                'Posisikan bagian tengah telapak memenuhi kotak panduan.',
                'Pastikan tidak ada benda lain di dalam kotak.',
              ],
      ),
    ScanFailureType.roiTooSmall => (
        judul: 'Area foto terlalu kecil',
        alasan: 'Bagian $objek yang tertangkap di dalam frame terlalu sedikit.',
        tips: [
          'Dekatkan HP sampai $objek memenuhi frame panduan.',
          'Pastikan frame tidak tertutup jari atau benda lain.',
        ],
      ),
    ScanFailureType.invalidImage => (
        judul: 'Foto tidak terbaca',
        alasan: 'File foto $foto rusak atau tidak bisa dibuka.',
        tips: ['Ambil ulang foto dari kamera.'],
      ),
    ScanFailureType.modelNotReady => (
        judul: 'Model belum siap',
        alasan: 'Model analisis masih dimuat, jadi foto belum bisa dicek.',
        tips: ['Tunggu beberapa detik, lalu ambil foto lagi.'],
      ),
    ScanFailureType.noPhoto => (
        judul: 'Belum ada foto',
        alasan: 'Ambil minimal satu foto terlebih dahulu.',
        tips: const [],
      ),
    ScanFailureType.unknown => (
        judul: 'Terjadi kesalahan',
        alasan: 'Foto $foto tidak bisa diproses.',
        tips: ['Coba ambil foto lagi.'],
      ),
  };
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

String saranLanjutan(RiskCategory c) => switch (c) {
      RiskCategory.tinggi =>
        'Kategori ini perlu ditindaklanjuti dengan pemeriksaan di fasilitas '
            'kesehatan. Jangan memulai atau mengubah pengobatan berdasarkan aplikasi.',
      RiskCategory.perluPerhatian =>
        'Lakukan pemeriksaan kadar hemoglobin (Hb). Lengkapi menu dengan sumber '
            'zat besi dan vitamin C, dan ikuti anjuran TTD dari tenaga kesehatan.',
      RiskCategory.rendah =>
        'Lengkapi menu dengan sumber zat besi dan vitamin C. Ikuti anjuran TTD '
            'dari tenaga kesehatan. Periksakan keluhan meski kategori tampak rendah.',
    };