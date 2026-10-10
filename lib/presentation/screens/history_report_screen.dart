import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import 'medicine_detail_screen.dart';

/// Riwayat minum + laporan kepatuhan (FR-08, FR-09).
class HistoryReportScreen extends ConsumerWidget {
  const HistoryReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(historyFilterProvider);
    final logsAsync = ref.watch(historyProvider);
    final members = ref.watch(membersProvider).value ?? const [];
    final meds = ref.watch(allMedicinesIncludingArchivedProvider).value ??
        const [];

    final memberById = {for (final m in members) m.id: m};
    final medById = {for (final m in meds) m.id: m};
    final logs = logsAsync.value ?? const <DoseLog>[];

    final taken = logs.where((l) => l.status == 'taken').length;
    final missed = logs.where((l) => l.status == 'missed').length;
    final skipped = logs.where((l) => l.status == 'skipped').length;
    final relevant = logs.where((l) => l.status != 'pending').length;
    final onTime = relevant == 0 ? 0.0 : (taken / relevant) * 100;

    final hasFilter = filter.memberId != null ||
        filter.medicineId != null ||
        filter.status != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat & Laporan'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: Badge(
              isLabelVisible: hasFilter,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _openFilter(context, ref),
          ),
          PopupMenuButton<String>(
            tooltip: 'Ekspor laporan',
            onSelected: (v) async {
              final range = await showDateRangeSheet(context);
              if (range == null) return;
              if (!context.mounted) return;
              await _export(context, ref, v, range.from, range.to);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'csv', child: Text('Ekspor CSV')),
              PopupMenuItem(
                  value: 'pdf', child: Text('Ekspor PDF / Kirim ke Dokter')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (hasFilter)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (filter.memberId != null)
                      InputChip(
                        label: Text(
                            memberById[filter.memberId]?.name ?? 'Anggota'),
                        onDeleted: () => ref
                            .read(historyFilterProvider.notifier)
                            .setMember(null),
                      ),
                    if (filter.medicineId != null)
                      InputChip(
                        label: Text(medById[filter.medicineId]?.name ?? 'Obat'),
                        onDeleted: () => ref
                            .read(historyFilterProvider.notifier)
                            .setMedicine(null),
                      ),
                    if (filter.status != null)
                      InputChip(
                        label: Text(doseStatusLabel(filter.status!)),
                        onDeleted: () => ref
                            .read(historyFilterProvider.notifier)
                            .setStatus(null),
                      ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _summaryCard(
                context, logs.length, taken, missed, skipped, onTime),
          ),
          Expanded(
            child: logsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history,
                    title: 'Belum ada riwayat',
                    subtitle:
                        'Riwayat akan muncul setelah jadwal minum berjalan.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (_, i) => _HistoryTile(
                    log: list[i],
                    medicine: medById[list[i].medicineId],
                    member: memberById[list[i].memberId],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, int total, int taken, int missed,
      int skipped, double onTime) {
    final p = context.palette;
    final pct = onTime.toStringAsFixed(0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kepatuhan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: p.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        letterSpacing: -0.6,
                        color: p.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: (onTime / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: p.surfaceMuted,
                      color: p.primary,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(color: p.divider, height: 1),
            ),
            Row(
              children: [
                _mini(context, 'Total', '$total', p.textPrimary),
                _mini(context, 'Minum', '$taken', p.success),
                _mini(context, 'Terlewat', '$missed', p.error),
                _mini(context, 'Dilewati', '$skipped', p.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(BuildContext context, String label, String value, Color color) {
    final p = context.palette;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: p.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref, String kind,
      DateTime from, DateTime to) async {
    final filter = ref.read(historyFilterProvider);
    String? memberId = filter.memberId;
    if (memberId == null) {
      final members = await ref.read(databaseProvider).getActiveMembers();
      if (members.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belum ada anggota untuk dilaporkan.')),
          );
        }
        return;
      }
      if (members.length == 1) {
        memberId = members.first.id;
      } else {
        if (!context.mounted) return;
        final selected = await showModalBottomSheet<String>(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Text(
                    'Pilih Anggota',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: ctx.palette.textPrimary,
                    ),
                  ),
                ),
                ...members.map((m) => ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(m.name),
                      onTap: () => Navigator.pop(ctx, m.id),
                    )),
              ],
            ),
          ),
        );
        memberId = selected;
      }
    }
    if (memberId == null) return;

    final report =
        await ref.read(reportServiceProvider).build(memberId, from, to);
    if (kind == 'csv') {
      await ref.read(reportServiceProvider).shareCsv(report);
    } else {
      await ref.read(reportServiceProvider).sharePdf(report);
    }
  }

  Future<void> _openFilter(BuildContext context, WidgetRef ref) async {
    final filter = ref.read(historyFilterProvider);
    final members = ref.read(membersProvider).value ?? const [];
    final meds =
        ref.read(allMedicinesIncludingArchivedProvider).value ?? const [];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filter Riwayat',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: ctx.palette.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _filterLabel(ctx, 'Anggota'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: filter.memberId == null,
                    onSelected: (_) => ref
                        .read(historyFilterProvider.notifier)
                        .setMember(null),
                  ),
                  ...members.map((m) => ChoiceChip(
                        label: Text(m.name),
                        selected: filter.memberId == m.id,
                        onSelected: (_) => ref
                            .read(historyFilterProvider.notifier)
                            .setMember(m.id),
                      )),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _filterLabel(ctx, 'Obat'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: filter.medicineId == null,
                    onSelected: (_) => ref
                        .read(historyFilterProvider.notifier)
                        .setMedicine(null),
                  ),
                  ...meds.map((m) => ChoiceChip(
                        label: Text(m.name),
                        selected: filter.medicineId == m.id,
                        onSelected: (_) => ref
                            .read(historyFilterProvider.notifier)
                            .setMedicine(m.id),
                      )),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _filterLabel(ctx, 'Status'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: filter.status == null,
                    onSelected: (_) => ref
                        .read(historyFilterProvider.notifier)
                        .setStatus(null),
                  ),
                  ...['taken', 'missed', 'skipped', 'snoozed', 'pending']
                      .map((s) => ChoiceChip(
                            label: Text(doseStatusLabel(s)),
                            selected: filter.status == s,
                            onSelected: (_) => ref
                                .read(historyFilterProvider.notifier)
                                .setStatus(s),
                          )),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Terapkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterLabel(BuildContext ctx, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ctx.palette.textPrimary,
          ),
        ),
      );
}

