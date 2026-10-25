# Kontrak Fitur Skrining (Logika ↔ UI)

Dokumen ini menjelaskan cara halaman UI memakai logika skrining Anemify.
UI **tidak perlu** (dan tidak boleh) menyentuh TFLite, preprocessing, atau perhitungan kategori; semuanya lewat `ScanBloc`.

> Pemilik: logika skrining (`lib/features/scan/data`, `lib/features/scan/domain`, `GuideGeometry`, `GuideOverlay`) dikelola Yumna.
> Halaman (`lib/features/scan/presentation/pages`, widget lain) dikelola tim UI.
> Kalau perlu mengubah sesuatu di bagian logika atau dokumen ini, kabari dulu.

---

## 1. Alur singkat

```
Halaman kamera ──(foto utuh)──► ScanBloc ──► potong sesuai panduan ► preprocessing ► 2 model TFLite ► PDR ► ScanResult
                                    ▲                                                                       │
Halaman hasil ◄────────────── ScanState (status, result, failure) ◄─────────────────────────────────────────┘
```

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
| `PalmPhotoCaptured(bytes)` | Setelah foto telapak diambil | **Foto utuh** dari kamera (`Uint8List`). Jangan dipotong/di-resize. |
| `EyePhotoCaptured(bytes)` | Setelah foto mata diambil | **Foto utuh** dari kamera. |
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
| `canSubmit` | `bool` (getter) | `true` kalau tombol "Analisis" boleh aktif |

| `ScanStatus` | Tampilkan |
|---|---|
| `initial`, `loadingModel` | Indikator "Menyiapkan model..." |
| `ready` | Halaman normal (ambil foto / tombol Analisis) |
| `processing` | Indikator "Menganalisis..." (±1–2 detik), tombol dinonaktifkan |
| `success` | Halaman hasil dari `state.result` |
| `failure` | Pesan dari `state.failure` (lihat bagian 6) + tombol ulangi |

## 5. Hasil: `ScanResult`

| Field | Tipe | Arti |
|---|---|---|
| `category` | `RiskCategory` | `rendah`, `perluPerhatian`, `tinggi` → **hasil utama yang ditampilkan** |
| `score` | `double` 0–1 | Skor penentu kategori (gabungan bila dua foto) |
| `palmScore`, `eyeScore` | `double?` | Skor tiap model (null kalau fotonya tidak ada) |
| `usesFusion` | `bool` | `true` kalau dua foto dipakai |
| `warnings` | `List<ScanWarning>` | Peringatan tambahan (lihat di bawah) |

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

**Aturan tampilan hasil:**
- Kategori adalah informasi utama. Skor boleh ditampilkan sebagai informasi tambahan dengan label **"skor risiko skrining"** (bukan "probabilitas anemia").
- **Selalu** tampilkan disclaimer: *"Anemify adalah alat skrining awal, bukan diagnosis. Hasil tidak menggantikan pemeriksaan hemoglobin oleh tenaga kesehatan."*
- Jangan menghitung ulang atau mengubah kategori di UI.

## 6. Kegagalan: `ScanFailureType`

| Nilai | Saran pesan |
|---|---|
| `noPhoto` | "Ambil minimal satu foto (telapak atau mata) terlebih dahulu." |
| `invalidImage` | "Foto tidak dapat dibaca. Silakan ambil ulang." |
| `roiTooSmall` | "Area foto tidak cukup jelas. Posisikan sesuai panduan dan ambil ulang." |
| `modelNotReady` | "Model belum siap. Tunggu sebentar lalu coba lagi." |
| `unknown` | "Terjadi kesalahan. Silakan coba lagi." |

## 7. Halaman kamera (WAJIB diikuti)

Area yang dianalisis dipotong **persis** sesuai bentuk panduan. Agar yang dilihat pengguna sama dengan yang dipotong:

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
   - Mata: "Pegang HP ±15–20 cm. Tarik kelopak mata bawah, lalu posisikan garis merah muda di dalam sabit tipis. Gunakan cahaya terang, tanpa flash."

Contoh lengkap yang sudah teruji: `presentation/pages/debug_camera_page.dart`.

## 8. Jangan

- Jangan memotong, me-resize, mengubah warna, atau mengompresi foto di UI.
- Jangan memuat model TFLite atau membaca `fusion_config.json` dari UI.
- Jangan mengubah `GuideGeometry` tanpa koordinasi (unit test akan gagal, dan hasil potongan berubah).
- Jangan menulis "probabilitas anemia" atau "diagnosis" di teks UI.

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
        return PesanGagal(type: s.failure!);
      case ScanStatus.ready:
        return FilledButton(
          onPressed: s.canSubmit ? () => context.read<ScanBloc>().add(const ScanSubmitted()) : null,
          child: const Text('Analisis'),
        );
    }
  },
)
```

## 10. Akan ditambahkan (kontrak diperbarui)

- **Cek kualitas foto:** jenis kegagalan baru di `ScanFailureType` (mis. terlalu gelap, terlalu terang, blur, warna tidak wajar) beserta saran pesannya.
- **Riwayat skrining:** entity dan cara menyimpan/membaca riwayat untuk halaman Riwayat.

## 11. Koordinasi Git

- Kerja langsung di `main`: `git pull` sebelum mulai dan sebelum `push`.
- `lib/main.dart` rawan konflik: sepakati satu orang yang mengubahnya. Saat ini `home` masih halaman debug (`DebugParityPage`); ganti ke beranda saat sudah siap, lalu aktifkan lagi test di `test/widget_test.dart` (hapus `skip: true`).
