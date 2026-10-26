# Kontrak Fitur Skrining (Logika ↔ UI)

Dokumen ini menjelaskan cara halaman UI memakai logika skrining Anemify.
UI **tidak perlu** (dan tidak boleh) menyentuh TFLite, preprocessing, cek kualitas, atau perhitungan kategori; semuanya lewat `ScanBloc`.

> Pemilik: logika skrining (`lib/features/scan/data`, `lib/features/scan/domain`, `GuideGeometry`, `GuideOverlay`) dikelola Yumna.
> Halaman (`lib/features/scan/presentation/pages`, widget lain) dikelola tim UI.
> Kalau perlu mengubah sesuatu di bagian logika atau dokumen ini, kabari dulu.

---

## 1. Alur singkat

```
Halaman kamera ──(foto utuh)──► ScanBloc ──► potong sesuai panduan ► preprocessing
                                                 ► cek kualitas (gelap/terang/blur)
                                                 ► cek objek (telapak/konjungtiva dikenali?)
                                                 ► 2 model TFLite ► PDR ► ScanResult
                                    ▲                                          │
Halaman hasil ◄──── ScanState (status, result, failure, failedPhoto) ◄─────────┘
```

Setiap foto dicek **sebelum** dianalisis. Kalau satu foto gagal cek, skrining berhenti dengan `status == failure`,
dan `failedPhoto` memberi tahu foto mana yang harus diulang.

## 2. Menyiapkan BLoC

`setupInjection()` sudah dipanggil di `main()`. Di halaman awal alur skrining:

```dart
BlocProvider(
  create: (_) => sl<ScanBloc>()..add(const ScanStarted()),
  child: const HalamanSkrining(),
)
```

