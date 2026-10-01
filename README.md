# Anemify

**Anemify** adalah aplikasi mobile berbasis Flutter yang dikembangkan sebagai alat skrining awal risiko anemia dengan memanfaatkan teknologi **Computer Vision** dan **Machine Learning**.

Anemify menggunakan citra bagian tubuh yang dapat menunjukkan karakteristik visual yang berkaitan dengan anemia, yaitu **telapak tangan dan mata**. Citra yang diambil melalui kamera perangkat akan diproses dan dianalisis menggunakan model Machine Learning yang dijalankan secara langsung pada perangkat menggunakan TensorFlow Lite.

Aplikasi ini juga menyediakan informasi edukasi mengenai anemia serta riwayat hasil skrining sehingga pengguna dapat memantau hasil pemeriksaan sebelumnya.

> **Catatan:** Anemify merupakan alat skrining awal dan bukan alat diagnosis medis. Hasil yang diberikan aplikasi tidak menggantikan pemeriksaan dan diagnosis oleh tenaga kesehatan.

## Tujuan Aplikasi

Anemify dikembangkan untuk menyediakan media skrining anemia yang praktis dan mudah digunakan melalui perangkat mobile.

Tujuan utama Anemify adalah:

1. Membantu pengguna melakukan skrining awal terhadap risiko anemia melalui citra telapak tangan dan mata.
2. Memanfaatkan teknologi Computer Vision dan Machine Learning untuk melakukan analisis citra secara otomatis.
3. Menyediakan hasil skrining yang mudah dipahami oleh pengguna.
4. Menyediakan informasi edukasi mengenai anemia, gejala, faktor risiko, pencegahan, serta pola hidup yang mendukung kesehatan.
5. Menyimpan riwayat hasil skrining agar pengguna dapat melihat hasil pemeriksaan sebelumnya.

## Fitur Aplikasi

### 1. Onboarding

Onboarding merupakan halaman pengenalan yang muncul ketika pengguna pertama kali menggunakan Anemify.

Pada bagian ini pengguna akan diperkenalkan dengan tujuan dan cara kerja aplikasi sebelum masuk ke halaman utama.

Informasi yang diberikan meliputi pengenalan Anemify, fungsi skrining, cara melakukan pengambilan gambar, serta informasi bahwa hasil yang diberikan merupakan skrining awal.

### 2. Profil Pengguna

Fitur profil digunakan untuk menyimpan informasi dasar pengguna.

Informasi profil dapat digunakan untuk memberikan pengalaman penggunaan yang lebih sesuai serta menghubungkan hasil skrining dengan pengguna yang melakukan pemeriksaan.

### 3. Skrining Anemia

Skrining merupakan fitur utama Anemify.

Pengguna dapat melakukan pengambilan gambar melalui kamera perangkat. Citra kemudian diperiksa sebelum masuk ke tahap analisis.

Proses skrining secara umum terdiri dari:

```text
Pengguna
   ↓
Memilih jenis skrining
   ↓
Mengambil gambar
   ↓
Pengecekan kualitas gambar
   ↓
Preprocessing gambar
   ↓
Model Machine Learning
   ↓
Prediksi
   ↓
Hasil skrining
```

Anemify menyediakan dua sumber citra untuk proses skrining:

**Telapak tangan**

Citra telapak tangan digunakan sebagai salah satu sumber informasi visual untuk model pendeteksi risiko anemia.

**Mata**

Citra mata digunakan sebagai sumber citra tambahan untuk melakukan analisis menggunakan model yang telah dikembangkan.

### 4. Pengecekan Kualitas Foto

Sebelum gambar dianalisis oleh model, aplikasi melakukan pengecekan terhadap kualitas gambar.

Pengecekan ini bertujuan memastikan gambar yang digunakan cukup sesuai untuk proses analisis.

Beberapa kondisi yang dapat diperiksa antara lain:

```text
Kejelasan gambar
Pencahayaan
Posisi objek
Area objek yang terlihat
Kesesuaian gambar dengan kebutuhan model
```

Jika gambar tidak memenuhi kondisi yang diperlukan, pengguna dapat diminta mengambil gambar kembali.

### 5. Analisis Menggunakan Machine Learning

Setelah gambar dinyatakan sesuai, gambar akan melalui tahap preprocessing.

