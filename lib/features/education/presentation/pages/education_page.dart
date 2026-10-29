import 'package:anemify/features/ttd/presentation/pages/ttd_reminder_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/education_data.dart';
import '../../data/models/article_model.dart';
import '../../data/models/food_model.dart';
import '../utils/show_article_detail.dart';
import '../widgets/article_list_item.dart';
import '../widgets/bottom_info_card.dart';
import '../widgets/education_header.dart';
import '../widgets/education_hero_card.dart';
import '../widgets/education_tab_bar.dart';
import '../widgets/food_card_item.dart';
import '../widgets/food_detail_sheet.dart';
import '../widgets/myth_fact_card.dart';
import '../widgets/ttd_dosis_card.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  int _selectedTabIndex = 0;
  String _foodSearchQuery = '';
  String _selectedFoodCategory = 'Semua';

  final List<String> _tabs = [
    'Seputar Anemia',
    'Gejala',
    'Katalog Makanan',
    'Tentang TTD',
    'Mitos vs Fakta',
  ];

  final List<String> _symptomChips = [
    'Pucat',
    'Lemas',
    'Pusing',
    'Sesak',
    'Jantung berdebar',
  ];

  final List<String> _foodCategories = ['Semua', 'Sayuran', 'Hewani', 'Nabati'];

  List<FoodModel> get _filteredFoods {
    return EducationData.foodCatalog.where((food) {
      final matchesCategory =
          _selectedFoodCategory == 'Semua' ||
          food.category == _selectedFoodCategory;
      final matchesSearch =
          food.name.toLowerCase().contains(_foodSearchQuery.toLowerCase()) ||
          food.subtitle.toLowerCase().contains(_foodSearchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<ArticleModel> currentArticles = EducationData.seputarAnemiaArticles;
    if (_selectedTabIndex == 1) {
      currentArticles = EducationData.gejalaArticles;
    } else if (_selectedTabIndex == 3) {
      currentArticles = EducationData.ttdArticles;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: EducationHeader(),
              ),
              const SizedBox(height: 24),

              // Tab Bar dengan Auto-Center Smooth Transition
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

              // Konten Utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Hero Card
                    EducationHeroCard(
                      title: _selectedTabIndex == 4
                          ? 'Bukan katanya. Kenali faktanya.'
                          : _selectedTabIndex == 3
                          ? 'Satu kebiasaan, banyak manfaat.'
                          : _selectedTabIndex == 2
                          ? 'Nutrisi baik, dekat denganmu.'
                          : _selectedTabIndex == 1
                          ? 'Dengarkan tanda dari tubuhmu.'
                          : 'Pahami tubuh, jaga energimu.',
                      subtitle: _selectedTabIndex == 4
                          ? 'Luruskan informasi tentang anemia agar langkah sehatmu lebih tepat.'
                          : _selectedTabIndex == 3
                          ? 'Kenali TTD dan jadwal pencegahan yang berbeda untuk setiap kelompok.'
                          : _selectedTabIndex == 2
                          ? 'Sumber zat besi lokal dan perkiraan kandungan gizi untuk melengkapi piringmu.'
                          : _selectedTabIndex == 1
                          ? 'Kenali keluhan yang perlu diperhatikan, tanpa menyimpulkan diagnosis sendiri.'
                          : 'Mulai dari pengertian, penyebab, jenis, hingga siapa yang lebih berisiko.',
                      icon: _selectedTabIndex == 4
                          ? Icons.help_outline_rounded
                          : _selectedTabIndex == 3
                          ? Icons.notifications_none_rounded
                          : _selectedTabIndex == 2
                          ? Icons.eco_outlined
                          : _selectedTabIndex == 1
                          ? Icons.favorite_border_rounded
                          : Icons.menu_book_rounded,
                    ),

                    // ==========================================
                    // TAB 2: KATALOG MAKANAN
                    // ==========================================
                    if (_selectedTabIndex == 2) ...[
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _foodSearchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari makanan bergizi...',
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _foodCategories.map((cat) {
                            final isSelected = _selectedFoodCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFoodCategory = cat;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2B2D42)
                                        : const Color(0xFFF4F5F7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF2B2D42),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${_filteredFoods.length} pilihan makanan lokal',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2B2D42),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredFoods.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemBuilder: (context, index) {
                          final food = _filteredFoods[index];
                          return FoodCardItem(
                            food: food,
                            onTap: () => showFoodDetailModal(context, food),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Perkiraan per 100 g bahan mentah. Nilai dapat berubah menurut varietas dan pengolahan. Rujukan: USDA FoodData Central. Foto: Unsplash; kredit fotografer tersedia pada detail makanan.',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          height: 1.4,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],

                    // ==========================================
                    // TAB 4: MITOS VS FAKTA (ACCORDION DROPDOWN)
                    // ==========================================
                    if (_selectedTabIndex == 4) ...[
                      const SizedBox(height: 24),
                      Text(
                        '${EducationData.mythFacts.length} mitos yang perlu diluruskan',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2B2D42),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...EducationData.mythFacts.map((mf) {
                        return MythFactCard(mythFact: mf);
                      }),
                      const SizedBox(height: 8),
                      Text(
                        'Rujukan: WHO, NHLBI, dan edukasi TTD Kemenkes.',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          height: 1.4,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],

                    // ==========================================
                    // TAB ARTIKEL (Seputar, Gejala, TTD)
                    // ==========================================
                    if (_selectedTabIndex != 2 && _selectedTabIndex != 4) ...[
                      // Khusus Tab Gejala
                      if (_selectedTabIndex == 1) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: _symptomChips.map((chip) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                chip,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE63946),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFD6DC),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFE63946),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Nyeri dada, sesak berat, pingsan, atau perdarahan aktif? Cari pertolongan segera. Jangan menunggu hasil scan.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF9E2A2B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Khusus Tab Tentang TTD
                      if (_selectedTabIndex == 3) ...[
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            TtdDosisCard(
                              title: 'Remaja putri',
                              dosis: '1× / minggu',
                              subtitle: 'Jadwal umum program pencegahan',
                            ),
                            SizedBox(width: 12),
                            TtdDosisCard(
                              title: 'Ibu hamil',
                              dosis: 'Setiap hari',
                              subtitle: 'Sesuai arahan layanan antenatal',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Informasi ini bukan resep. Dosis terapi anemia, komposisi tablet, dan durasi konsumsi harus ditentukan tenaga kesehatan.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            height: 1.4,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      Text(
                        'Baca, pahami, lalu terapkan',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2B2D42),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List Artikel
                      ...currentArticles.map((article) {
                        return ArticleListItem(
                          number: article.number,
                          title: article.title,
                          description: article.subtitle,
                          readTime: article.readTime,
                          onTap: () => showArticleDetailModal(context, article),
                        );
                      }),

                      // Tombol CTA Sesuaikan Pengingat TTD (Hanya di Tab TTD)
                      if (_selectedTabIndex == 3) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TtdReminderPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_active_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              'Sesuaikan pengingat TTD',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 16),
                    const BottomInfoCard(),
                    const SizedBox(height: 32),

                    Center(
                      child: Text(
                        'Edukasi umum, bukan pengganti konsultasi medis.',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 130),
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