class _HistoryTile extends ConsumerWidget {
  final DoseLog log;
  final Medicine? medicine;
  final Member? member;
  const _HistoryTile({required this.log, this.medicine, this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final at = DateTime.fromMillisecondsSinceEpoch(log.scheduledAt);
    return Card(
      child: InkWell(
        onTap: medicine == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        MedicineDetailScreen(medicineId: medicine!.id),
                  ),
                ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicineAvatar(
                thumbB64: medicine?.photoThumbB64,
                filePath: medicine?.photoPath,
                size: 46,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine?.name ?? 'Obat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${Dates.dateTimeFull(at)} • ${member?.name ?? ''}',
                      style: TextStyle(fontSize: 12.5, color: p.textSecondary),
                    ),
                    if (log.note != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        log.note!,
                        style: TextStyle(
                            color: p.textHint,
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(log.status),
                  const SizedBox(height: 2),
                  TextButton(
                    onPressed: () async {
                      final newStatus =
                          await showCorrectStatusSheet(context, log.status);
                      if (newStatus == null || newStatus == log.status) return;
                      await ref.read(doseServiceProvider).correctStatus(
                            log.id,
                            newStatus,
                            email: ref.read(familySessionProvider).email,
                          );
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Koreksi', style: TextStyle(fontSize: 12.5)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
