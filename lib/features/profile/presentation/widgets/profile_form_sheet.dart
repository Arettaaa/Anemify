import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/blur_sheet.dart';
import '../../data/profile_storage.dart';

/// Tambah (initial == null) atau ubah profil. Pop result: Profile
class ProfileFormSheet extends StatefulWidget {
  final Profile? initial;

  const ProfileFormSheet({super.key, this.initial});

  @override
  State<ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends State<ProfileFormSheet> {
  static const _categories = ['Umum', 'Ibu hamil', 'Remaja'];

  late final _nameCtrl = TextEditingController(text: widget.initial?.name);
  late final _ageCtrl =
      TextEditingController(text: widget.initial?.age.toString());
  late String _category = widget.initial?.category ?? 'Umum';

  bool get _isEdit => widget.initial != null;

  bool get _valid {
    final age = int.tryParse(_ageCtrl.text.trim());
    return _nameCtrl.text.trim().isNotEmpty &&
        age != null &&
        age > 0 &&
        age < 120;
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final age = int.parse(_ageCtrl.text.trim());
    final result = _isEdit
        ? widget.initial!.copyWith(name: name, age: age, category: _category)
        : Profile.create(name: name, age: age, category: _category);
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(title: _isEdit ? 'Ubah profil' : 'Tambah profil keluarga'),
        if (!_isEdit) ...[
          const SizedBox(height: 16),
          Text(
            'Tidak perlu akun. Setiap anggota keluarga punya riwayatnya sendiri.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 20),
        _label('Nama'),
        const SizedBox(height: 8),
        _field(_nameCtrl, 'Contoh: Ibu', TextInputType.name),
        const SizedBox(height: 18),
        _label('Usia'),
        const SizedBox(height: 8),
        _field(_ageCtrl, 'Usia dalam tahun', TextInputType.number),
        const SizedBox(height: 18),
        _label('Kategori'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _category,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textPrimary),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: AppColors.white,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: _decoration(null),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _category = v ?? _category),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _valid ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
              disabledForegroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Simpan profil',
                  style: GoogleFonts.dmSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.check_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );

  Widget _field(TextEditingController c, String hint, TextInputType type) {
    return TextField(
      controller: c,
      keyboardType: type,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
      decoration: _decoration(hint),
    );
  }

  InputDecoration _decoration(String? hint) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(
        fontSize: 14,
        color: AppColors.textSecondary.withOpacity(0.7),
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      border: border(AppColors.inactive),
      enabledBorder: border(AppColors.inactive),
      focusedBorder: border(AppColors.primarySoft),
    );
  }
}