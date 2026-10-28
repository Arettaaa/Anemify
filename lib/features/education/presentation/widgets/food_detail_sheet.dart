import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/food_model.dart';

void showFoodDetailModal(BuildContext context, FoodModel food) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FoodDetailSheet(food: food),
      );
    },
  );
}

class FoodDetailSheet extends StatelessWidget {
  final FoodModel food;

  const FoodDetailSheet({super.key, required this.food});

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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title & Close
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            food.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
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
                    const SizedBox(height: 16),

                    // Gambar Makanan
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        food.imagePath,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chip Kategori
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
                        food.category,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Nutrisi baik, dekat denganmu.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      food.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Box Kandungan Gizi
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perkiraan per 100 g',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Zat besi',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      food.ironContent,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Protein',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      food.proteinContent,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (food.extraNutrient != null)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lainnya',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        food.extraNutrient!,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tips untuk piringmu
                    Text(
                      'Tips untuk piringmu',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      food.tips,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        'Rujukan: USDA FoodData Central (FDC ID: ${food.fdcId})',
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