Import yang dibutuhkan:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
```

Satu `ScanBloc` dipakai untuk satu sesi skrining (foto telapak + foto mata + hasil). Model dimuat sekali dan tetap ada selama aplikasi hidup.

## 3. Event (yang dikirim UI)

| Event | Kapan dikirim | Catatan |
|---|---|---|
| `ScanStarted()` | Saat alur skrining dibuka | Memuat model. Aman dikirim berulang. |
| `PalmPhotoCaptured(bytes)` | Setelah foto telapak diambil | **Foto utuh** dari kamera (`Uint8List`). Jangan dipotong/di-resize. Mengirim ulang = mengganti foto lama. |
| `EyePhotoCaptured(bytes)` | Setelah foto mata diambil | **Foto utuh** dari kamera. Mengirim ulang = mengganti foto lama. |
| `ScanSubmitted()` | Tombol "Analisis" ditekan | Boleh dengan satu foto atau dua foto. |
| `ScanReset()` | Mulai skrining baru | Menghapus foto & hasil; model tetap termuat. |

Contoh: `context.read<ScanBloc>().add(PalmPhotoCaptured(bytes));`

## 4. State (yang dibaca UI)

| Field | Tipe | Arti |
|---|---|---|
| `status` | `ScanStatus` | Lihat tabel di bawah |
| `modelReady` | `bool` | Model sudah termuat |
| `palmPhoto`, `eyePhoto` | `Uint8List?` | Foto yang sudah diambil (untuk pratinjau) |
| `result` | `ScanResult?` | Terisi saat `status == success` |
| `failure` | `ScanFailureType?` | Terisi saat `status == failure` |
| `failedPhoto` | `ScanPhotoKind?` | `palm` / `eye` = foto yang harus diulang; `null` = tidak spesifik |
| `failedMetrics` | `QualityMetrics?` | **Khusus debug.** UI biasa abaikan. |
| `canSubmit` | `bool` (getter) | `true` kalau tombol "Analisis" boleh aktif |

| `ScanStatus` | Tampilkan |
|---|---|
| `initial`, `loadingModel` | Indikator "Menyiapkan model..." |
| `ready` | Halaman normal (ambil foto / tombol Analisis) |
| `processing` | Indikator "Menganalisis..." (±2–3 detik), tombol dinonaktifkan |
| `success` | Halaman hasil dari `state.result` |
| `failure` | Pesan dari `state.failure` (lihat bagian 6) + tombol **ulangi foto yang gagal** |

Saat `failure` dengan `failedPhoto != null`: arahkan pengguna memotret ulang **foto itu saja** (kirim `PalmPhotoCaptured`/`EyePhotoCaptured` baru),
foto lain tidak perlu diulang. Lalu kirim `ScanSubmitted()` lagi.

## 5. Hasil: `ScanResult`

| Field | Tipe | Arti |
|---|---|---|
| `category` | `RiskCategory` | `rendah`, `perluPerhatian`, `tinggi` → **hasil utama yang ditampilkan** |
| `score` | `double` 0–1 | Skor penentu kategori (gabungan bila dua foto) |
| `palmScore`, `eyeScore` | `double?` | Skor tiap model (null kalau fotonya tidak ada) |
| `usesFusion` | `bool` | `true` kalau dua foto dipakai |
| `warnings` | `List<ScanWarning>` | Peringatan tambahan (lihat di bawah). Bisa lebih dari satu. |
| `palmQuality`, `eyeQuality` | `QualityMetrics?` | **Khusus debug.** UI biasa abaikan. |

**Teks kategori** (sama dengan `assets/config/fusion_config.json`):

| `category` | Judul | Pesan |
|---|---|---|
| `rendah` | Risiko rendah | Tidak ditemukan tanda kuat anemia pada foto. Tetap periksa ke tenaga kesehatan jika ada gejala. |
| `perluPerhatian` | Perlu perhatian | Ada kemungkinan anemia. Disarankan pemeriksaan kadar hemoglobin (Hb). |
| `tinggi` | Risiko tinggi | Tanda anemia cukup kuat. Segera lakukan pemeriksaan kadar hemoglobin (Hb) di fasilitas kesehatan. |

**Peringatan:**

| `ScanWarning` | Arti | Saran pesan |
|---|---|---|
| `inconsistent` | Skor telapak dan mata berbeda jauh | "Hasil foto telapak dan mata tidak konsisten. Sebaiknya ulangi pengambilan foto atau lakukan pemeriksaan Hb." |
| `eyeOnly` | Hanya foto mata yang dipakai | "Hasil dari foto mata saja kurang informatif. Tambahkan foto telapak tangan untuk hasil yang lebih baik." |
| `dullColor` | Warna foto kusam (cahaya kurang) | "Warna foto kurang cerah, hasil mungkin kurang akurat. Sebaiknya foto ulang di tempat yang lebih terang." |
| `atypicalPhoto` | Foto kurang jelas dikenali sebagai telapak/konjungtiva | "Foto kurang jelas terdeteksi sebagai telapak tangan/konjungtiva. Hasil mungkin kurang akurat. Sebaiknya foto ulang sesuai panduan." |

> `atypicalPhoto` saat ini **tidak muncul** (cek objek memakai mode ketat: foto yang kurang dikenali langsung ditolak dengan `notTarget`).
> Tetap siapkan teksnya; mode bisa diubah lewat `assets/config/ood_config.json` tanpa mengubah kode.

**Aturan tampilan hasil:**
- Kategori adalah informasi utama. Skor boleh ditampilkan sebagai informasi tambahan dengan label **"skor risiko skrining"** (bukan "probabilitas anemia").
- **Selalu** tampilkan disclaimer: *"Anemify adalah alat skrining awal, bukan diagnosis. Hasil tidak menggantikan pemeriksaan hemoglobin oleh tenaga kesehatan."*
- Semua peringatan di `warnings` ditampilkan (tidak hanya yang pertama).
- Jangan menghitung ulang atau mengubah kategori di UI.

## 6. Kegagalan: `ScanFailureType`

`{foto}` = "telapak tangan" bila `failedPhoto == ScanPhotoKind.palm`, "mata" bila `ScanPhotoKind.eye`.

| Nilai | Saran pesan |
|---|---|
| `noPhoto` | "Ambil minimal satu foto (telapak atau mata) terlebih dahulu." |
| `invalidImage` | "Foto {foto} tidak dapat dibaca. Silakan ambil ulang." |
| `roiTooSmall` | "Area foto {foto} tidak cukup jelas. Posisikan sesuai panduan dan ambil ulang." |
| `tooDark` | "Foto {foto} terlalu gelap. Pindah ke tempat yang lebih terang (tanpa flash), lalu foto ulang." |
| `tooBright` | "Foto {foto} terlalu terang. Hindari cahaya langsung yang menyilaukan, lalu foto ulang." |
| `blurry` | "Foto {foto} kurang tajam. Tahan HP agar tidak bergerak dan tunggu fokus, lalu foto ulang." |
| `notTarget` (palm) | "Telapak tangan tidak terdeteksi. Buka telapak tangan hingga memenuhi kotak panduan, lalu foto ulang." |
| `notTarget` (eye) | "Konjungtiva tidak terdeteksi. Tarik kelopak mata bawah hingga bagian dalam yang kemerahan memenuhi sabit, lalu foto ulang." |
| `modelNotReady` | "Model belum siap. Tunggu sebentar lalu coba lagi." |
| `unknown` | "Terjadi kesalahan. Silakan coba lagi." |

Fungsi bantu yang disarankan (taruh di widget UI):

```dart
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
```

Import: `import '../../domain/entities/scan_failure.dart';` (berisi `ScanFailureType` dan `ScanPhotoKind`).

## 7. Halaman kamera (WAJIB diikuti)

Area yang dianalisis dipotong **persis** sesuai bentuk panduan.

**Cara paling aman: pakai `GuidedCameraPage`** (`presentation/pages/guided_camera_page.dart`). Halaman ini sudah memenuhi semua aturan di bawah
(preview utuh + `GuideOverlay`, flash mati, fokus ke tengah panduan, kamera depan/belakang, foto utuh) dan sudah diuji di HP.

```dart
final bytes = await Navigator.of(context).push<Uint8List>(
  MaterialPageRoute(builder: (_) => const GuidedCameraPage(isEye: true)));
