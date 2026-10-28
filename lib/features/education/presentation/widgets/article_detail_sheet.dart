import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/article_model.dart';

class ArticleDetailSheet extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailSheet({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle (Garis -- di tengah atas)
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Isi Pop-up yang bisa di-scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Title & Close Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            article.title,
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF4F5F7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Tag Chip Category & Read Time
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${article.category} · ${article.readTime}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Subtitle Overview
                    Text(
                      article.subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dynamic Article Sections
                    ...article.sections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.header,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              section.body,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                height: 1.55,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Reference Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Rujukan untuk dibaca lebih lanjut',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.north_east_rounded,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${article.referenceSource} · ${article.referenceName}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Disclaimer
                    Center(
                      child: Text(
                        'Konten edukasi umum. Konsultasikan kondisi pribadi dengan tenaga kesehatan.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
