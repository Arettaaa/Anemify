/// Link rujukan per artikel (key = ArticleModel.id).
class ArticleReference {
  final String label;
  final String url;
  const ArticleReference(this.label, this.url);
}

const _who = ArticleReference(
  'WHO · Anaemia',
  'https://www.who.int/news-room/fact-sheets/detail/anaemia',
);
const _ash = ArticleReference(
  'ASH · Anemia',
  'https://www.hematology.org/education/patients/anemia',
);
const _nhlbi = ArticleReference(
  'NHLBI · Your Guide to Anemia',
  'https://www.nhlbi.nih.gov/resources/your-guide-anemia',
);
const _ayoSehat = ArticleReference(
  'Kemenkes Ayo Sehat · Anemia',
  'https://ayosehat.kemkes.go.id/topik-penyakit/defisiensi-nutrisi/anemia',
);
const _mayo = ArticleReference(
  'Mayo Clinic · Low hemoglobin count',
  'https://www.mayoclinic.org/symptoms/low-hemoglobin/basics/definition/sym-20050760',
);
const _permenkes = ArticleReference(
  'Kemenkes · Permenkes No. 14 Tahun 2019',
  'https://jdih.kemkes.go.id/common/dokumen/2019permenkes014.pdf',
);
const _ttdRemaja = ArticleReference(
  'Kemenkes Ayo Sehat · Cegah Anemia dengan Tablet Tambah Darah',
  'https://ayosehat.kemkes.go.id/list-perangkat-ajar/cegah-anemia-dengan-tablet-tambah-darah',
);
const _medline = ArticleReference(
  'MedlinePlus · Taking iron supplements',
  'https://medlineplus.gov/ency/article/007478.htm',
);

const Map<String, List<ArticleReference>> kArticleReferences = {
  'seputar_01': [_who],
  'seputar_02': [_who, _ash],
  'seputar_03': [_ash, _nhlbi],
  'seputar_04': [_who, _ayoSehat],
  'gejala_01': [_mayo, _who],
  'gejala_02': [_mayo],
  'ttd_01': [_permenkes, _ttdRemaja],
  'ttd_02': [_permenkes, _medline],
};