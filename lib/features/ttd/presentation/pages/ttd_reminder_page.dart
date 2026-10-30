import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/blur_sheet.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../scan/presentation/widgets/scan_widgets.dart';
import '../../domain/entities/ttd_settings.dart';
import '../../domain/usecases/ttd_usecases.dart';
import '../ttd_revision.dart';
import '../../../../core/widgets/app_switch.dart';
import '../ttd_reminder_sync.dart';

class TtdReminderPage extends StatefulWidget {
  const TtdReminderPage({super.key});

  @override
  State<TtdReminderPage> createState() => _TtdReminderPageState();
}

class _TtdReminderPageState extends State<TtdReminderPage> {
  TtdSettings? _s;
  bool _wasEnabled = false;
  bool _saving = false;
  Profile? _profile;

  String get _name => _profile?.name ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await sl<GetTtdSettings>()();
    final p = await sl<GetActiveProfile>()();
    if (!mounted) return;
    setState(() {
      _s = s;
      _wasEnabled = s.enabled;
      _profile = p;
    });
  }

  Future<void> _pickTime() async {
    final s = _s!;
    var picked = DateTime(2000, 1, 1, s.hour, s.minute);
    final ok = await showBlurSheet<bool>(
      context,
      child: Builder(
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHeader(title: 'Waktu pengingat'),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: scanStyle(
                      size: 22,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: picked,
                  onDateTimeChanged: (d) => picked = d,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ScanPrimaryButton(
              label: 'Pilih waktu',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) {
      setState(() => _s = s.copyWith(hour: picked.hour, minute: picked.minute));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    var s = _s!;
    if (s.enabled && !_wasEnabled) {
      s = s.copyWith(startDate: dayOnly(DateTime.now()));
    }
    await sl<SaveTtdSettings>()(s);
    notifyTtdChanged();

    final notif = NotificationService.instance;
    var granted = true;
    if (s.enabled || s.weeklyScreening) {
      granted = await notif.requestPermission();
    }
    await syncTtdReminders();
    if (!mounted) return;
    if (granted) {
      showAppToast(context, 'Jadwal TTD berhasil disimpan');
    } else {
      showAppToast(
        context,
        'Jadwal disimpan, tapi izin notifikasi belum aktif',
        type: ToastType.warning,
        actionLabel: 'Izinkan',
        onAction: notif.openSettings,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    if (s == null) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return ScanPageScaffold(
      children: [
        const ScanTitle(
          title: 'Pengingat sehat',
          subtitle: TextSpan(
            text: 'Atur rutinitas yang sesuai anjuran tenaga kesehatan.',
          ),
        ),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _switchRow(
                title: 'Tablet Tambah Darah',
                subtitle: _name.isEmpty ? null : 'Untuk $_name',
                value: s.enabled,
                onChanged: (v) => setState(() => _s = s.copyWith(enabled: v)),
              ),
              if (s.enabled) ...[
                const Divider(height: 28, color: AppColors.inactive),
                Text(
                  'Frekuensi sesuai anjuran',
                  style: scanStyle(size: 13, weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _dropdown<TtdFrequency>(
                  value: s.frequency,
                  items: const {
                    TtdFrequency.harian: 'Harian',
                    TtdFrequency.mingguan: 'Mingguan',
                  },
                  onChanged: (v) =>
                      setState(() => _s = s.copyWith(frequency: v)),
                ),
                if (s.frequency == TtdFrequency.mingguan) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Hari',
                    style: scanStyle(size: 13, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _dropdown<int>(
                    value: s.weekday,
                    items: hariNama,
                    onChanged: (v) =>
                        setState(() => _s = s.copyWith(weekday: v)),
                  ),
                ],
                const Divider(height: 28, color: AppColors.inactive),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Waktu pengingat',
                        style: scanStyle(size: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              s.timeLabel,
                              style: scanStyle(
                                size: 15,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.access_time_rounded,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Frekuensi disimpan per profil dan digunakan untuk menghitung '
                  'kepatuhan. Riwayat dihitung memakai jadwal yang dipilih saat '
                  'ini. Dosis dan frekuensi tetap mengikuti tenaga kesehatan.',
                  style: scanStyle(
                    size: 11.5,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _card(
          child: _switchRow(
            title: 'Skrining mingguan',
            subtitle: 'Setiap Senin · 08.00',
            value: s.weeklyScreening,
            onChanged: (v) =>
                setState(() => _s = s.copyWith(weeklyScreening: v)),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.pinkTint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Notifikasi muncul sesuai jam pengingat walau aplikasi ditutup, '
                  'bisa terlambat beberapa menit. Di beberapa HP, matikan '
                  'penghemat baterai untuk Anemify agar notifikasi tidak tertahan.',
                  style: scanStyle(
                    size: 12,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ScanPrimaryButton(
          label: _saving ? 'Menyimpan…' : 'Simpan pengingat',
          icon: Icons.check_rounded,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.inactive),
    ),
    child: child,
  );

  Widget _switchRow({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: scanStyle(size: 15, weight: FontWeight.w700)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: scanStyle(size: 12, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _dropdown<T>({
    required T value,
    required Map<T, String> items,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textPrimary,
      ),
      borderRadius: BorderRadius.circular(16),
      dropdownColor: AppColors.white,
      style: scanStyle(size: 14, weight: FontWeight.w700),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        for (final e in items.entries)
          DropdownMenuItem(value: e.key, child: Text(e.value)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
