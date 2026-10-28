import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/blur_sheet.dart';
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

  if (action == 'edit') {
    final active = await sl<GetActiveProfile>()();
    if (active == null || !context.mounted) return false;
    final p = await showBlurSheet<Profile>(
      context,
      child: ProfileFormSheet(initial: active),
    );
    if (p != null) await sl<UpdateProfile>()(p);
    return p != null;
  }

  return action == 'changed';
}