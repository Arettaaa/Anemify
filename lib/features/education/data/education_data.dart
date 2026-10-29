import 'models/article_model.dart';
import 'models/food_model.dart';
import 'models/myth_fact_model.dart';

class EducationData {
  // ==========================================
  // TAB 1: SEPUTAR ANEMIA
  // ==========================================
  static const List<ArticleModel> seputarAnemiaArticles = [
    ArticleModel(
      id: 'seputar_01',
      number: '01',
      title: 'Apa itu anemia?',
      subtitle:
          'Bukan sekadar kurang darah. Kenali peran hemoglobin dan mengapa pemeriksaan tetap penting.',
      category: 'Seputar Anemia',
      readTime: '3 menit baca',
      sections: [
        ArticleSection(
          header: 'Oksigen untuk setiap langkah',
          body:
              'Anemia terjadi ketika jumlah sel darah merah atau kadar hemoglobin lebih rendah dari batas yang sesuai usia, jenis kelamin, dan kondisi kehamilan. Hemoglobin membawa oksigen ke jaringan tubuh.',
        ),
        ArticleSection(
          header: 'Skrining berbeda dari diagnosis',
          body:
              'Kepucatan pada mata atau telapak tangan dapat menjadi petunjuk awal, tetapi tidak mengukur hemoglobin. Diagnosis memerlukan pemeriksaan darah dan penilaian tenaga kesehatan.',
        ),
        ArticleSection(
          header: 'Mengapa perlu diperhatikan?',
          body:
              'Anemia dapat mengganggu energi, konsentrasi, dan kemampuan beraktivitas. Pada kehamilan, kondisi ini perlu ditangani untuk mendukung kesehatan ibu dan janin.',
        ),
      ],
      referenceSource: 'WHO',
      referenceName: 'Anaemia',
    ),
    ArticleModel(
      id: 'seputar_02',
      number: '02',
      title: 'Apa penyebab anemia?',
      subtitle:
          'Kekurangan zat besi sering terjadi, tetapi anemia memiliki lebih dari satu penyebab.',
      category: 'Seputar Anemia',
      readTime: '4 menit baca',
      sections: [
        ArticleSection(
          header: 'Kekurangan zat gizi',
          body:
              'Kekurangan zat besi adalah kekurangan gizi yang paling umum menyebabkan anemia, terutama karena asupan zat besi rendah. Kekurangan folat, vitamin B12, vitamin A, atau riboflavin juga dapat menjadi penyebab.',
        ),
        ArticleSection(
          header: 'Kehilangan darah',
          body:
              'Haid yang banyak dan terus-menerus, serta perdarahan saat dan setelah melahirkan, dapat menguras cadangan zat besi. Perdarahan juga disebut sebagai penyebab utama anemia defisiensi besi.',
        ),
        ArticleSection(
          header: 'Penyakit kronis dan kelainan bawaan',
          body:
              'Penyakit kronis yang menimbulkan peradangan dapat menyebabkan anemia, misalnya penyakit ginjal. Kelainan sel darah merah yang diturunkan, seperti thalassemia dan sel sabit, juga dapat menjadi penyebab.',
        ),
      ],
      referenceSource: 'WHO & ASH',
      referenceName: 'Anaemia & Anemia Basics',
    ),
    ArticleModel(
      id: 'seputar_03',
      number: '03',
      title: 'Jenis-jenis anemia',
      subtitle:
          'Penyebab yang berbeda memerlukan pemeriksaan dan penanganan yang berbeda pula.',
      category: 'Seputar Anemia',
      readTime: '4 menit baca',
      sections: [
        ArticleSection(
          header: 'Anemia defisiensi besi',
          body:
              'Jenis yang paling umum. Terjadi ketika tubuh kekurangan zat besi untuk membuat hemoglobin.',
        ),
        ArticleSection(
          header: 'Anemia defisiensi vitamin',
          body:
              'Berkaitan dengan kekurangan vitamin B12 atau folat (juga tembaga dan seng). Anemia pernisiosa adalah bentuk autoimun dari kekurangan B12.',
        ),
        ArticleSection(
          header: 'Anemia hemolitik dan aplastik',
          body:
              'Pada anemia hemolitik, sel darah merah dihancurkan lebih cepat dari pembentukannya. Pada anemia aplastik, sumsum tulang berhenti membuat sel darah dalam jumlah cukup. Aplastik tergolong jarang.',
        ),
        ArticleSection(
          header: 'Kelainan bawaan dan penyakit lain',
          body:
              'Anemia sel sabit adalah kelainan bawaan pada hemoglobin yang membuat sel darah merah kaku, berbentuk sabit, dan berumur pendek. Thalassemia juga diturunkan. Anemia dapat pula muncul akibat penyakit lain, seperti penyakit ginjal.',
        ),
      ],
      referenceSource: 'ASH & NHLBI',
      referenceName: 'Anemia & Your Guide to Anemia',
    ),
    ArticleModel(
      id: 'seputar_04',
      number: '04',
      title: 'Siapa yang lebih berisiko?',
      subtitle:
          'Kebutuhan tubuh dan kondisi kesehatan dapat meningkatkan risiko anemia.',
      category: 'Seputar Anemia',
      readTime: '3 menit baca',
      sections: [
        ArticleSection(
          header: 'Remaja putri dan perempuan yang haid',
          body:
              'WHO menyebut remaja putri dan perempuan yang mengalami menstruasi sebagai kelompok yang paling berisiko, terutama bila haidnya banyak dan terus-menerus.',
        ),
        ArticleSection(
          header: 'Ibu hamil',
          body:
              'Kebutuhan zat besi ibu meningkat seiring usia kehamilan, dan volume darah ibu naik hingga sekitar 50%. Karena itu ibu hamil dan nifas termasuk kelompok berisiko.',
        ),
        ArticleSection(
          header: 'Anak-anak',
          body:
              'Anak balita termasuk kelompok yang paling berisiko menurut WHO.',
        ),
        ArticleSection(
          header: 'Lansia',
          body:
              'Kemenkes menyebut anemia dapat dialami balita, remaja, ibu hamil, bahkan usia lanjut.',
        ),
      ],
      referenceSource: 'WHO & Kemenkes',
      referenceName: 'Anaemia & Ayo Sehat',
    ),
  ];

