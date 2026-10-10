import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../domain/services/family_sync.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import 'control_visit_screen.dart';
import 'family_join_setup_screen.dart';
import 'member_detail_screen.dart';
import 'member_form_screen.dart';
import 'permission_backup_screen.dart';
import 'settings_screen.dart';

/// Tab "Keluarga & Lainnya": grup keluarga, kontrol RS, stok menipis,
/// pengaturan, dan tentang aplikasi.
class FamilyMoreScreen extends ConsumerWidget {
  const FamilyMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final session = ref.watch(familySessionProvider);
    final members = ref.watch(membersProvider).value ?? const [];
    final lowStock = ref.watch(lowStockProvider).value ?? const [];
    final visits = ref.watch(allControlVisitsProvider).value ?? const [];
    final upcoming = visits.where((v) => v.status == 'upcoming').toList()
      ..sort((a, b) => a.visitAt.compareTo(b.visitAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Keluarga & Lainnya')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xxl),
        children: [
          _FamilyCard(session: session),
          const SectionHeader('Anggota Keluarga'),
          if (members.isEmpty)
            _emptyCard(context, 'Belum ada anggota keluarga.')
          else
            ...members.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      leading: MemberAvatar(
                        name: m.name,
                        avatarPath: m.avatarPath,
                        thumbB64: m.avatarThumbB64,
                        size: 46,
                      ),
                      title: Text(m.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                              color: p.textPrimary)),
                      subtitle: Text(m.notes ?? 'Tanpa catatan'),
                      trailing: Icon(Icons.chevron_right, color: p.textHint),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MemberDetailScreen(memberId: m.id),
                        ),
                      ),
                    ),
                  ),
                )),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MemberFormScreen()),
              ),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Tambah Anggota'),
            ),
          ),
          const SectionHeader('Kontrol RS Mendatang'),
          if (upcoming.isEmpty)
            _emptyCard(context, 'Belum ada jadwal kontrol mendatang.')
          else
            ...upcoming.take(4).map((v) {
              final member = members.where((m) => m.id == v.memberId).firstOrNull;
              final at = DateTime.fromMillisecondsSinceEpoch(v.visitAt);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    leading: SoftIcon(icon: Icons.local_hospital_rounded, color: p.accent),
                    title: Text(v.hospital,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.5,
                            color: p.textPrimary)),
                    subtitle: Text(
                        '${member?.name ?? ''} • ${Dates.dateFull(at)} ${Dates.time(at)}'),
                    trailing: Text(Dates.daysUntil(at),
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: p.accent)),
                    onTap: member == null
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ControlVisitScreen(memberId: member.id),
                              ),
                            ),
                  ),
                ),
              );
            }),
          if (lowStock.isNotEmpty) ...[
            const SectionHeader('Stok Menipis'),
            ...lowStock.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      leading: SoftIcon(
                          icon: Icons.warning_amber_rounded, color: p.warning),
                      title: Text(m.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.5,
                              color: p.textPrimary)),
                      subtitle: Text(
                          'Sisa ${formatQty(m.stockQty)} ${m.unit} (batas ${formatQty(m.lowStockThreshold)})'),
                    ),
                  ),
                )),
          ],
          const SectionHeader('Lainnya'),
          Card(
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.settings_rounded,
                  title: 'Pengaturan',
                  subtitle: 'Tampilan, alarm, suara, dan aksesibilitas',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                Divider(height: 1, indent: 72, color: p.divider),
                InfoTile(
                  icon: Icons.security_rounded,
                  title: 'Izin & Backup',
                  subtitle: 'Izin sistem dan pencadangan data',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PermissionBackupScreen()),
                  ),
                ),
                Divider(height: 1, indent: 72, color: p.divider),
                InfoTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang ${AppInfo.appName}',
                  subtitle: 'Versi ${AppInfo.version} • Gratis selamanya',
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final p = context.palette;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.medication_rounded, color: p.primary, size: 40),
        title: Text('${AppInfo.appName} ${AppInfo.version}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengingat obat keluarga yang bekerja penuh secara offline, '
              'tanpa biaya. Sinkronisasi antar-anggota keluarga opsional '
              'lewat akun Google.',
              style: TextStyle(color: p.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Jadwal & alarm • Stok • Laporan • Efek samping',
              style: TextStyle(
                color: p.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'IngatObat membantu mengingat jadwal, bukan menggantikan nasihat '
              'dokter. Selalu ikuti anjuran tenaga kesehatan.',
              style: TextStyle(color: p.textHint, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(BuildContext context, String text) {
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(text, style: TextStyle(color: p.textSecondary)),
      ),
    );
  }
}

class _FamilyCard extends ConsumerWidget {
  final FamilySession session;
  const _FamilyCard({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    if (!session.isLoggedIn) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SoftIcon(icon: Icons.family_restroom, color: p.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Grup Keluarga',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: p.textPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Masuk dengan akun Google untuk mengaktifkan sinkronisasi antar perangkat keluarga. '
                'Tanpa login, aplikasi tetap berjalan penuh secara offline.',
                style: TextStyle(
                    color: p.textSecondary, fontSize: 14, height: 1.45),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const FamilyJoinSetupScreen()),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text('Masuk / Buat Grup'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: p.highContrast
                        ? Colors.transparent
                        : p.primaryContainer,
                    shape: BoxShape.circle,
                    border: p.highContrast ? Border.all(color: p.primary) : null,
                  ),
                  child: Icon(Icons.family_restroom, color: p.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.familyName ?? 'Grup Keluarga',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: p.textPrimary)),
                      const SizedBox(height: 2),
                      Text(session.email ?? '',
                          style: TextStyle(
                              color: p.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Chip(
                  label: Text(session.role == 'admin' ? 'Admin' : 'Anggota'),
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(
                    session.role == 'admin'
                        ? Icons.shield_outlined
                        : Icons.person_outline,
                    size: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _invite(context, ref),
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Undang'),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _sync(context, ref),
                    icon: const Icon(Icons.sync),
                    label: const Text('Sinkron'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showAccessList(context, ref),
                icon: const Icon(Icons.group, size: 18),
                label: const Text('Lihat akses anggota'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final email = await showInviteEmailSheet(context);
    if (email == null) return;
    try {
      await ref.read(familySyncProvider).inviteEmail(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Undangan dikirim ke $email')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengundang: $e')),
        );
      }
    }
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final status = await ref.read(familySyncProvider).syncNow();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(status == SyncStatus.synced
                ? 'Data keluarga tersinkron.'
                : 'Sinkronisasi gagal. Coba lagi.')),
      );
    }
  }

  Future<void> _showAccessList(BuildContext context, WidgetRef ref) async {
    final access = await ref.read(familySyncProvider).listAccess();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('Akses Anggota',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: ctx.palette.textPrimary)),
            ),
            ...access.map((a) => ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(a.email),
                  subtitle: Text(
                      a.status == 'joined' ? 'Sudah bergabung' : 'Menunggu'),
                  trailing: IconButton(
                    tooltip: 'Cabut akses',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref.read(familySyncProvider).revokeEmail(a.email);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
