import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/blur_sheet.dart';
import '../../../history/domain/usecases/history_usecases.dart';
import '../../../history/presentation/history_revision.dart';
import '../../../ttd/domain/usecases/ttd_usecases.dart';
import '../../../ttd/presentation/ttd_revision.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../profile_revision.dart';
import 'profile_form_sheet.dart';
import 'profile_picker_sheet.dart';

Future<bool> openProfileSwitcher(BuildContext context) async {
  final changed = await _open(context);
  if (changed) notifyProfileChanged();
  return changed;
}

/// Langsung buka form ubah profil aktif (dipakai di Pengaturan).
Future<bool> openActiveProfileEditor(BuildContext context) async {
  final changed = await _editActive(context);
  if (changed) notifyProfileChanged();
  return changed;
}

Future<bool> _editActive(BuildContext context) async {
  final active = await sl<GetActiveProfile>()();
  final all = await sl<GetProfiles>()();
  if (active == null || !context.mounted) return false;

  final res = await showBlurSheet<Object>(
    context,
    child: ProfileFormSheet(initial: active, canDelete: all.length > 1),
  );

  if (res is Profile) {
    await sl<UpdateProfile>()(res);
    await _refreshTtdNotification(res); // nama/kategori bisa berubah
    return true;
  }

  if (res == kDeleteProfile && context.mounted) {
    final ok = await showBlurSheet<bool>(
      context,
      child: _DeleteConfirmSheet(profile: active),
    );
    if (ok != true) return false;
    await _deleteActive(active);
    if (context.mounted) {
      showAppToast(context, 'Profil ${active.name} dihapus');
    }
    return true;
  }
  return false;
}

Future<bool> _open(BuildContext context) async {
  final action =
      await showBlurSheet<String>(context, child: const ProfilePickerSheet());
  if (!context.mounted) return action == 'changed';

  if (action == 'add') {
    final p = await showBlurSheet<Profile>(
      context,
      child: const ProfileFormSheet(),
    );
    if (p != null) await sl<AddProfile>()(p);
    if (!context.mounted) return p != null;
    await _open(context); // balik ke daftar
    return true;
  }

  if (action == 'edit') return _editActive(context);

  return action == 'changed';
}

/// Hapus profil aktif beserta riwayat skrining, data TTD, dan pengingatnya.
/// Urutan penting: data dibersihkan selagi profil ini masih aktif.
Future<void> _deleteActive(Profile p) async {
  await sl<ClearHistory>()();
  await sl<ClearTtdData>()();
  await NotificationService.instance.cancelTtd(p.id);
  await sl<DeleteProfile>()(p.id);
  notifyHistoryChanged();
  notifyTtdChanged();
}

Future<void> _refreshTtdNotification(Profile p) async {
  final s = await sl<GetTtdSettings>()();
  if (!s.enabled && !s.weeklyScreening) return;
  await NotificationService.instance.applyTtd(settings: s, profile: p);
}

class _DeleteConfirmSheet extends StatelessWidget {
  final Profile profile;
  const _DeleteConfirmSheet({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetHeader(title: 'Hapus profil?'),
        const SizedBox(height: 14),
        Text(
          'Profil ${profile.name} beserta riwayat skrining, catatan TTD, dan '
          'pengingatnya akan dihapus dari perangkat ini. Tindakan ini tidak '
          'bisa dibatalkan.',
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            height: 1.7,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Ya, hapus profil',
              style: GoogleFonts.dmSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 46,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.dmSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}