  // ==========================================
  // TAB 2: GEJALA
  // ==========================================
  static const List<ArticleModel> gejalaArticles = [
    ArticleModel(
      id: 'gejala_01',
      number: '01',
      title: 'Kenali tanda pada tubuhmu',
      subtitle:
          'Pucat, lemas, pusing, sesak, dan berdebar: petunjuk yang perlu dipahami bersama konteksnya.',
      category: 'Gejala',
      readTime: '3 menit baca',
      sections: [
        ArticleSection(
          header: 'Lelah dan lemas',
          body:
              'Rasa lelah dan lemas adalah gejala yang paling sering disebut. Saat hemoglobin rendah, jaringan menerima lebih sedikit oksigen.',
        ),
        ArticleSection(
          header: 'Pucat',
          body:
              'Kulit, gusi, atau bagian dalam kelopak mata bisa tampak lebih pucat dari biasanya. Tangan dan kaki juga dapat terasa dingin.',
        ),
        ArticleSection(
          header: 'Pusing, sesak, dan jantung berdebar',
          body:
              'Anemia dapat menimbulkan pusing, sakit kepala, napas pendek saat beraktivitas, serta denyut jantung yang cepat atau tidak teratur. Pusing dapat terasa lebih berat saat berdiri.',
        ),
      ],
      referenceSource: 'Mayo Clinic & WHO',
      referenceName: 'Low hemoglobin & Anaemia',
    ),
    ArticleModel(
      id: 'gejala_02',
      number: '02',
      title: 'Kapan harus ke dokter?',
      subtitle:
          'Kenali keluhan yang perlu konsultasi dan tanda bahaya yang tidak boleh menunggu.',
      category: 'Gejala',
      readTime: '2 menit baca',
      sections: [
        ArticleSection(
          header: 'Keluhan yang perlu diperiksakan',
          body:
              'Bila kamu mengalami gejala seperti lelah berkepanjangan, pusing, napas pendek, atau tampak pucat, buat janji dengan tenaga kesehatan.',
        ),
        ArticleSection(
          header: 'Tanda bahaya',
          body:
              'Nyeri dada, sesak berat, pingsan, atau perdarahan aktif perlu pertolongan segera. Jangan menunggu hasil scan.',
        ),
        ArticleSection(
          header: 'Pemeriksaan yang mungkin dilakukan',
          body:
              'Dokter dapat menyarankan tes darah lengkap (complete blood count). Pemeriksaan bisa mencakup kadar hemoglobin, hematokrit, dan feritin (cadangan zat besi).',
        ),
      ],
      referenceSource: 'Mayo Clinic',
      referenceName: 'Low hemoglobin count',
    ),
  ];

