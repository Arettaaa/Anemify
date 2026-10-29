import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/blur_sheet.dart';
import '../../domain/entities/profile.dart';
import 'profile_fields.dart';

const kDeleteProfile = 'delete';

/// Tambah (initial == null) atau ubah profil.
/// Pop result: Profile, atau [kDeleteProfile] (hanya saat ubah & [canDelete]).
class ProfileFormSheet extends StatefulWidget {
  final Profile? initial;
  final bool canDelete;

  const ProfileFormSheet({super.key, this.initial, this.canDelete = false});

  @override
  State<ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends State<ProfileFormSheet> {
  late final _nameCtrl = TextEditingController(text: widget.initial?.name);
  late final _ageCtrl =
      TextEditingController(text: widget.initial?.age.toString());
  late Sex? _sex = widget.initial?.sex;
  late bool _pregnant = widget.initial?.isPregnant ?? false;

  bool get _isEdit => widget.initial != null;
  int? get _age => int.tryParse(_ageCtrl.text.trim());
  bool get _canBePregnant => Profile.canBePregnant(_sex, _age);

  bool get _valid {
    final age = _age;
    return _nameCtrl.text.trim().isNotEmpty &&
        age != null &&
        age > 0 &&
        age < 120 &&
        _sex != null;
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final result = _isEdit
        ? widget.initial!.copyWith(
            name: name, age: _age, sex: _sex, pregnant: _pregnant)
        : Profile.create(
            name: name, age: _age!, sex: _sex!, pregnant: _pregnant);
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
                if (_isEdit && widget.canDelete) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(kDeleteProfile),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(
                'Hapus profil',
                style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.inactive),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.inactive),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primarySoft),
        ),
      ),
    );
  }
}