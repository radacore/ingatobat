import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import 'control_visit_screen.dart';
import 'medicine_detail_screen.dart';
import 'medicine_form_screen.dart';
import 'member_form_screen.dart';
import 'schedule_form_screen.dart';

class MemberDetailScreen extends ConsumerWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberProvider(memberId));
    final meds = ref.watch(medicinesProvider(memberId)).value ?? const [];
    final schedules =
        ref.watch(memberSchedulesProvider(memberId)).value ?? const [];
    final visits =
        ref.watch(memberControlVisitsProvider(memberId)).value ?? const [];
    final effects =
        ref.watch(memberSideEffectsProvider(memberId)).value ?? const [];
    final modes = ref.watch(alarmModesProvider).value ?? const {};
    final member = memberAsync.value;

    if (member == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final p = context.palette;
    final mode = modes[memberId] ?? 'monitor_only';

    Widget emptyCard(String text) => Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(text, style: TextStyle(color: p.textSecondary)),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          IconButton(
            tooltip: 'Ubah anggota',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => MemberFormScreen(member: member)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MedicineFormScreen(memberId: memberId),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Obat'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, 96),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  MemberAvatar(
                    name: member.name,
                    avatarPath: member.avatarPath,
                    thumbB64: member.avatarThumbB64,
                    size: 72,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: p.textPrimary,
                            )),
                        if (member.notes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(member.notes!,
                                style: TextStyle(color: p.textSecondary)),
                          ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                            '${meds.length} obat • ${schedules.length} jadwal aktif',
                            style: TextStyle(
                                color: p.accent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('Mode Alarm di Perangkat Ini'),
          Card(
            child: RadioGroup<String>(
              groupValue: mode,
              onChanged: (v) =>
                  ref.read(repositoryProvider).setAlarmMode(memberId, v!),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'full_alarm',
                    title: const Text('Alarm Keras'),
                    subtitle: const Text(
                        'Berbunyi nyaring di perangkat ini pada waktu minum'),
                    secondary:
                        SoftIcon(icon: Icons.alarm_on_rounded, color: p.primary),
                  ),
                  Divider(height: 1, color: p.divider),
                  RadioListTile<String>(
                    value: 'monitor_only',
                    title: const Text('Pantau Saja'),
                    subtitle: const Text(
                        'Tidak berbunyi; hanya menampilkan pengingat & status'),
                    secondary: SoftIcon(
                        icon: Icons.notifications_none_rounded, color: p.accent),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader('Obat (${meds.length})'),
          if (meds.isEmpty)
            emptyCard('Belum ada obat untuk anggota ini.')
          else
            ...meds.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Card(
                    child: ListTile(
                      leading: MedicineAvatar(
                        thumbB64: m.photoThumbB64,
                        filePath: m.photoPath,
                      ),
                      title: Text(m.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: p.textPrimary)),
                      subtitle: Text(
                        '${m.dosage} • ${formatQty(m.doseQty)} ${m.unit} • stok ${formatQty(m.stockQty)}',
                        style: TextStyle(color: p.textSecondary),
                      ),
                      trailing:
                          Icon(Icons.chevron_right, color: p.textHint),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MedicineDetailScreen(medicineId: m.id),
                        ),
                      ),
                    ),
                  ),
                )),
          SectionHeader('Jadwal Aktif (${schedules.length})'),
          if (schedules.isEmpty)
            emptyCard('Belum ada jadwal. Buat jadwal dari halaman obat.')
          else
            ...schedules.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Card(
                    child: ListTile(
                      leading: SoftIcon(
                          icon: Icons.schedule_rounded, color: p.primary),
                      title: Text(_scheduleSummary(s),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: p.textPrimary)),
                      subtitle: Text(
                        'Mulai ${Dates.dateShort(DateTime.fromMillisecondsSinceEpoch(s.startDate))}',
                        style: TextStyle(color: p.textSecondary),
                      ),
                      trailing:
                          Icon(Icons.edit_outlined, color: p.textSecondary),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScheduleFormScreen(
                            memberId: memberId,
                            schedule: s,
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          SectionHeader('Kontrol RS',
              trailing: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ControlVisitScreen(memberId: memberId)),
                ),
                icon: const Icon(Icons.local_hospital_outlined, size: 18),
                label: const Text('Kelola'),
              )),
          if (visits.where((v) => v.status == 'upcoming').isEmpty)
            emptyCard('Belum ada jadwal kontrol mendatang.')
          else
            ...visits
                .where((v) => v.status == 'upcoming')
                .take(3)
                .map((v) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Card(
                        child: ListTile(
                          leading: SoftIcon(
                              icon: Icons.local_hospital_rounded,
                              color: p.accent),
                          title: Text(v.hospital,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: p.textPrimary)),
                          subtitle: Text(
                            '${Dates.dateFull(DateTime.fromMillisecondsSinceEpoch(v.visitAt))} • ${Dates.time(DateTime.fromMillisecondsSinceEpoch(v.visitAt))}',
                            style: TextStyle(color: p.textSecondary),
                          ),
                          trailing: Text(
                              Dates.daysUntil(DateTime.fromMillisecondsSinceEpoch(
                                  v.visitAt)),
                              style: TextStyle(
                                  color: p.accent, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    )),
          SectionHeader('Efek Samping (${effects.length})'),
          if (effects.isEmpty)
            emptyCard('Belum ada catatan efek samping.')
          else
            ...effects.take(3).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Card(
                    child: ListTile(
                      leading: SoftIcon(
                          icon: Icons.warning_amber_rounded, color: p.warning),
                      title: Text(
                          e.kind == 'kustom' ? (e.customKind ?? 'Lainnya') : e.kind,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: p.textPrimary)),
                      subtitle: Text(
                        '${Dates.dateShort(DateTime.fromMillisecondsSinceEpoch(e.occurredAt))} • ${e.severity}',
                        style: TextStyle(color: p.textSecondary),
                      ),
                    ),
                  ),
                )),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => _confirmArchive(context, ref, member),
            icon: const Icon(Icons.archive_outlined),
            label: const Text('Arsipkan Anggota'),
            style: OutlinedButton.styleFrom(
              foregroundColor: p.error,
              side: BorderSide(color: p.error.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  String _scheduleSummary(Schedule s) {
    final times = _times(s);
    switch (s.recurrenceType) {
      case 'weekly':
        final days = _days(s);
        const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        final d = days.map((e) => names[(e - 1) % 7]).join(', ');
        return '$d • ${times.join(', ')}';
      case 'interval':
        return 'Setiap ${s.intervalHours ?? 24} jam • mulai ${times.first}';
      default:
        return 'Setiap hari • ${times.join(', ')}';
    }
  }

  List<String> _times(Schedule s) {
    try {
      return (s.timesJson.replaceAll('[', '').replaceAll(']', '').split(','))
          .map((e) => e.replaceAll('"', '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  List<int> _days(Schedule s) {
    try {
      return (s.daysOfWeek ?? '')
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .where((e) => e > 0)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _confirmArchive(
      BuildContext context, WidgetRef ref, Member member) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arsipkan Anggota?'),
        content: Text(
          'Semua jadwal aktif milik ${member.name} akan dinonaktifkan dan alarm terkait dibatalkan. '
          'Riwayat minum dan laporan tetap tersimpan.',
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
            child: const Text('Arsipkan'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(repositoryProvider).archiveMember(member.id);
    await ref.read(alarmCoordinatorProvider).rescheduleAll();
    if (context.mounted) Navigator.of(context).pop();
  }
}