Preprocessing pada aplikasi harus mengikuti preprocessing yang digunakan ketika model dikembangkan dan diuji.

Contohnya dapat mencakup:

```text
Input gambar
   ↓
Resize
   ↓
Konversi format warna
   ↓
Normalisasi
   ↓
Tensor input
   ↓
Model TensorFlow Lite
```

Model kemudian menghasilkan output prediksi yang akan diproses kembali oleh aplikasi menjadi informasi yang dapat dipahami pengguna.

### 6. Hasil Skrining

Setelah proses analisis selesai, pengguna akan mendapatkan hasil skrining.

Hasil dapat menampilkan informasi seperti:

```text
Hasil prediksi
Tingkat kepercayaan model
Informasi singkat mengenai hasil
```

Hasil skrining ditampilkan dengan bahasa yang sederhana agar lebih mudah dipahami.

Hasil tersebut digunakan sebagai informasi awal dan tidak digunakan sebagai diagnosis medis.

### 7. Riwayat Skrining

Fitur riwayat digunakan untuk menyimpan hasil skrining yang telah dilakukan pengguna.

Pengguna dapat melihat kembali:

```text
Tanggal skrining
Jenis citra yang digunakan
Hasil skrining
Nilai kepercayaan prediksi
```

Riwayat dapat membantu pengguna melihat hasil pemeriksaan sebelumnya tanpa harus melakukan skrining ulang hanya untuk melihat data lama.

### 8. Edukasi Anemia

Anemify menyediakan halaman edukasi untuk memberikan informasi mengenai anemia.

Materi edukasi dapat mencakup:

```text
Pengertian anemia
Gejala anemia
Faktor risiko
Penyebab anemia
Pencegahan anemia
Pola makan
Sumber zat besi
Informasi kesehatan lainnya
```

Fitur ini bertujuan agar aplikasi tidak hanya memberikan hasil skrining, tetapi juga membantu pengguna memahami anemia secara lebih baik.

### 9. Informasi Makanan

Anemify menyediakan informasi mengenai makanan yang dapat mendukung pemenuhan kebutuhan nutrisi yang berkaitan dengan pencegahan anemia.

Informasi dapat mencakup jenis makanan, kandungan nutrisi, serta penjelasan singkat mengenai manfaatnya.

### 10. Pengaturan

Halaman pengaturan digunakan untuk mengelola konfigurasi dan data aplikasi.

Fitur yang dapat tersedia meliputi:

```text
Pengaturan aplikasi
Pengelolaan data pengguna
Penghapusan riwayat skrining
Pengaturan notifikasi
Informasi aplikasi
```

### 11. Penyimpanan Data

Data hasil skrining dan informasi yang diperlukan aplikasi dapat disimpan secara lokal pada perangkat.

Penyimpanan lokal memungkinkan aplikasi mengakses riwayat skrining tanpa harus selalu bergantung pada koneksi internet.

## Alur Utama Aplikasi

Secara umum, penggunaan Anemify dapat digambarkan sebagai berikut:

```text
┌───────────────┐
│   Onboarding  │
└───────┬───────┘
        ↓
┌───────────────┐
│     Profil    │
└───────┬───────┘
        ↓
┌───────────────┐
│    Beranda    │
└───────┬───────┘
        ↓
┌────────────────────┐
│   Pilih Skrining   │
└─────────┬──────────┘
          ↓
┌────────────────────┐
│    Ambil Gambar    │
└─────────┬──────────┘
          ↓
┌────────────────────┐
│ Cek Kualitas Foto  │
└─────────┬──────────┘
          ↓
┌────────────────────┐
│     Preprocessing  │
└─────────┬──────────┘
          ↓
┌────────────────────┐
│   Model TFLite     │
└─────────┬──────────┘
          ↓
┌────────────────────┐
│   Hasil Skrining   │
└─────────┬──────────┘
          ↓
┌────────────────────┐
│ Simpan ke Riwayat  │
└────────────────────┘
```

Selain melakukan skrining, pengguna dapat mengakses halaman edukasi, makanan, profil, riwayat, dan pengaturan melalui navigasi aplikasi.

## Teknologi yang Digunakan

### Flutter

Flutter digunakan sebagai framework utama untuk membangun aplikasi mobile.

### Dart

Dart digunakan sebagai bahasa pemrograman utama dalam pengembangan aplikasi Flutter.

