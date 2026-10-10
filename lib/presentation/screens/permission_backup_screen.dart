import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../domain/services/alarm_service.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';

/// Izin sistem & pencadangan data (FR-10, FR-17, NFR-Reliability).
class PermissionBackupScreen extends ConsumerStatefulWidget {
  const PermissionBackupScreen({super.key});

  @override
  ConsumerState<PermissionBackupScreen> createState() =>
      _PermissionBackupScreenState();
}

class _PermissionBackupScreenState
    extends ConsumerState<PermissionBackupScreen> {
  bool _notif = false;
  bool _exact = false;
  bool _battery = false;
  bool _dnd = false;
  bool _busy = false;
  String _autoUri = '';
  int _lastBackup = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var notif = false, exact = false, battery = false, dnd = false;
    try {
      notif = await AlarmService.hasNotificationPermission();
      exact = await AlarmService.hasExactAlarmPermission();
      battery = await AlarmService.isIgnoringBatteryOptimizations();
      dnd = await AlarmService.hasDndAccess();
    } catch (_) {
      // Izin hanya tersedia di Android.
    }
    final db = ref.read(databaseProvider);
    final uri = await db.getSetting(SettingKeys.autoBackupUri) ?? '';
    final last =
        int.tryParse(await db.getSetting(SettingKeys.autoBackupLastAt) ?? '0') ??
            0;
    if (!mounted) return;
    setState(() {
      _notif = notif;
      _exact = exact;
      _battery = battery;
      _dnd = dnd;
      _autoUri = uri;
      _lastBackup = last;
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      _snack('Gagal: $e');
    }
  }

  Future<void> _requestNotification() async {
    await _guard(() async {
      await AlarmService.requestNotificationPermission();
      await Future.delayed(const Duration(milliseconds: 400));
      await _load();
    });
  }

  Future<void> _backupNow() async {
    setState(() => _busy = true);
    try {
      final file = await ref.read(backupServiceProvider).exportZip();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Cadangan data ${AppInfo.appName}',
        ),
      );
    } catch (e) {
      _snack('Gagal membuat cadangan: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFolder() async {
    await _guard(() async {
      final uri = await AlarmService.pickBackupFolder();
      if (uri == null || uri.isEmpty) return;
      await ref
          .read(databaseProvider)
          .setSetting(SettingKeys.autoBackupUri, uri);
      setState(() => _autoUri = uri);
      _snack('Folder cadangan otomatis disimpan.');
    });
  }

  Future<void> _runAutoBackup() async {
    setState(() => _busy = true);
    try {
      final ok = await ref.read(autoBackupServiceProvider).runNow();
      if (ok) {
        await _load();
        _snack('Cadangan otomatis berhasil.');
      } else {
        _snack('Atur folder cadangan terlebih dahulu.');
      }
    } catch (e) {
      _snack('Gagal mencadangkan: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final picked = await AlarmService.pickFile().catchError((_) => null);
    if (picked == null) return;
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pulihkan Data?'),
        content: const Text(
          'Seluruh data saat ini akan digantikan oleh isi file cadangan. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Pulihkan')),
        ],
      ),
    );
    if (ok != true) return;

    final result = await ref
        .read(backupServiceProvider)
        .restoreFromBytes(Uint8List.fromList(picked.bytes));
    if (!mounted) return;
    if (result.success) {
      await AlarmService.restartApp();
    } else {
      _snack(result.message);
    }
  }

  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool granted,
    required String actionLabel,
    required Future<void> Function() onAction,
  }) {
    final p = context.palette;
    final tone = granted ? p.success : p.warning;
    return Column(
      children: [
        ListTile(
          leading: SoftIcon(icon: icon, color: tone),
          title: Text(title,
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: p.textPrimary)),
          subtitle: Text(subtitle, style: TextStyle(color: p.textSecondary)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: p.highContrast
                  ? Colors.transparent
                  : tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: p.highContrast ? Border.all(color: tone) : null,
            ),
            child: Text(
              granted ? 'Aktif' : 'Belum',
              style: TextStyle(
                color: tone,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        if (!granted)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () => _guard(onAction),
                child: Text(actionLabel),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final lastLabel = _lastBackup > 0
        ? Dates.dateTimeFull(DateTime.fromMillisecondsSinceEpoch(_lastBackup))
        : 'Belum pernah';

    return Scaffold(
      appBar: AppBar(title: const Text('Izin & Backup')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xxl),
        children: [
          const SectionHeader('Izin Sistem'),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              'Agar alarm selalu berbunyi tepat waktu, izinkan akses berikut.',
              style: TextStyle(color: p.textSecondary, height: 1.4),
            ),
          ),
          Card(
            child: Column(
              children: [
                _permissionTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notifikasi',
                  subtitle: 'Menampilkan pengingat minum obat',
                  granted: _notif,
                  actionLabel: 'Izinkan',
                  onAction: _requestNotification,
                ),
                Divider(height: 1, color: p.divider),
                _permissionTile(
                  icon: Icons.alarm_rounded,
                  title: 'Alarm & pengingat',
                  subtitle: 'Alarm tepat waktu (Android 12+)',
                  granted: _exact,
                  actionLabel: 'Buka Pengaturan',
                  onAction: () async {
                    await AlarmService.openExactAlarmSettings();
                    await Future.delayed(const Duration(milliseconds: 600));
                    await _load();
                  },
                ),
                Divider(height: 1, color: p.divider),
                _permissionTile(
                  icon: Icons.battery_saver_rounded,
                  title: 'Bebas batas baterai',
                  subtitle: 'Cegah sistem menghentikan alarm',
                  granted: _battery,
                  actionLabel: 'Buka Pengaturan',
                  onAction: () async {
                    await AlarmService.openBatterySettings();
                    await Future.delayed(const Duration(milliseconds: 600));
                    await _load();
                  },
                ),
                Divider(height: 1, color: p.divider),
                _permissionTile(
                  icon: Icons.do_not_disturb_off_rounded,
                  title: 'Akses Jangan Ganggu',
                  subtitle: 'Alarm tetap berbunyi saat mode senyap',
                  granted: _dnd,
                  actionLabel: 'Buka Pengaturan',
                  onAction: () async {
                    await AlarmService.openDndSettings();
                    await Future.delayed(const Duration(milliseconds: 600));
                    await _load();
                  },
                ),
              ],
            ),
          ),
          const SectionHeader('Cadangan Lokal'),
          Card(
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.sd_storage_rounded,
                  title: 'Cadangan terakhir',
                  subtitle: lastLabel,
                ),
                Divider(height: 1, color: p.divider),
                InfoTile(
                  icon: Icons.folder_open_rounded,
                  title: 'Folder cadangan otomatis',
                  subtitle: _autoUri.isEmpty
                      ? 'Belum diatur'
                      : 'Aktif • cadangan mingguan',
                  onTap: _pickFolder,
                ),
                Divider(height: 1, color: p.divider),
                InfoTile(
                  icon: Icons.backup_rounded,
                  title: 'Cadangkan sekarang',
                  subtitle: 'Simpan & bagikan file cadangan',
                  onTap: _busy ? null : _backupNow,
                ),
                Divider(height: 1, color: p.divider),
                InfoTile(
                  icon: Icons.cloud_upload_rounded,
                  title: 'Cadangkan ke folder',
                  subtitle: 'Tulis ke folder yang dipilih',
                  onTap: _busy ? null : _runAutoBackup,
                ),
                Divider(height: 1, color: p.divider),
                InfoTile(
                  icon: Icons.restore_rounded,
                  title: 'Pulihkan dari file',
                  subtitle: 'Ganti data dengan isi cadangan',
                  onTap: _busy ? null : _restore,
                  color: p.warning,
                ),
              ],
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
