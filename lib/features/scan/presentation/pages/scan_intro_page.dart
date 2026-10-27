import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/scan_widgets.dart';
import 'scan_capture_page.dart';
import 'scan_flow.dart';
import 'scan_how_it_works_page.dart';

class ScanIntroPage extends StatefulWidget {
  const ScanIntroPage({super.key});

  @override
  State<ScanIntroPage> createState() => _ScanIntroPageState();
}

class _ScanIntroPageState extends State<ScanIntroPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return ScanPageScaffold(
      children: [
        ScanTitle(
          title: 'Kenali, lalu jaga.',
          subtitle: TextSpan(
            text: 'Dua foto, satu langkah peduli. ',
            children: [
              TextSpan(
                text: 'Tanpa jarum dan tanpa akun.',
                style: scanStyle(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _TypeCard(
                  icon: LucideIcons.eye,
                  title: 'Konjungtiva mata',
                  caption: 'Frame bulan sabit',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _TypeCard(
                  icon: LucideIcons.hand,
                  title: 'Telapak tangan',
                  caption: 'Frame kotak di tengah',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Kualitas foto, langkah pertama',
          style: scanStyle(size: 17, weight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        const _TipRow(
          icon: LucideIcons.sun,
          title: 'Cahaya terang yang merata',
          desc: 'Tanpa flash, hindari bayangan dan lampu berwarna.',
        ),
        const _TipRow(
          icon: LucideIcons.camera,
          title: 'Kamera bersih, tangan stabil',
          desc: 'Foto gelap, terlalu terang, atau buram perlu diulang.',
        ),
        const _TipRow(
          icon: LucideIcons.shieldCheck,
          title: 'Data tetap di perangkatmu',
          desc: 'Foto diproses lokal dan tidak disimpan.',
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Penting: ',
                  style:
                      scanStyle(size: 13, weight: FontWeight.w700, height: 1.5),
                ),
                const TextSpan(
                  text: 'hasil berupa kategori risiko skrining dari model di '
                      'perangkat, bukan diagnosis. Ikuti panduan di kamera '
                      'agar foto bisa dianalisis.',
                ),
              ],
            ),
            style: scanStyle(
                size: 13, height: 1.5, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () => setState(() => _agreed = !_agreed),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreed,
                  activeColor: AppColors.primary,
                  side: const BorderSide(
                      color: AppColors.textSecondary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Saya memahami batasan skrining, foto diproses di perangkat, '
                  'dan hasil ini bukan diagnosis.',
                  style: scanStyle(
                      size: 13, height: 1.5, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ScanPrimaryButton(
          label: 'Mulai ambil foto',
          onPressed: _agreed
              ? () => pushScanPage(
                    context,
                    const ScanCapturePage(),
                    name: kScanCaptureRoute,
                  )
              : null,
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanHowItWorksPage()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Baca Cara Kerja & Akurasi',
                style: scanStyle(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String caption;
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.pinkTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 14),
          Text(title,
              textAlign: TextAlign.center,
              style: scanStyle(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(caption,
              textAlign: TextAlign.center,
              style: scanStyle(size: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _TipRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: scanStyle(size: 15, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc,
                    style: scanStyle(
                        size: 13, height: 1.4, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}