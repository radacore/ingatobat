import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import 'medicine_form_screen.dart';
import 'schedule_form_screen.dart';
import 'side_effect_form_screen.dart';

class MedicineDetailScreen extends ConsumerWidget {
  final String medicineId;
  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medAsync = ref.watch(medicineProvider(medicineId));
    final ledger = ref.watch(ledgerProvider(medicineId)).value ?? const [];
    final effects =
        ref.watch(medicineSideEffectsProvider(medicineId)).value ?? const [];
    final medicine = medAsync.value;

    if (medicine == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final p = context.palette;
    final low = medicine.stockQty <= medicine.lowStockThreshold;

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        actions: [
          IconButton(
            tooltip: 'Ubah obat',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => MedicineFormScreen(medicine: medicine)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xxl),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  MedicineAvatar(
                    thumbB64: medicine.photoThumbB64,
                    filePath: medicine.photoPath,
                    size: 88,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(medicine.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: p.textPrimary,
                            )),
                        const SizedBox(height: 2),
                        Text(medicine.dosage,
                            style: TextStyle(color: p.textSecondary)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${formatQty(medicine.doseQty)} ${medicine.unit} sekali minum',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: p.textPrimary),
                        ),
                        Text(
                          MedicineCatalog.mealRelationLabel(medicine.mealRelation),
                          style: TextStyle(
                              color: p.accent, fontSize: 13, height: 1.4),
                        ),
                        if (medicine.notes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(medicine.notes!,
                                style: TextStyle(
                                    color: p.textSecondary, height: 1.4)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('Stok'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  SoftIcon(
                    icon: low
                        ? Icons.warning_amber_rounded
                        : Icons.inventory_2_rounded,
                    color: low ? p.warning : p.accent,
                    size: 48,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatQty(medicine.stockQty)} ${medicine.unit}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: low ? p.warning : p.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          low
                              ? 'Stok menipis (batas ${formatQty(medicine.lowStockThreshold)})'
                              : 'Batas menipis: ${formatQty(medicine.lowStockThreshold)}',
                          style: TextStyle(
                              color: low ? p.warning : p.textSecondary,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton.icon(
                    onPressed: () async {
                      final add =
                          await showRestockSheet(context, medicine.name);
                      if (add == null) return;
                      await ref
                          .read(repositoryProvider)
                          .adjustStock(medicine.id, add, reason: 'restock');
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(
            'Riwayat Stok (${ledger.length})',
            trailing: TextButton.icon(
              onPressed: () => _showAdjustSheet(context, ref, medicine),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Sesuaikan'),
            ),
          ),
          if (ledger.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text('Belum ada perubahan stok.',
                    style: TextStyle(color: p.textSecondary)),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < ledger.length && i < 10; i++) ...[
                    if (i > 0) Divider(height: 1, color: p.divider),
                    ListTile(
                      dense: true,
                      leading: Icon(
                        ledger[i].delta >= 0
                            ? Icons.add_circle_rounded
                            : Icons.remove_circle_rounded,
                        color:
                            ledger[i].delta >= 0 ? p.success : p.error,
                      ),
                      title: Text(
                        '${ledger[i].delta >= 0 ? '+' : ''}${formatQty(ledger[i].delta)} ${medicine.unit}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: p.textPrimary),
                      ),
                      subtitle: Text(
                        '${_reasonLabel(ledger[i].reason)} • ${Dates.dateTimeFull(DateTime.fromMillisecondsSinceEpoch(ledger[i].createdAt))}',
                        style: TextStyle(color: p.textSecondary),
                      ),
                      trailing: Text('Sisa ${formatQty(ledger[i].balanceAfter)}',
                          style: TextStyle(color: p.textSecondary)),
                    ),
                  ],
                ],
              ),
            ),
          SectionHeader(
            'Jadwal Minum',
            trailing: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScheduleFormScreen(
                    memberId: medicine.memberId,
                    medicineId: medicine.id,
                  ),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
            ),
          ),
          _SchedulesOfMedicine(medicineId: medicine.id),
          SectionHeader(
            'Efek Samping (${effects.length})',
            trailing: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SideEffectFormScreen(medicine: medicine),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Catat'),
            ),
          ),
          if (effects.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text('Belum ada catatan efek samping.',
                    style: TextStyle(color: p.textSecondary)),
              ),
            )
          else
            ...effects.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Card(
                    child: ListTile(
                      leading: SoftIcon(
                          icon: Icons.warning_amber_rounded,
                          color: p.warning),
                      title: Text(e.kind == 'kustom'
                          ? (e.customKind ?? 'Lainnya')
                          : e.kind),
                      subtitle: Text(
                        '${SideEffectCatalog.severities[e.severity] ?? e.severity} • ${Dates.dateShort(DateTime.fromMillisecondsSinceEpoch(e.occurredAt))}${e.note != null ? ' • ${e.note}' : ''}',
                        style: TextStyle(color: p.textSecondary),
                      ),
                      trailing: IconButton(
                        tooltip: 'Hapus catatan',
                        icon: Icon(Icons.delete_outline, color: p.error),
                        onPressed: () => ref
                            .read(repositoryProvider)
                            .deleteSideEffect(e.id),
                      ),
                    ),
                  ),
                )),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _confirmArchive(context, ref, medicine),
            icon: const Icon(Icons.archive_outlined),
            label: const Text('Arsipkan Obat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: p.error,
              side: BorderSide(color: p.error.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  String _reasonLabel(String reason) {
    switch (reason) {
      case 'restock':
        return 'Tambah stok';
      case 'taken':
        return 'Dosis diminum';
      case 'correction':
        return 'Koreksi';
      case 'adjust':
        return 'Penyesuaian';
      default:
        return reason;
    }
  }

  Future<void> _showAdjustSheet(
      BuildContext context, WidgetRef ref, Medicine medicine) async {
    final p = context.palette;
    final controller = TextEditingController();
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sesuaikan Stok',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: p.textPrimary)),
            const SizedBox(height: 4),
            Text(
              'Gunakan angka negatif untuk mengurangi (mis. -2 untuk koreksi).',
              style: TextStyle(color: p.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Perubahan stok'),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(controller.text.replaceAll(',', '.'));
                if (v != null && v != 0) Navigator.pop(ctx, v);
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    await ref
        .read(repositoryProvider)
        .adjustStock(medicine.id, result, reason: 'adjust');
  }

  Future<void> _confirmArchive(
      BuildContext context, WidgetRef ref, Medicine medicine) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arsipkan Obat?'),
        content: Text(
            'Jadwal aktif untuk ${medicine.name} akan dinonaktifkan dan alarm dibatalkan. Riwayat tetap tersimpan.'),
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
    await ref.read(repositoryProvider).archiveMedicine(medicine.id);
    await ref.read(alarmCoordinatorProvider).rescheduleAll();
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _SchedulesOfMedicine extends ConsumerWidget {
  final String medicineId;
  const _SchedulesOfMedicine({required this.medicineId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return FutureBuilder<List<Schedule>>(
      future: ref.watch(databaseProvider).getSchedulesOfMedicine(medicineId),
      builder: (context, snap) {
        final schedules = snap.data ?? const <Schedule>[];
        if (schedules.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text('Belum ada jadwal untuk obat ini.',
                  style: TextStyle(color: p.textSecondary)),
            ),
          );
        }
        return Column(
          children: schedules
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Card(
                      child: ListTile(
                        leading: SoftIcon(
                            icon: Icons.schedule_rounded, color: p.primary),
                        title: Text(_summary(s),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: p.textPrimary)),
                        trailing: Icon(Icons.edit_outlined,
                            color: p.textSecondary),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ScheduleFormScreen(
                              memberId: s.memberId,
                              schedule: s,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  String _summary(Schedule s) {
    final times = s.timesJson
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((e) => e.replaceAll('"', '').trim())
        .where((e) => e.isNotEmpty)
        .join(', ');
    switch (s.recurrenceType) {
      case 'weekly':
        return 'Mingguan • $times';
      case 'interval':
        return 'Setiap ${s.intervalHours ?? 24} jam';
      default:
        return 'Setiap hari • $times';
    }
  }
}