if (bytes != null) context.read<ScanBloc>().add(EyePhotoCaptured(bytes));
```

Tampilannya boleh diberi gaya (warna, tombol, teks petunjuk lewat parameter `instruction`). Kalau membuat halaman kamera sendiri, aturan berikut wajib diikuti:

1. **Overlay:** pakai `GuideOverlay(isEye: true/false)` dari `presentation/widgets/guide_overlay.dart`.
   Warna/ketebalan garis boleh diubah; **geometri tidak boleh** (geometri ada di `GuideGeometry`).
2. **Preview utuh:** bungkus preview dengan `AspectRatio(aspectRatio: 1 / controller.value.aspectRatio)`, lalu `Stack` berisi `CameraPreview` + `GuideOverlay`.
   **Jangan** memakai `BoxFit.cover`, crop, atau zoom pada preview.
3. **Resolusi:** `ResolutionPreset.high` (atau `veryHigh`), bukan `max`.
4. **Flash mati:** `controller.setFlashMode(FlashMode.off)` setelah `initialize()`.
5. **Kirim foto utuh:** `final f = await controller.takePicture(); final bytes = await f.readAsBytes();` → `PalmPhotoCaptured(bytes)` / `EyePhotoCaptured(bytes)`.
6. **Kamera depan & belakang** keduanya disediakan. Default belakang ("minta bantuan orang lain"), depan untuk pemakaian sendiri.
7. **Petunjuk di layar:**
   - Telapak: "Buka telapak tangan dan posisikan bagian tengahnya di dalam kotak."
   - Mata: "Pegang HP ±15–20 cm. Tarik kelopak mata bawah sampai bagian dalam yang kemerahan terlihat. Isi sabit dengan bagian kemerahan itu saja; bulu mata dan kulit kelopak di luar sabit. Gunakan cahaya terang, tanpa flash."
8. **Disarankan:** tampilkan contoh gambar foto mata yang benar vs salah (kelopak tidak ditarik / bulu mata masuk sabit).
   Dari uji coba, kesalahan paling sering adalah tepi kelopak dan bulu mata ikut masuk sabit → foto ditolak `notTarget`.

Contoh lengkap yang sudah teruji: `presentation/pages/debug_camera_page.dart`.

Foto dari galeri **tidak didukung**: posisi konjungtiva/telapak pada foto galeri tidak diketahui, sehingga hasil potongannya salah.

## 8. Jangan

- Jangan memotong, me-resize, mengubah warna, atau mengompresi foto di UI.
- Jangan memuat model TFLite atau membaca file di `assets/config/` (`fusion_config.json`, `quality_config.json`, `ood_config.json`) dari UI.
- Jangan mengubah `GuideGeometry` tanpa koordinasi (unit test akan gagal, dan hasil potongan berubah).
- Jangan menulis "probabilitas anemia" atau "diagnosis" di teks UI.
- Jangan menampilkan angka metrik kualitas / jarak OOD ke pengguna (khusus debug).

## 9. Contoh minimal

```dart
BlocBuilder<ScanBloc, ScanState>(
  builder: (context, s) {
    switch (s.status) {
      case ScanStatus.initial:
      case ScanStatus.loadingModel:
        return const Center(child: Text('Menyiapkan model...'));
      case ScanStatus.processing:
        return const Center(child: CircularProgressIndicator());
      case ScanStatus.success:
        return HasilSkrining(result: s.result!);
      case ScanStatus.failure:
        return PesanGagal(pesan: pesanGagal(s.failure!, s.failedPhoto), ulangiFoto: s.failedPhoto);
      case ScanStatus.ready:
        return FilledButton(
          onPressed: s.canSubmit ? () => context.read<ScanBloc>().add(const ScanSubmitted()) : null,
          child: const Text('Analisis'),
        );
    }
  },
)
```

## 10. Riwayat skrining

Lokasi: `lib/features/history`. Disimpan lokal (SQLite), tanpa login. Yang disimpan: waktu, kategori, skor gabungan, skor palm, skor mata, peringatan. **Foto tidak disimpan.**
Hanya skrining yang **berhasil** (`status == success`) yang disimpan; skrining yang gagal cek foto tidak masuk riwayat.

Semua lewat `sl` (`core/di/injection.dart`):

| Aksi | Kode |
|---|---|
| Simpan hasil | `await sl<SaveScanToHistory>()(result);` |
| Semua riwayat (terbaru dulu) | `await sl<GetScanHistory>()();` → `List<HistoryEntry>` |
| Satu riwayat | `await sl<GetHistoryEntry>()(id);` → `HistoryEntry?` |
| Hapus satu | `await sl<DeleteHistoryEntry>()(id);` |
| Hapus semua | `await sl<ClearHistory>()();` |

`HistoryEntry`: `id`, `createdAt`, `category`, `score`, `palmScore`, `eyeScore`, `usesFusion`, `warnings`.
`warnings` ikut menyimpan peringatan baru (`dullColor`, `atypicalPhoto`); tampilkan di detail riwayat dengan teks yang sama seperti bagian 5.

**Menyimpan otomatis** (taruh di halaman hasil/kamera, jangan ubah `ScanBloc`):

```dart
BlocListener<ScanBloc, ScanState>(
  listenWhen: (p, c) => p.status != ScanStatus.success && c.status == ScanStatus.success,
  listener: (context, state) {
    final r = state.result;
    if (r != null) sl<SaveScanToHistory>()(r);
  },
  child: ...,
)
```

`listenWhen` memastikan hasil hanya tersimpan sekali per skrining.

## 11. Koordinasi Git

- Setiap fitur di **branch sendiri** (`feature/nama-fitur`), lalu merge sendiri ke `main` setelah `flutter test` lulus:
  ```
  git checkout main
  git pull
  git merge feature/nama-fitur --no-edit
  flutter test
  git push
  git branch -d feature/nama-fitur
  ```
- `git pull` di `main` sebelum membuat branch baru.
- `lib/main.dart` rawan konflik: sepakati satu orang yang mengubahnya. Saat ini `home` masih halaman debug (`DebugParityPage`); ganti ke beranda saat sudah siap, lalu aktifkan lagi test di `test/widget_test.dart` (hapus `skip: true`).
