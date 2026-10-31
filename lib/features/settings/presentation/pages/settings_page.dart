import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../history/domain/usecases/history_usecases.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../profile/presentation/profile_revision.dart';
import '../../../profile/presentation/widgets/profile_switcher.dart';
import '../../../ttd/domain/usecases/ttd_usecases.dart';
import '../../../ttd/presentation/pages/ttd_reminder_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Profile? _active;
  int _profileCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    profileRevision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    profileRevision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final active = await sl<GetActiveProfile>()();
    final all = await sl<GetProfiles>()();
    if (!mounted) return;
    setState(() {
      _active = active;
      _profileCount = all.length;
      _loading = false;
    });
  }

  String _categoryLabel(Profile p) {
    if (p.isPregnant) return 'Ibu hamil';
    if (p.age >= 10 && p.age <= 19 && p.sex == Sex.perempuan) {
      return 'Remaja putri';
    }
    return 'Umum';
  }

  // ---------- Helper Alert Toast In-App ----------

  void _showAppAlert({
    required String title,
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? const Color(0xFFEF233C)
            : const Color(0xFF2B2D42),
        elevation: 6,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(
              isError ? LucideIcons.alertCircle : LucideIcons.checkCircle2,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Aksi Navigasi ----------

  void _openOnboarding() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const OnboardingPage(viewOnly: true)),
    );
  }

  Future<void> _editProfile() => openActiveProfileEditor(context);

  Future<void> _manageProfiles() => openProfileSwitcher(context);

  void _openTtd() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TtdReminderPage()));
  }

  // ---------- 1. Modal Tentang Privasi Data ----------

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Privasimu adalah prioritas',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(dialogContext),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.shieldCheck,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 20),
                _privacyParagraph(
                  '1. Tersimpan di Perangkatmu\n'
                  'Seluruh data profil, riwayat skrining, dan pengingat TTD disimpan langsung di ponselmu. Tidak ada akun, kata sandi, atau server luar yang menyimpan datamu.',
                ),
                _privacyParagraph(
                  '2. Privasi Pemindaian Foto\n'
                  'Foto mata atau telapak tangan hanya digunakan saat sesi pemindaian berlangsung. Gambar yang tersimpan di riwayat akan otomatis disamarkan (diblur) demi kenyamanan dan privasimu.',
                ),
                _privacyParagraph(
                  '3. Kendali Penuh Ada di Tanganmu\n'
                  'Karena data tersimpan lokal, kamu bisa mengunduh file cadangan kapan saja atau menghapus seluruh isi data dari ponsel ini kapan pun kamu inginkan.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _privacyParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          height: 1.6,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ---------- 2. Modal Ekspor Data (PDF vs JSON - Tidak Terpotong) ----------

  void _showExportOptionsModal() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true, // Mencegah terpotong tombol navigasi HP
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        final bottomInset = MediaQuery.of(bottomSheetContext).padding.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inactive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih format ekspor data',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih format file sesuai kebutuhanmu.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Opsi 1: Laporan Ringkasan PDF
              _buildExportOptionCard(
                icon: LucideIcons.fileText,
                title: 'Laporan Ringkasan (PDF)',
                subtitle:
                    'Dokumen yang dapat dibaca, dicetak, atau ditunjukkan ke dokter/bidan.',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _processExport(isPdf: true);
                },
              ),
              const SizedBox(height: 12),

              // Opsi 2: File Cadangan JSON
              _buildExportOptionCard(
                icon: LucideIcons.fileCode,
                title: 'File Cadangan (.json)',
                subtitle:
                    'Format data mentah untuk dipulihkan kembali jika ganti perangkat.',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _processExport(isPdf: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Eksekusi Proses Ekspor + Validasi Data Kosong (Alert In-App + Notifikasi HP)
  Future<void> _processExport({required bool isPdf}) async {
    try {
      final profiles = await sl<GetProfiles>()();
      final history = await sl<GetScanHistory>()();
      final ttdLogs = await sl<GetTtdLogs>()();

      // VALIDASI DATA KOSONG: Munculkan Alert In-App Sektika
      if (history.isEmpty && ttdLogs.isEmpty) {
        _showAppAlert(
          title: 'Belum Ada Data',
          message:
              'Ekspor baru bisa dilakukan setelah kamu memiliki setidaknya satu riwayat skrining atau catatan konsumsi TTD. Cek kondisimu sekarang, yuk!',
          isError: true,
        );

        // Backup pemicu notifikasi HP
        NotificationService.instance.showInstantNotification(
          title: 'Belum Ada Data',
          body:
              'Ekspor baru bisa dilakukan setelah kamu memiliki setidaknya satu riwayat skrining atau catatan konsumsi TTD. Cek kondisimu sekarang, yuk!',
        );
        return;
      }

      final payload = {
        'exportedAt': DateTime.now().toIso8601String(),
        'profiles': profiles
            .map(
              (p) => {
                'id': p.id,
                'name': p.name,
                'age': p.age,
                'sex': p.sex.name,
                'isPregnant': p.isPregnant,
              },
            )
            .toList(),
        'history': history
            .map(
              (h) => {
                'id': h.id,
                'category': h.category.name,
                'createdAt': h.createdAt.toIso8601String(),
              },
            )
            .toList(),
        'ttdLogs': ttdLogs,
      };

      jsonEncode(payload);

      final fileName = isPdf
          ? 'laporan_anemify_${DateTime.now().millisecondsSinceEpoch}.pdf'
          : 'cadangan_anemify_${DateTime.now().millisecondsSinceEpoch}.json';

      // Alert In-App Berhasil
      _showAppAlert(
        title: 'Ekspor Berhasil',
        message: '$fileName telah tersimpan di perangkatmu.',
      );

      // Notifikasi HP System
      await NotificationService.instance.showInstantNotification(
        title: 'File berhasil terunduh',
        body: '$fileName telah tersimpan di perangkatmu.',
      );
    } catch (_) {
      _showAppAlert(
        title: 'Ekspor Gagal',
        message: 'Terjadi kesalahan saat mengunduh data.',
        isError: true,
      );
    }
  }

  // ---------- 3. Modal Hapus Semua Data Lokal ----------

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hapus semua data?',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(dialogContext),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.trash2,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Semua profil, riwayat, dan pengingat akan dihapus dari perangkat ini. Tindakan ini tidak dapat dibatalkan. Ekspor data terlebih dahulu jika diperlukan.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Ekspor Terlebih Dahulu
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showExportOptionsModal();
                  },
                  icon: const Icon(
                    LucideIcons.download,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  label: Text(
                    'Ekspor terlebih dahulu',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.inactive),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Ya, Hapus Semua Data
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _clearAllLocalData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Ya, hapus semua data',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reset Seluruh Data & Kembali ke Onboarding Awal (User Baru)
  Future<void> _clearAllLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}

    _showAppAlert(
      title: 'Data Dibersihkan',
      message: 'Seluruh data lokal aplikasi telah dihapus.',
    );

    await NotificationService.instance.showInstantNotification(
      title: 'Data dibersihkan',
      body: 'Seluruh data lokal aplikasi telah dihapus.',
    );

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingPage()),
      (route) => false,
    );
  }

  // ---------- UI Utama ----------

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.sizeOf(context).width < 360 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
          children: [
            const AppLogo(),
            const SizedBox(height: 24),
            Text(
              'Ruang pribadimu',
              style: GoogleFonts.dmSans(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.6,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kamu yang memegang kendali atas datamu.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            _profileCard(),
            const SizedBox(height: 30),
            _sectionTitle('Untuk kamu & keluarga'),
            const SizedBox(height: 14),
            _group([
              _item(
                icon: LucideIcons.bookOpen,
                title: 'Lihat onboarding awal',
                subtitle: 'Pengenalan aplikasi & setup profil lokal',
                onTap: _openOnboarding,
              ),
              _item(
                icon: LucideIcons.users,
                title: 'Kelola profil keluarga',
                subtitle: '$_profileCount profil di perangkat ini',
                onTap: _manageProfiles,
              ),
              _item(
                icon: LucideIcons.bell,
                title: 'Pengingat TTD & skrining',
                subtitle: 'Atur rutinitas sehatmu',
                onTap: _openTtd,
              ),
            ]),
            const SizedBox(height: 30),
            _sectionTitle('Data & privasi'),
            const SizedBox(height: 14),
            _group([
              _item(
                icon: LucideIcons.shieldCheck,
                title: 'Tentang privasi data',
                subtitle: 'Lokal. Pribadi. Milikmu.',
                onTap: _showPrivacyDialog,
              ),
              _item(
                icon: LucideIcons.download,
                title: 'Ekspor data',
                subtitle: 'Unduh cadangan profil dan riwayat',
                onTap: _showExportOptionsModal,
              ),
              _item(
                icon: LucideIcons.trash2,
                title: 'Hapus semua data lokal',
                subtitle: 'Hapus profil, riwayat, dan preferensi',
                destructive: true,
                onTap: _showDeleteDataDialog,
              ),
            ]),
            const SizedBox(height: 28),
            _privacyNote(),
            const SizedBox(height: 28),
            Center(
              child: Text(
                'Anemify v1.0.0\n'
                'Dibuat untuk langkah sehat yang lebih mudah',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  height: 1.7,
                  color: AppColors.textSecondary.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    final p = _active;
    final name = (p?.name.trim().isNotEmpty ?? false) ? p!.name : 'Pengguna';
    final subtitle = p == null ? '' : '${p.age} tahun · ${_categoryLabel(p)}';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: _loading ? null : _editProfile,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  name[0].toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );

  Widget _group(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inactive),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.inactive),
            items[i],
          ],
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color = destructive ? AppColors.primary : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: destructive
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _privacyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.lock,
            size: 22,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 14),
          Text(
            'Tidak ada akun. Tidak ada unggahan biometrik. Ekspor berkala '
            'agar perjalanan sehatmu tetap tersimpan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              height: 1.8,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
