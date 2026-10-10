import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/alarm_service.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';

/// Jadwal kontrol RS + pengingat H-2 & H-1 (FR-16).
class ControlVisitScreen extends ConsumerWidget {
  final String memberId;
  const ControlVisitScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(memberControlVisitsProvider(memberId));
    final member = ref.watch(memberProvider(memberId)).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kontrol RS'),
        actions: [
          IconButton(
            tooltip: 'Kirim ringkasan ke RS',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: member == null
                ? null
                : () => _shareSummary(context, ref, member),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref, memberId: memberId),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kontrol'),
      ),
      body: visitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (visits) {
          if (visits.isEmpty) {
            return const EmptyState(
              icon: Icons.local_hospital_outlined,
              title: 'Belum ada jadwal kontrol',
              subtitle:
                  'Tambahkan jadwal kontrol ke RS agar mendapat pengingat H-2 dan H-1.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final v in visits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _VisitCard(visit: v, memberId: memberId),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _shareSummary(
      BuildContext context, WidgetRef ref, Member member) async {
    final range = await showDateRangeSheet(context);
    if (range == null) return;
    final report = await ref
        .read(reportServiceProvider)
        .build(member.id, range.from, range.to);
    await ref.read(reportServiceProvider).sharePdf(report);
  }
}

class _VisitCard extends ConsumerWidget {
  final ControlVisit visit;
  final String memberId;
  const _VisitCard({required this.visit, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final at = DateTime.fromMillisecondsSinceEpoch(visit.visitAt);
    final upcoming = visit.status == 'upcoming';
    final accent = upcoming ? p.accent : p.textSecondary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftIcon(icon: Icons.local_hospital_rounded, color: accent),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(visit.hospital,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: p.textPrimary)),
                      if (visit.doctor != null)
                        Text('Dokter: ${visit.doctor}',
                            style: TextStyle(color: p.textSecondary)),
                      const SizedBox(height: 2),
                      Text(Dates.dateTimeFull(at),
                          style: TextStyle(
                              color: p.primary, fontWeight: FontWeight.w600)),
                      if (visit.notes != null)
                        Text(visit.notes!,
                            style: TextStyle(
                                color: p.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      upcoming ? Dates.daysUntil(at) : 'Selesai',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        switch (v) {
                          case 'edit':
                            _openForm(context, ref,
                                memberId: memberId, visit: visit);
                          case 'done':
                            await ref
                                .read(repositoryProvider)
                                .updateControlVisit(
                                  visit.id,
                                  hospital: visit.hospital,
                                  doctor: visit.doctor,
                                  visitAt: at,
                                  notes: visit.notes,
                                  reminderH2At: visit.reminderH2At,
                                  reminderH1At: visit.reminderH1At,
                                  status: 'done',
                                );
                            await AlarmService.cancelAlarm('control_${visit.id}_h2');
                            await AlarmService.cancelAlarm('control_${visit.id}_h1');
                          case 'delete':
                            await ref
                                .read(repositoryProvider)
                                .deleteControlVisit(visit.id);
                            await AlarmService.cancelAlarm('control_${visit.id}_h2');
                            await AlarmService.cancelAlarm('control_${visit.id}_h1');
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Ubah')),
                        PopupMenuItem(
                            value: 'done', child: Text('Tandai selesai')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (upcoming &&
                (visit.reminderH2At != null || visit.reminderH1At != null)) ...[
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  if (visit.reminderH2At != null)
                    Chip(
                      avatar: Icon(Icons.notifications_active_rounded,
                          size: 16, color: p.accent),
                      label: const Text('Pengingat H-2'),
                    ),
                  if (visit.reminderH1At != null)
                    Chip(
                      avatar: Icon(Icons.notifications_active_rounded,
                          size: 16, color: p.accent),
                      label: const Text('Pengingat H-1'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _openForm(
  BuildContext context,
  WidgetRef ref, {
  required String memberId,
  ControlVisit? visit,
}) async {
  final hospital = TextEditingController(text: visit?.hospital ?? '');
  final doctor = TextEditingController(text: visit?.doctor ?? '');
  final notes = TextEditingController(text: visit?.notes ?? '');
  var at = visit == null
      ? DateTime.now().add(const Duration(days: 7))
      : DateTime.fromMillisecondsSinceEpoch(visit.visitAt);
  var reminderH2 = visit?.reminderH2At != null;
  var reminderH1 = visit?.reminderH1At != null;
  final formKey = GlobalKey<FormState>();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        final p = ctx.palette;
        return Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(visit == null ? 'Tambah Kontrol RS' : 'Ubah Kontrol RS',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary)),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: hospital,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Rumah sakit / klinik *',
                    prefixIcon: Icon(Icons.local_hospital_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: doctor,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama dokter (opsional)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: at,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date == null) return;
                    if (!ctx.mounted) return;
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(at),
                    );
                    if (time == null) return;
                    setSheet(() => at = DateTime(
                        date.year, date.month, date.day, time.hour, time.minute));
                  },
                  icon: const Icon(Icons.event),
                  label: Text('Tanggal: ${Dates.dateTimeFull(at)}'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: reminderH2,
                  onChanged: (v) => setSheet(() => reminderH2 = v),
                  title: const Text('Pengingat H-2'),
                  subtitle: const Text('Notifikasi 2 hari sebelum kontrol'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: reminderH1,
                  onChanged: (v) => setSheet(() => reminderH1 = v),
                  title: const Text('Pengingat H-1'),
                  subtitle: const Text('Notifikasi 1 hari sebelum kontrol'),
                  contentPadding: EdgeInsets.zero,
                ),
                TextFormField(
                  controller: notes,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    final repo = ref.read(repositoryProvider);
                    final session = ref.read(familySessionProvider);
                    final h2 = reminderH2
                        ? at.subtract(const Duration(days: 2)).millisecondsSinceEpoch
                        : null;
                    final h1 = reminderH1
                        ? at.subtract(const Duration(days: 1)).millisecondsSinceEpoch
                        : null;

                    String id;
                    if (visit == null) {
                      id = await repo.createControlVisit(
                        memberId: memberId,
                        hospital: hospital.text.trim(),
                        doctor: doctor.text.trim().isEmpty
                            ? null
                            : doctor.text.trim(),
                        visitAt: at,
                        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                        reminderH2At: h2,
                        reminderH1At: h1,
                        familyId: session.familyId,
                      );
                    } else {
                      id = visit.id;
                      await repo.updateControlVisit(
                        id,
                        hospital: hospital.text.trim(),
                        doctor: doctor.text.trim().isEmpty
                            ? null
                            : doctor.text.trim(),
                        visitAt: at,
                        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                        reminderH2At: h2,
                        reminderH1At: h1,
                        status: visit.status,
                      );
                    }

                    // Jadwalkan ulang pengingat native.
                    await AlarmService.cancelAlarm('control_${id}_h2');
                    await AlarmService.cancelAlarm('control_${id}_h1');
                    final now = DateTime.now().millisecondsSinceEpoch;
                    if (h2 != null && h2 > now) {
                      await AlarmService.scheduleAlarm(AlarmRequest(
                        id: 'control_${id}_h2',
                        triggerAtMs: h2,
                        title: 'Kontrol RS 2 hari lagi',
                        body: '${hospital.text.trim()} • ${Dates.dateTimeFull(at)}',
                        fullAlarm: false,
                        doseLogIds: const [],
                      ));
                    }
                    if (h1 != null && h1 > now) {
                      await AlarmService.scheduleAlarm(AlarmRequest(
                        id: 'control_${id}_h1',
                        triggerAtMs: h1,
                        title: 'Kontrol RS besok',
                        body: '${hospital.text.trim()} • ${Dates.dateTimeFull(at)}',
                        fullAlarm: false,
                        doseLogIds: const [],
                      ));
                    }
                    if (ctx.mounted) Navigator.pop(ctx, true);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
        );
      },
    ),
  );

  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jadwal kontrol tersimpan.')),
    );
  }
}
