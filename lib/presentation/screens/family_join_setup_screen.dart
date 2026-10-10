import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';

/// Masuk / buat grup keluarga (FR-18). Berjalan penuh secara offline;
/// sinkronisasi cloud aktif otomatis saat Firebase dikonfigurasi.
class FamilyJoinSetupScreen extends ConsumerStatefulWidget {
  const FamilyJoinSetupScreen({super.key});

  @override
  ConsumerState<FamilyJoinSetupScreen> createState() =>
      _FamilyJoinSetupScreenState();
}

class _FamilyJoinSetupScreenState extends ConsumerState<FamilyJoinSetupScreen> {
  final _nameController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      await ref.read(familySyncProvider).signInWithGoogle();
      final db = ref.read(databaseProvider);
      final email = await db.getSetting(SettingKeys.currentUserEmail) ?? '';
      final familyId = await db.getSetting(SettingKeys.currentFamilyId) ?? '';
      var familyName =
          await db.getSetting(SettingKeys.familyName) ?? 'Keluarga Saya';
      final role =
          await db.getSetting(SettingKeys.currentUserRole) ?? 'admin';
      final typed = _nameController.text.trim();
      if (typed.isNotEmpty) {
        familyName = typed;
        await db.setSetting(SettingKeys.familyName, familyName);
      }
      await ref.read(familySessionProvider.notifier).save(
            email: email,
            familyId: familyId,
            familyName: familyName,
            role: role,
          );
      _snack('Berhasil masuk. Grup keluarga aktif.');
    } catch (e) {
      _snack('Gagal masuk: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invite() async {
    final email = await showInviteEmailSheet(context);
    if (email == null) return;
    try {
      await ref.read(familySyncProvider).inviteEmail(email);
      _snack('Undangan dikirim ke $email');
    } catch (e) {
      _snack('Gagal mengundang: $e');
    }
  }

  Future<void> _leave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Grup?'),
        content: const Text(
          'Data obat di perangkat ini tetap tersimpan, namun tidak lagi '
          'tersinkron dengan anggota keluarga lain.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(familySyncProvider).leaveFamily();
    await ref.read(familySessionProvider.notifier).clear();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun & Data Cloud?'),
        content: const Text(
          'Seluruh data anggota, obat, jadwal, dan riwayat akan dihapus '
          'permanen. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: ctx.palette.error,
              foregroundColor: ctx.palette.onPrimary,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(familySyncProvider).deleteAccountAndCloud();
    await ref.read(familySessionProvider.notifier).clear();
    if (mounted) {
      _snack('Akun dan data telah dihapus.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(familySessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grup Keluarga')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xxl),
        children: session.isLoggedIn ? _loggedIn(session) : _loggedOut(),
      ),
    );
  }

  List<Widget> _loggedOut() {
    final p = context.palette;
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SoftIcon(
                      icon: Icons.family_restroom_rounded, color: p.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Satu Keluarga, Satu Jadwal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: p.textPrimary,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Masuk dengan akun Google agar anggota keluarga lain dapat '
                'memantau dan mengonfirmasi obat yang sudah diminum.',
                style: TextStyle(color: p.textSecondary, height: 1.45),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama grup keluarga (opsional)',
                  hintText: 'mis. Keluarga Bapak',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _busy ? null : _signIn,
                icon: const Icon(Icons.login_rounded),
                label: Text(_busy ? 'Memproses…' : 'Masuk dengan Google'),
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56)),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 16, color: p.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Tanpa login pun aplikasi tetap berjalan penuh secara offline.',
                style: TextStyle(color: p.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _loggedIn(FamilySession session) {
    final p = context.palette;
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SoftIcon(icon: Icons.family_restroom_rounded, color: p.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.familyName ?? 'Grup Keluarga',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: p.textPrimary,
                        )),
                    Text(session.email ?? '',
                        style: TextStyle(color: p.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Chip(
                label: Text(session.role == 'admin' ? 'Admin' : 'Anggota'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      FilledButton.icon(
        onPressed: _invite,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Undang Anggota Keluarga'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
      ),
      const SizedBox(height: AppSpacing.lg),
      const SectionHeader('Kelola Grup'),
      Card(
        child: Column(
          children: [
            InfoTile(
              icon: Icons.logout_rounded,
              title: 'Keluar dari grup',
              subtitle: 'Berhenti sinkron, data tetap di perangkat',
              onTap: _leave,
              color: p.warning,
            ),
            Divider(height: 1, color: p.divider),
            InfoTile(
              icon: Icons.delete_forever_rounded,
              title: 'Hapus akun & data cloud',
              subtitle: 'Hapus permanen seluruh data',
              onTap: _deleteAccount,
              color: p.error,
            ),
          ],
        ),
      ),
    ];
  }
}
