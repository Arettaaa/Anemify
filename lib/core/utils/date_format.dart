const _bulanPendek = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];
const _bulanPanjang = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 30 Sep
String formatTglPendek(DateTime d) => '${d.day} ${_bulanPendek[d.month - 1]}';

/// 30 September 2026
String formatTglPanjang(DateTime d) =>
    '${d.day} ${_bulanPanjang[d.month - 1]} ${d.year}';

/// September 2026
String formatBulanTahun(DateTime d) =>
    '${_bulanPanjang[d.month - 1]} ${d.year}';

/// 09:11
String formatJam(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
