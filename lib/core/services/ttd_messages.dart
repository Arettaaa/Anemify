import '../../features/profile/domain/entities/profile.dart';

/// Gaya pesan pengingat TTD, ditentukan dari profil.
enum TtdAudience { remaja, ibuHamil, lakiLaki, umum }

TtdAudience audienceOf(Profile? p) {
  if (p == null) return TtdAudience.umum;
  if (p.isPregnant) return TtdAudience.ibuHamil;
  if (p.age >= 10 && p.age <= 19) return TtdAudience.remaja;
  if (p.sex == Sex.lakiLaki) return TtdAudience.lakiLaki;
  return TtdAudience.umum;
}

typedef TtdMessage = ({String title, String body});

/// 7 pesan per gaya, dipakai bergiliran (satu per hari dalam seminggu).
/// {n} diganti nama profil.
const Map<TtdAudience, List<TtdMessage>> _messages = {
  TtdAudience.remaja: [
    (
      title: '{n}, TTD-nya belum diminum nih 😤',
      body: 'Aku nungguin dari tadi lho. Minum sekarang, terus centang di Anemify ya.',
    ),
    (
      title: 'Psst, {n} 👀',
      body: 'Ada tablet kecil yang nungguin kamu. Minum dulu, baru lanjut scroll.',
    ),
    (
      title: 'Jangan di-skip ya, {n} 🙅',
      body: 'Biar badan nggak gampang lemas, minum TTD dulu yuk.',
    ),
    (
      title: 'Reminder dari bestie kamu 💊',
      body: 'Waktunya TTD, {n}. Habis minum, jangan lupa dicentang.',
    ),
    (
      title: '{n}, sudah minum TTD belum? 🥺',
      body: 'Kalau sudah, centang di Anemify biar streak kamu nggak putus.',
    ),
    (
      title: 'Streak kamu nungguin nih 🔥',
      body: 'Minum TTD sekarang biar catatanmu tetap penuh, {n}.',
    ),
    (
      title: 'Tablet kecil memanggil 📣',
      body: 'Minum pakai air putih ya, {n}, jangan bareng teh atau kopi.',
    ),
  ],
  TtdAudience.ibuHamil: [
    (
      title: 'Waktunya TTD, {n} 💗',
      body: 'Satu tablet hari ini untuk Ibu dan si kecil. Catat di Anemify setelah diminum.',
    ),
    (
      title: '{n}, jangan lupa TTD ya 🤰',
      body: 'Minum dengan air putih atau jus jeruk, hindari teh dan kopi di waktu yang sama.',
    ),
    (
      title: 'Pengingat lembut untuk {n} 🌷',
      body: 'Sudah minum TTD hari ini? Centang di Anemify supaya catatannya rapi.',
    ),
    (
      title: 'Hai {n}, waktunya TTD 💊',
      body: 'Kalau terasa mual, tanyakan ke bidan waktu minum yang paling nyaman.',
    ),
    (
      title: 'Langkah kecil hari ini 💗',
      body: '{n}, minum TTD rutin membantu menjaga Ibu tetap bertenaga.',
    ),
    (
      title: '{n}, tabletnya sudah siap? ✨',
      body: 'Minum sekarang lalu catat di Anemify, ya.',
    ),
    (
      title: 'Satu tablet, satu hari ✔️',
      body: 'Terima kasih sudah menjaga diri, {n}. Waktunya minum TTD.',
    ),
  ],
  TtdAudience.lakiLaki: [
    (
      title: '{n}, waktunya TTD 💪',
      body: 'Sebentar saja. Minum, centang, lanjut aktivitas.',
    ),
    (
      title: 'Jangan sampai lupa, {n} ⏰',
      body: 'TTD hari ini belum dicatat. Minum sekarang yuk.',
    ),
    (
      title: 'Isi ulang energi 🔋',
      body: 'Minum TTD dengan air putih, lalu catat di Anemify.',
    ),
    (
      title: 'Cek sebentar, {n} 👋',
      body: 'Sudah minum TTD? Kalau sudah, tinggal dicentang.',
    ),
    (
      title: 'Pengingat harian 💊',
      body: 'Hindari minum bareng teh atau kopi supaya penyerapannya lebih baik.',
    ),
    (
      title: '{n}, streak kamu masih jalan 🔥',
      body: 'Minum TTD sekarang biar nggak putus.',
    ),
    (
      title: 'Satu tablet saja ✔️',
      body: 'Waktunya TTD, {n}. Habis itu catat di Anemify.',
    ),
  ],
  TtdAudience.umum: [
    (
      title: 'Waktunya minum TTD, {n} 💊',
      body: 'Minum sekarang, lalu centang di Anemify.',
    ),
    (
      title: '{n}, jangan lupa TTD ya ⏰',
      body: 'Minum dengan air putih, hindari teh atau kopi di waktu yang sama.',
    ),
    (
      title: 'Hai {n} 👋',
      body: 'Ada TTD yang menunggu hari ini. Sudah diminum?',
    ),
    (
      title: 'Kebiasaan kecil hari ini 🌱',
      body: '{n}, satu tablet TTD lalu catat di Anemify.',
    ),
    (
      title: '{n}, streak kamu masih jalan 🔥',
      body: 'Minum TTD sekarang biar catatannya nggak putus.',
    ),
    (
      title: 'Pengingat TTD 💗',
      body: 'Sudah minum, {n}? Kalau sudah, tinggal dicentang.',
    ),
    (
      title: 'Satu tablet, satu hari ✔️',
      body: 'Waktunya TTD, {n}. Jaga tetap rutin ya.',
    ),
  ],
};

/// Pesan untuk [weekday] (1 = Senin ... 7 = Minggu).
TtdMessage ttdMessage(TtdAudience a, String name, int weekday) {
  final list = _messages[a]!;
  final m = list[(weekday - 1) % list.length];
  final n = name.trim().isEmpty ? 'kamu' : name.trim();
  String fill(String s) => s.replaceAll('{n}', n);
  return (title: fill(m.title), body: fill(m.body));
}