  // ==========================================
  // TAB 3: KATALOG MAKANAN (REVISED)
  // ==========================================
  static const List<FoodModel> foodCatalog = [
    FoodModel(
      id: 'food_01',
      name: 'Bayam',
      subtitle: 'Sayuran hijau',
      category: 'Sayuran',
      ironContent: '±2,7 mg',
      proteinContent: '±2,9 g',
      extraNutrient: 'Kaya Folat',
      fdcId: '168462',
      description:
          'Sayuran yang mudah ditemukan, kaya folat dan mengandung zat besi.',
      tips:
          'Padukan dengan sumber vitamin C seperti jeruk atau tomat untuk membantu penyerapan zat besi.',
      imagePath: 'assets/images/bayam.png',
    ),
    FoodModel(
      id: 'food_02',
      name: 'Tiram',
      subtitle: 'Hasil laut, sumber zat besi',
      category: 'Hewani',
      ironContent: '±5,8 mg',
      proteinContent: '±5,2 g',
      fdcId: '175172',
      description: 'Hasil laut yang mengandung zat besi dan protein.',
      tips:
          'Hasil laut dapat membantu penyerapan zat besi dari makanan nabati, jadi padukan dengan sayur atau kacang-kacangan dalam satu kali makan. Nilai di atas untuk bahan mentah. Konsumsi dalam keadaan matang, dan hindari bila kamu alergi hasil laut.',
      imagePath: 'assets/images/tiram.jpg',
    ),
    FoodModel(
      id: 'food_03',
      name: 'Tempe',
      subtitle: 'Baik, lokal, terjangkau',
      category: 'Nabati',
      ironContent: '±2,7 mg',
      proteinContent: '±20,3 g',
      fdcId: '174272',
      description:
          'Pangan nabati lokal yang terjangkau, mengandung zat besi dan protein.',
      tips:
          'Zat besi dari tumbuhan (nonheme) diserap sekitar 2–20%. Padukan dengan sumber vitamin C untuk membantu penyerapan.',
      imagePath: 'assets/images/tempe.jpg',
    ),
    FoodModel(
      id: 'food_04',
      name: 'Hati Ayam',
      subtitle: 'Sumber zat besi heme',
      category: 'Hewani',
      ironContent: '±9,0 mg',
      proteinContent: '±16,9 g',
      extraNutrient: 'Tinggi Vit A',
      fdcId: '171060',
      description:
          'Mengandung zat besi heme, bentuk zat besi dari pangan hewani.',
      tips:
          'Nilai gizi di atas untuk bahan mentah. Zat besi heme diserap sekitar 15–35%. Konsumsi secukupnya, dan tanyakan ke tenaga kesehatan bila kamu sedang hamil.',
      imagePath: 'assets/images/hati_ayam.png',
    ),
    FoodModel(
      id: 'food_05',
      name: 'Daun Kelor',
      subtitle: 'Nutrisi dari sekitar kita',
      category: 'Sayuran',
      ironContent: '±4,0 mg',
      proteinContent: '±9,4 g',
      extraNutrient: 'Tinggi Vit C',
      fdcId: '168416',
      description:
          'Sayuran lokal yang mengandung zat besi, protein, dan vitamin C.',
      tips:
          'Vitamin C membantu penyerapan zat besi dari tumbuhan, dan kelor sudah mengandungnya.',
      imagePath: 'assets/images/daun_kelor.png',
    ),
    FoodModel(
      id: 'food_06',
      name: 'Kacang Hijau',
      subtitle: 'Kacang-kacangan lokal',
      category: 'Nabati',
      ironContent: '±6,7 mg',
      proteinContent: '±23,9 g',
      extraNutrient: 'Kaya Folat',
      fdcId: '174256',
      description:
          'Kacang-kacangan lokal yang mengandung zat besi, protein, dan folat.',
      tips:
          'Zat besi dari kacang-kacangan lebih sulit diserap karena adanya fitat. Padukan dengan sumber vitamin C seperti tomat atau jeruk. Nilai di atas untuk kacang hijau kering sebelum dimasak. Setelah direbus, nilai per 100 g lebih rendah karena kacang menyerap air.',
      imagePath: 'assets/images/kacang_hijau.jpg',
    ),
  ];

