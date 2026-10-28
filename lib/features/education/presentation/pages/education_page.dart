import 'package:flutter/material.dart';
import '../widgets/education_header.dart';
import '../widgets/education_tab_bar.dart';
import '../widgets/education_hero_card.dart';
import '../widgets/article_list_item.dart';
import '../widgets/bottom_info_card.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Seputar Anemia',
    'Gejala',
    'Katalog Makanan',
    'Tentang TTD',
    'Mitos vs Fakta',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Tanpa AppBar agar jarak status bar & logo seragam dengan HomePage
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Baru (Dengan DM Sans & Logo Sejajar)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: EducationHeader(),
              ),

              const SizedBox(height: 24),

              // 2. Tab Bar
              EducationTabBar(
                tabs: _tabs,
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ),

              const SizedBox(height: 24),

              // 3. Konten Utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EducationHeroCard(),
                    const SizedBox(height: 32),

                    const Text(
                      'Baca, pahami, lalu terapkan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ArticleListItem(
                      number: '01',
                      title: 'Apa itu anemia?',
                      description:
                          'Bukan sekadar kurang darah. Kenali peran hemoglobin dan mengapa pemeriksaan tetap penting.',
                      readTime: '3 menit baca',
                      onTap: () {},
                    ),
                    ArticleListItem(
                      number: '02',
                      title: 'Apa penyebab anemia?',
                      description:
                          'Kekurangan zat besi sering terjadi, tetapi anemia memiliki lebih dari satu penyebab.',
                      readTime: '4 menit baca',
                      onTap: () {},
                    ),
                    ArticleListItem(
                      number: '03',
                      title: 'Jenis-jenis anemia',
                      description:
                          'Penyebab yang berbeda memerlukan pemeriksaan dan penanganan yang berbeda pula.',
                      readTime: '4 menit baca',
                      onTap: () {},
                    ),
                    ArticleListItem(
                      number: '04',
                      title: 'Siapa yang lebih berisiko?',
                      description:
                          'Kebutuhan tubuh dan kondisi kesehatan dapat meningkatkan risiko anemia.',
                      readTime: '3 menit baca',
                      onTap: () {},
                    ),

                    const SizedBox(height: 16),
                    const BottomInfoCard(),
                    const SizedBox(height: 32),

                    Center(
                      child: Text(
                        'Edukasi umum, bukan pengganti konsultasi medis.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 130), // Spacing navigasi bawah
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