### TensorFlow Lite

TensorFlow Lite digunakan untuk menjalankan model Machine Learning pada perangkat mobile.

Model yang digunakan disimpan dalam format `.tflite`.

### Computer Vision

Computer Vision digunakan untuk melakukan analisis terhadap citra yang diperoleh melalui kamera perangkat.

### BLoC

BLoC digunakan untuk mengatur state aplikasi, terutama pada proses yang memiliki beberapa kondisi seperti proses pengambilan gambar, preprocessing, proses prediksi, hasil, dan error.

### Clean Architecture

Struktur aplikasi menggunakan pendekatan Clean Architecture untuk memisahkan bagian antarmuka, logika aplikasi, dan pengolahan data.

## Struktur Project

```text
anemify/
│
├── assets/
│   ├── models/
│   │   ├── eye_model.tflite
│   │   └── palm_model.tflite
│   │
│   ├── images/
│   │
│   └── foods/
│
├── lib/
│   ├── core/
│   │   ├── di/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── services/
│   │
│   ├── features/
│   │   ├── onboarding/
│   │   ├── profile/
│   │   ├── scan/
│   │   ├── history/
│   │   ├── ttd/
│   │   ├── education/
│   │   └── settings/
│   │
│   └── main.dart
│
├── test/
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

## Arsitektur Aplikasi

Setiap fitur utama menggunakan pemisahan menjadi tiga bagian:

```text
Presentation
     ↓
Domain
     ↓
Data
```

### Presentation

Berisi bagian aplikasi yang berhubungan langsung dengan tampilan dan interaksi pengguna.

Bagian ini mencakup halaman, widget, serta pengelolaan state menggunakan BLoC.

### Domain

Berisi logika inti aplikasi yang tidak bergantung langsung pada Flutter atau teknologi tertentu.

Bagian ini mencakup entity, repository contract, dan use case.

### Data

Berisi implementasi pengambilan dan penyimpanan data.

Pada fitur skrining, bagian ini menangani interaksi dengan kamera, model TensorFlow Lite, serta sumber data lainnya.

## Alur Arsitektur Fitur Skrining

```text
Scan Page
    ↓
Scan BLoC
    ↓
Classify Anemia Risk
    ↓
Scan Repository
    ↓
TFLite Data Source
    ↓
Palm Model / Eye Model
    ↓
Prediction Result
    ↓
Scan Result
    ↓
Scan BLoC
    ↓
Scan Page
```

## Instalasi dan Menjalankan Project

Pastikan Flutter dan Dart sudah terpasang pada perangkat.

Clone repository:

```bash
git clone <repository-url>
```

Masuk ke folder project:

```bash
cd anemify
```

Install dependencies:

```bash
flutter pub get
```

Periksa konfigurasi Flutter:

```bash
flutter doctor
```

Jalankan aplikasi:

```bash
flutter run
```

Untuk menjalankan aplikasi pada perangkat Android tertentu:

```bash
flutter devices
```

Kemudian:

```bash
flutter run -d <device-id>
```

## Pengembangan Model

Model Machine Learning digunakan untuk melakukan klasifikasi berdasarkan citra yang diberikan kepada aplikasi.

Model yang telah dikembangkan dan diuji kemudian dikonversi ke format TensorFlow Lite sehingga dapat digunakan pada aplikasi Flutter.

Hal penting dalam implementasi model adalah memastikan preprocessing pada aplikasi sama dengan preprocessing yang digunakan ketika model dikembangkan.

Perbedaan ukuran gambar, normalisasi, format warna, susunan channel, atau urutan label dapat memengaruhi hasil prediksi.

## Pengembangan Selanjutnya

Pengembangan Anemify dapat mencakup penyempurnaan model Machine Learning, peningkatan validasi kualitas gambar, penyempurnaan antarmuka pengguna, penambahan materi edukasi, pengembangan riwayat skrining, serta peningkatan pengalaman pengguna.

## Disclaimer

Anemify dikembangkan sebagai aplikasi untuk **skrining awal risiko anemia** dan edukasi kesehatan.

Hasil yang diberikan oleh model Machine Learning bukan merupakan diagnosis medis. Pengguna tetap disarankan melakukan pemeriksaan lebih lanjut kepada tenaga kesehatan apabila memiliki gejala atau kekhawatiran terkait anemia.