  // ==========================================
  // TAB 4: TENTANG TTD (TABLET TAMBAH DARAH)
  // ==========================================
  static const List<ArticleModel> ttdArticles = [
    ArticleModel(
      id: 'ttd_01',
      number: '01',
      title: 'Kenalan dengan Tablet Tambah Darah',
      subtitle:
          'TTD membantu mencegah kekurangan zat besi dan folat pada kelompok yang membutuhkan.',
      category: 'Tentang TTD',
      readTime: '3 menit baca',
      sections: [
        ArticleSection(
          header: 'Isi tablet',
          body:
              'Menurut Permenkes, TTD sekurangnya mengandung zat besi setara 60 mg besi elemental dan 0,4 mg asam folat per tablet.',
        ),
        ArticleSection(
          header: 'Untuk siapa?',
          body:
              'Dalam program Kemenkes, TTD diberikan kepada remaja putri dan ibu hamil. Remaja putri di sini berusia 12–18 tahun. Kebutuhan zat besi ibu hamil meningkat seiring kehamilan.',
        ),
        ArticleSection(
          header: 'Untuk pencegahan',
          body:
              'TTD adalah suplemen pencegahan, bukan obat yang hanya diminum saat sakit. Minum TTD secara rutin diharapkan mengurangi potensi anemia. TTD tidak menggantikan makanan bergizi, dan tidak semua jenis anemia diatasi dengan zat besi.',
        ),
      ],
      referenceSource: 'Kemenkes',
      referenceName: 'Permenkes No. 14 Tahun 2019 & Anemia Remaja Putri',
    ),
    ArticleModel(
      id: 'ttd_02',
      number: '02',
      title: 'Dosis umum & cara konsumsi',
      subtitle:
          'Informasi program pencegahan, bukan resep pribadi. Ikuti arahan tenaga kesehatan.',
      category: 'Tentang TTD',
      readTime: '4 menit baca',
      sections: [
        ArticleSection(
          header: 'Jadwal umum',
          body:
              'Remaja putri: 1 tablet setiap minggu. Ibu hamil: minimal 90 tablet selama kehamilan. Ikuti petunjuk di kemasan dan arahan tenaga kesehatan. Jangan memulai, menghentikan, atau mengubah dosis hanya berdasarkan hasil aplikasi.',
        ),
        ArticleSection(
          header: 'Cara minum',
          body:
              'Minum dengan air putih setelah makan. Buah kaya vitamin C, seperti jeruk atau jambu, dapat membantu penyerapan.',
        ),
        ArticleSection(
          header: 'Hindari diminum bersamaan',
          body:
              'Hindari minum TTD bersama teh, kopi, atau susu. Antasida (obat maag) dan produk kalsium juga sebaiknya diberi jarak waktu. Tanin dalam teh dan kalsium dapat mengurangi penyerapan zat besi.',
        ),
        ArticleSection(
          header: 'Efek samping yang mungkin muncul',
          body:
              'Efek yang tercatat antara lain mual, sembelit, rasa pahit, dan feses yang lebih gelap. Feses berwarna hitam saat minum zat besi adalah hal yang normal. Segera hubungi tenaga kesehatan bila feses hitam dan seperti ter, ada garis darah merah, atau perut kram dan nyeri tajam.',
        ),
      ],
      referenceSource: 'Kemenkes & MedlinePlus',
      referenceName: 'Permenkes No. 14/2019 & Taking iron supplements',
    ),
  ];

