import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/alarm_service.dart';
import '../../domain/services/widget_service.dart';
import '../providers/providers.dart';
import 'common.dart';
import 'sheets.dart';

/// Aksi cepat dosis (FR-05, FR-06) — dipakai layar Hari Ini, Riwayat, dan Alarm.
class DoseActions {
  final WidgetRef ref;
  const DoseActions(this.ref);

  Future<void> taken(DoseLog log) async {
    final session = ref.read(familySessionProvider);
    await ref.read(doseServiceProvider).markTaken(log.id, email: session.email);
    await AlarmService.cancelAlarm('dose_${log.scheduledAt}');
    await WidgetService.refresh(ref.read(databaseProvider));
    await _checkLowStock(log.medicineId);
  }

  Future<bool> snooze(DoseLog log, int minutes) async {
    final ok = await ref.read(doseServiceProvider).snooze(log.id, minutes);
    if (ok) {
      await ref.read(alarmCoordinatorProvider).rescheduleAll();
    }
    return ok;
  }

  Future<void> skip(DoseLog log, String reason) async {
    final session = ref.read(familySessionProvider);
    await ref.read(doseServiceProvider)
        .markSkipped(log.id, reason: reason, email: session.email);
    await AlarmService.cancelAlarm('dose_${log.scheduledAt}');
  }

  Future<void> correct(DoseLog log, String status) async {
    final session = ref.read(familySessionProvider);
    await ref.read(doseServiceProvider)
        .correctStatus(log.id, status, email: session.email);
    if (status == 'taken') await _checkLowStock(log.medicineId);
  }

  /// Beri notifikasi bila stok obat menipis setelah dosis dikonfirmasi (FR-07).
  Future<void> _checkLowStock(String medicineId) async {
    final med = await ref.read(databaseProvider).getMedicine(medicineId);
    if (med == null) return;
    if (med.stockQty <= med.lowStockThreshold) {
      await AlarmService.showNotification(
        id: medicineId.hashCode & 0x7fffffff,
        title: 'Stok obat menipis',
        body:
            '${med.name} tersisa ${formatQty(med.stockQty)} ${med.unit}. Segera tambah stok.',
      );
    }
  }
}

Future<int?> showSnoozeSheet(BuildContext context) {
  final p = context.palette;
  return showModalBottomSheet<int>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'Tunda Alarm',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
              ),
            ),
          ),
          ...AlarmRules.snoozeOptions.map((m) => ListTile(
                leading: Icon(Icons.snooze_rounded, color: p.warning),
                title: Text('$m menit'),
                onTap: () => Navigator.pop(ctx, m),
              )),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class DoseCard extends ConsumerWidget {
  final DoseLog log;
  final Medicine? medicine;
  final Member? member;
  final bool compact;

  const DoseCard({
    super.key,
    required this.log,
    this.medicine,
    this.member,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final actions = DoseActions(ref);
    final pending = log.status == 'pending' || log.status == 'snoozed';
    final med = medicine;
    final qty = med?.doseQty ?? 1;
    final dosage = '${formatQty(qty)} ${med?.unit ?? ''} • ${med?.dosage ?? ''}'
        .replaceAll(RegExp(r'\s*•\s*$'), '')
        .trim();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedicineAvatar(
                  thumbB64: med?.photoThumbB64,
                  filePath: med?.photoPath,
                  size: compact ? 48 : 58,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 17, color: p.primary),
                          const SizedBox(width: 5),
                          Text(
                            Dates.time(DateTime.fromMillisecondsSinceEpoch(
                                log.effectiveScheduledAt)),
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.3,
                              color: p.primary,
                            ),
                          ),
                          if (log.snoozeCount > 0) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.snooze_rounded,
                                size: 16, color: p.warning),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        med?.name ?? 'Obat',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: p.textPrimary,
                        ),
                      ),
                      if (dosage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            dosage,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: p.textSecondary,
                            ),
                          ),
                        ),
                      if (member != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline_rounded,
                                  size: 15, color: p.accent),
                              const SizedBox(width: 4),
                              Text(
                                'Untuk ${member!.name}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: p.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                StatusChip(log.status),
              ],
            ),
            if (pending) ...[
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => actions.taken(log),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Sudah Minum'),
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: p.onAccent,
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final m = await showSnoozeSheet(context);
                        if (m == null) return;
                        final ok = await actions.snooze(log, m);
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Batas tunda tercapai. Segera minum atau lewati.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.snooze_rounded, size: 20),
                      label: const Text('Tunda'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: p.warning,
                        side: BorderSide(
                            color: p.warning, width: p.highContrast ? 2 : 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final reason = await showSkipReasonSheet(context);
                        if (reason == null) return;
                        await actions.skip(log, reason);
                      },
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      label: const Text('Lewati'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: p.error,
                        side: BorderSide(
                            color: p.error, width: p.highContrast ? 2 : 1.5),
                      ),
                    ),
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
