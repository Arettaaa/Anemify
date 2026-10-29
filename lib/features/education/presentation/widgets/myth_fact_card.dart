import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/myth_fact_model.dart';

class MythFactCard extends StatefulWidget {
  final MythFactModel mythFact;

  const MythFactCard({super.key, required this.mythFact});

  @override
  State<MythFactCard> createState() => _MythFactCardState();
}

class _MythFactCardState extends State<MythFactCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F2), width: 1),
      ),
      child: Column(
        children: [
          // Header Mitos (Dapat Di-klik)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Badge "MITOS [id]"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'MITOS ${widget.mythFact.id}',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE63946),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Judul Mitos
                  Expanded(
                    child: Text(
                      widget.mythFact.myth,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Panah Rotasi Halus
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten Fakta (Buka-Tutup Smooth Accordion)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF2B2D42),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'FAKTA',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2B2D42),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.mythFact.fact,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