  // ==========================================
  // TAB 5: MITOS VS FAKTA
  // ==========================================
  static final List<MythFactModel> mythFacts = [
    const MythFactModel(
      id: '1',
      number: '1',
      myth: 'Anemia sama dengan tekanan darah rendah (hipotensi).',
      fact:
          'Anemia berkaitan dengan kurangnya kadar sel darah merah atau hemoglobin, sedangkan tekanan darah rendah berkaitan dengan tekanan aliran darah. Keduanya berbeda meski sama-sama dapat menyebabkan pusing.',
    ),
    const MythFactModel(
      id: '2',
      number: '2',
      myth: 'Semua jenis anemia cukup diobati dengan suplemen zat besi.',
      fact:
          'Anemia memiliki beragam penyebab, seperti kekurangan zat besi, asam folat, vitamin B12, atau kondisi medis lain. Penanganan yang tepat memerlukan pemeriksaan dan saran dari tenaga kesehatan.',
    ),
    const MythFactModel(
      id: '3',
      number: '3',
      myth: 'Jika tidak terlihat pucat, berarti pasti bebas dari anemia.',
      fact:
          'Gejala awal anemia sering kali tidak terlihat secara fisik. Tanpa penanganan, anemia tetap bisa menyebabkan tubuh mudah lelah, lemas, dan sulit berkonsentrasi.',
    ),
    const MythFactModel(
      id: '4',
      number: '4',
      myth:
          'Tablet Tambah Darah (TTD) memicu kenaikan berat badan dan wajib diminum setiap hari.',
      fact:
          'TTD tidak mengandung kalori yang menyebabkan kenaikan berat badan. Aturan konsumsinya pun berbeda: remaja putri dianjurkan 1 kali seminggu, sedangkan ibu hamil disesuaikan dengan petunjuk bidan atau dokter.',
    ),
    const MythFactModel(
      id: '5',
      number: '5',
      myth: 'Sayur bayam saja sudah cukup untuk menyembuhkan anemia.',
      fact:
          'Zat besi dari tumbuh-tumbuhan (nabati) lebih sulit diserap tubuh dibandingkan zat besi dari bahan hewani seperti daging atau hati. Konsumsi bayam sebaiknya dilengkapi dengan pangan hewani dan TTD.',
    ),
    const MythFactModel(
      id: '6',
      number: '6',
      myth:
          'Jika hasil scan Anemify normal, tes darah laboratorium tidak diperlukan lagi.',
      fact:
          'Scan Anemify berfungsi sebagai skrining awal secara praktis. Jika mengalami gejala yang berlanjut, tes darah di puskesmas atau fasilitas kesehatan tetap menjadi rujukan medis utama.',
    ),
  ];

  // ==========================================
  // SEKSI CARA KERJA & AKURASI (FOOTER CARD)
  // ==========================================
  static const String caraKerjaTitle = 'Cara Kerja & Akurasi';
  static const String caraKerjaSubtitle =
      'Teknologi yang transparan, untuk keputusan yang lebih bijak.';
  static const String caraKerjaHeroTitle = 'Skrining awal, bukan diagnosis.';
  static const String caraKerjaHeroBody =
      'Prototipe ini belum memuat model TFLite atau segmentasi ML. Tidak ada angka akurasi klinis yang dapat diklaim.';

  static const List<Map<String, String>> caraKerjaSteps = [
    {
      'title': '1. Ambil dua foto',
      'body':
          'Gunakan panduan bulan sabit untuk konjungtiva dan frame tangan untuk telapak. Foto diproses di perangkat, tidak dikirim ke server.',
    },
    {
      'title': '2. Periksa kualitas',
      'body':
          'Rata-rata luminansi mengecek terang/gelap. Variansi Laplacian membantu mengenali blur. Ambang heuristik di prototipe belum divalidasi untuk semua kamera, warna kulit, dan pencahayaan.',
    },
    {
      'title': '3. Tinjau area panduan',
      'body':
          'Crop diambil dari pusat frame foto. Outline menunjukkan panduan posisi, bukan batas jaringan hasil segmentasi. Sistem belum dapat memastikan foto benar-benar mata atau telapak.',
    },
    {
      'title': '4. Kategori & ketidakpastian',
      'body':
          'Kategori Normal, Ringan, Sedang, dan Berat adalah contoh skenario. Confidence demo di bawah 70% menghasilkan status Tidak Yakin. Nilai dan ambang ini ilustratif, bukan keyakinan model terlatih.',
    },
    {
      'title': '5. Validasi sebelum penggunaan medis',
      'body':
          'Implementasi nyata perlu dataset dengan label Hb laboratorium, uji pada data independen, sensitivitas, spesifisitas, serta evaluasi pada kelompok usia, warna kulit, kehamilan, dan kamera yang berbeda. Tidak ada metrik tersebut pada prototipe ini.',
    },
  ];
}
