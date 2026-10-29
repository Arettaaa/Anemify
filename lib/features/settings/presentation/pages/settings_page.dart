import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Profile? _activeProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveProfile();
  }

  Future<void> _loadActiveProfile() async {
    final profile = await sl<GetActiveProfile>()();
    if (!mounted) return;
    setState(() {
      _activeProfile = profile;
      _isLoading = false;
    });
  }

  String _getCategoryLabel(Profile? profile) {
    if (profile == null) return 'Umum';
    if (profile.isPregnant) return 'Ibu hamil';
    if (profile.age >= 10 &&
        profile.age <= 19 &&
        profile.sex == Sex.perempuan) {
      return 'Remaja putri';
    }
    return 'Umum';
  }

  @override
  Widget build(BuildContext context) {
    final profileName = _activeProfile?.name.trim().isNotEmpty == true
        ? _activeProfile!.name
        : 'Pengguna';
    final avatarInitial = profileName.isNotEmpty
        ? profileName[0].toUpperCase()
        : 'A';
    final age = _activeProfile?.age ?? 0;
    final categoryLabel = _getCategoryLabel(_activeProfile);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Logo App (SVG)
              SvgPicture.asset('assets/images/anemify_logo.svg', height: 28),
              const SizedBox(height: 24),

              // Judul & Subjudul
              Text(
                'Ruang pribadimu',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2D42),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kamu yang memegang kendali atas datamu.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Card Profil Aktif (Dinamis dari Onboarding/Storage)
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : _buildProfileCard(
                      name: profileName,
                      subtitle: '$age tahun · $categoryLabel',
                      avatarInitial: avatarInitial,
                      onTap: () {},
                    ),
              const SizedBox(height: 28),

              // Section 1: Untuk Kamu & Keluarga
              _buildSectionTitle('Untuk kamu & keluarga'),
              const SizedBox(height: 12),
              _buildGroupedCard([
                _buildMenuItem(
                  icon: Icons
                      .menu_book_rounded, // Icon disesuaikan dengan Edukasi
                  title: 'Lihat onboarding awal',
                  subtitle: 'Pengenalan aplikasi & setup profil lokal',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.people_outline_rounded,
                  title: 'Kelola profil keluarga',
                  subtitle: '1 profil di perangkat ini',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Pengingat TTD & skrining',
                  subtitle: 'Atur rutinitas sehatmu',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 28),

              // Section 2: Data & Privasi
              _buildSectionTitle('Data & privasi'),
              const SizedBox(height: 12),
              _buildGroupedCard([
                _buildMenuItem(
                  icon: Icons.shield_outlined,
                  title: 'Tentang privasi data',
                  subtitle: 'Lokal. Pribadi. Milikmu.',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.file_download_outlined,
                  title: 'Ekspor data',
                  subtitle: 'Unduh cadangan profil dan riwayat',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.delete_outline_rounded,
                  title: 'Hapus semua data lokal',
                  subtitle: 'Hapus profil, riwayat, dan preferensi',
                  isDestructive: true,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              // Box Catatan Keamanan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF8D99AE),
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada akun. Tidak ada unggahan biometrik.\nEkspor berkala agar perjalanan sehatmu tetap tersimpan.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        height: 1.5,
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Footer Versi Aplikasi
              Center(
                child: Column(
                  children: [
                    Text(
                      'Anemify · Prototipe desain 1.0',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dibuat untuk langkah sehat yang lebih mudah',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2B2D42),
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String subtitle,
    required String avatarInitial,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    avatarInitial,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2B2D42),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2B2D42),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F2), width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final titleColor = isDestructive
        ? const Color(0xFFE63946)
        : const Color(0xFF2B2D42);
    final iconColor = isDestructive
        ? const Color(0xFFE63946)
        : const Color(0xFF6C757D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F2),
      indent: 52,
    );
  }
}
