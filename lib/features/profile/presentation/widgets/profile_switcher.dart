import 'package:flutter/material.dart';
import '../../../../core/widgets/blur_sheet.dart';
import '../../data/profile_storage.dart';
import 'profile_form_sheet.dart';
import 'profile_picker_sheet.dart';

/// Buka sheet pilih profil. Return true kalau ada perubahan.
Future<bool> openProfileSwitcher(BuildContext context) async {
  final action =
      await showBlurSheet<String>(context, child: const ProfilePickerSheet());
  if (!context.mounted) return action == 'changed';

  if (action == 'add') {
    final p = await showBlurSheet<Profile>(
      context,
      child: const ProfileFormSheet(),
    );
    if (p != null) await ProfileStorage.add(p);
    if (!context.mounted) return p != null;
    await openProfileSwitcher(context); // balik ke daftar
    return true;
  }

  if (action == 'edit') {
    final active = await ProfileStorage.getActive();
    if (active == null || !context.mounted) return false;
    final p = await showBlurSheet<Profile>(
      context,
      child: ProfileFormSheet(initial: active),
    );
    if (p != null) await ProfileStorage.update(p);
    return p != null;
  }

  return action == 'changed';
}