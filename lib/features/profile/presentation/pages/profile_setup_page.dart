import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../../onboarding/presentation/widgets/onboarding_consent_box.dart';
import '../../../onboarding/presentation/widgets/onboarding_header.dart';
import '../../../onboarding/presentation/widgets/onboarding_primary_button.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../widgets/profile_fields.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  Sex? _sex;
  bool _pregnant = false;
  bool _consent = false;

  int? get _age => int.tryParse(_ageCtrl.text.trim());
  bool get _canBePregnant => Profile.canBePregnant(_sex, _age);

  bool get _valid {
    final age = _age;
    return _nameCtrl.text.trim().isNotEmpty &&
        age != null &&
        age > 0 &&
        age < 120 &&
        _sex != null &&
        _consent;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    await sl<AddProfile>()(
      Profile.create(
        name: name,
        age: _age!,
        sex: _sex!,
        pregnant: _pregnant,
      ),
      setActive: true,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WelcomePage(name: name)),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnboardingHeader(),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_rounded,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Kembali',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'LANGKAH TERAKHIR',
                            style: GoogleFonts.dmSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kenalan sedikit,\nmulai hidup lebih sehat.',
                      style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -0.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cukup profil di perangkat ini. Tidak perlu email, kata sandi, atau akun.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        height: 1.7,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _profileCard(),
                    const SizedBox(height: 24),
                    _label('Tentang kamu', bold: true),
                    const SizedBox(height: 16),
                    _label('Nama panggilan'),
                    const SizedBox(height: 8),
                    _field(_nameCtrl, 'Contoh: Nadia', TextInputType.name),
                    const SizedBox(height: 16),
                    _label('Usia'),
                    const SizedBox(height: 8),
                    _field(_ageCtrl, 'Usia dalam tahun', TextInputType.number),
                    const SizedBox(height: 16),
                    _label('Jenis kelamin'),
                    const SizedBox(height: 8),
                    SexSelector(
                      value: _sex,
                      onChanged: (s) => setState(() => _sex = s),
                    ),
                    PregnancySwitch(
                      visible: _canBePregnant,
                      value: _pregnant && _canBePregnant,
                      onChanged: (v) => setState(() => _pregnant = v),
                    ),
                    const SizedBox(height: 16),
                    OnboardingConsentBox(
                      outlined: true,
                      checked: _consent,
                      onChanged: (v) => setState(() => _consent = v),
                      title: 'Persetujuan penggunaan data',
                      text:
                          'Saya setuju data profil dan riwayat skrining disimpan secara lokal di perangkat ini, dan hanya digunakan untuk keperluan aplikasi.',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.people_outline,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Profil keluarga bisa ditambahkan nanti. Data profil tidak dipakai model skrining dan bukan dasar diagnosis atau resep TTD.',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              height: 1.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  OnboardingPrimaryButton(
                    label: 'Simpan & mulai',
                    onPressed: _valid ? _save : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tanpa login. Data lokal. Kamu yang memegang kendali.',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
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

  Widget _profileCard() {
    final name = _nameCtrl.text.trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Profil pertamamu' : name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Milikmu, tersimpan secara lokal',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_user_outlined,
              size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _label(String text, {bool bold = false}) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primarySoft),
        ),
      ),
    );
  }
}