import 'package:drift/drift.dart';

import '../../core/constants.dart';
import '../../core/utils/ids.dart';
import '../../data/database/app_database.dart';
import 'schedule_engine.dart';

int _now() => DateTime.now().millisecondsSinceEpoch;

/// Logika inti dosis: pembuatan log, aksi cepat, koreksi status, dan
/// penyesuaian stok berbasis ledger (FR-05, FR-06, FR-07, FR-12).
class DoseService {
  final AppDatabase db;
  DoseService(this.db);

  /// Takaran efektif: override jadwal bila ada, jika tidak pakai obat.
  Future<double> doseQtyFor(Schedule schedule, Medicine medicine) async {
    return schedule.doseQty ?? medicine.doseQty;
  }

  /// Pastikan setiap kejadian jadwal dalam rentang punya entri DOSE_LOG.
  /// Aman dipanggil berulang (idempotent via ID deterministik).
  Future<int> ensureDoseLogsForRange(DateTime from, DateTime to) async {
    final schedules = await db.getActiveSchedules();
    if (schedules.isEmpty) return 0;

    final occurrences = ScheduleEngine.expandRange(schedules, from, to);
    var created = 0;
    await db.batch((batch) {
      for (final o in occurrences) {
        final ms = o.scheduledAt.millisecondsSinceEpoch;
        batch.insert(
          db.doseLogs,
          DoseLogsCompanion.insert(
            id: Ids.doseLog(o.scheduleId, ms),
            scheduleId: Value(o.scheduleId),
            memberId: o.memberId,
            medicineId: o.medicineId,
            scheduledAt: ms,
            effectiveScheduledAt: ms,
            status: 'pending',
            updatedAt: _now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
        created++;
      }
    });
    return created;
  }

  Future<void> markTaken(
    String doseLogId, {
    String? email,
    String? note,
  }) async {
    await db.transaction(() async {
      final log = await db.getDoseLog(doseLogId);
      if (log == null || log.status == 'taken') return;
      await _applyStock(log, apply: true, email: email);
      await (db.update(db.doseLogs)..where((t) => t.id.equals(doseLogId))).write(
        DoseLogsCompanion(
          status: const Value('taken'),
          actionByEmail: Value(email),
          actionAt: Value(_now()),
          note: Value(note),
          updatedAt: Value(_now()),
        ),
      );
    });
  }

  Future<void> markSkipped(
    String doseLogId, {
    String? reason,
    String? email,
  }) async {
    await db.transaction(() async {
      final log = await db.getDoseLog(doseLogId);
      if (log == null) return;
      // Bila sebelumnya taken, kembalikan stok.
      if (log.stockApplied) await _applyStock(log, apply: false, email: email);
      await (db.update(db.doseLogs)..where((t) => t.id.equals(doseLogId))).write(
        DoseLogsCompanion(
          status: const Value('skipped'),
          actionByEmail: Value(email),
          actionAt: Value(_now()),
          note: Value(reason),
          updatedAt: Value(_now()),
        ),
      );
    });
  }

  /// Tunda dosis. Mengembalikan false bila batas snooze/absolut tercapai.
  Future<bool> snooze(String doseLogId, int minutes) async {
    return db.transaction(() async {
      final log = await db.getDoseLog(doseLogId);
      if (log == null) return false;
      if (log.snoozeCount >= AlarmRules.maxSnooze) return false;

      final now = DateTime.now();
      final absoluteDeadline = DateTime.fromMillisecondsSinceEpoch(log.scheduledAt)
          .add(const Duration(minutes: AlarmRules.absoluteLimitMinutes));
      var target = now.add(Duration(minutes: minutes));
      if (target.isAfter(absoluteDeadline)) target = absoluteDeadline;

      await (db.update(db.doseLogs)..where((t) => t.id.equals(doseLogId))).write(
        DoseLogsCompanion(
          status: const Value('snoozed'),
          snoozeCount: Value(log.snoozeCount + 1),
          effectiveScheduledAt: Value(target.millisecondsSinceEpoch),
          updatedAt: Value(_now()),
        ),
      );
      return true;
    });
  }

  Future<void> markMissed(String doseLogId) async {
    await db.transaction(() async {
      final log = await db.getDoseLog(doseLogId);
      if (log == null || log.status == 'taken' || log.status == 'skipped') return;
      await (db.update(db.doseLogs)..where((t) => t.id.equals(doseLogId))).write(
        DoseLogsCompanion(
          status: const Value('missed'),
          updatedAt: Value(_now()),
        ),
      );
    });
  }

  /// Koreksi status dari layar Riwayat (BS-03): menyesuaikan stok otomatis.
  Future<void> correctStatus(String doseLogId, String newStatus,
      {String? email}) async {
    await db.transaction(() async {
      final log = await db.getDoseLog(doseLogId);
      if (log == null) return;
      final wasTaken = log.status == 'taken';
      final willBeTaken = newStatus == 'taken';

      if (!wasTaken && willBeTaken) {
        await _applyStock(log, apply: true, email: email);
      } else if (wasTaken && !willBeTaken) {
        await _applyStock(log, apply: false, email: email);
      }
      await (db.update(db.doseLogs)..where((t) => t.id.equals(doseLogId))).write(
        DoseLogsCompanion(
          status: Value(newStatus),
          actionByEmail: Value(email ?? log.actionByEmail),
          actionAt: Value(_now()),
          updatedAt: Value(_now()),
        ),
      );
    });
  }

  /// Tandai dosis yang sudah lewat batas sebagai missed (dipanggil reconcile).
  Future<int> reconcileMissed() async {
    final now = DateTime.now();
    final pending = await db.getPendingDoseLogs();
    var count = 0;
    for (final log in pending) {
      final effective = DateTime.fromMillisecondsSinceEpoch(log.effectiveScheduledAt);
      final absolute = DateTime.fromMillisecondsSinceEpoch(log.scheduledAt)
          .add(const Duration(minutes: AlarmRules.absoluteLimitMinutes));
      final limit = effective.add(const Duration(minutes: AlarmRules.missedAfterMinutes));
      final deadline = limit.isBefore(absolute) ? limit : absolute;
      if (now.isAfter(deadline)) {
        await markMissed(log.id);
        count++;
      }
    }
    return count;
  }

  /// Terapkan / kembalikan pemotongan stok (idempotent via `stock_applied`).
  Future<void> _applyStock(
    DoseLog log, {
    required bool apply,
    String? email,
  }) async {
    if (apply && log.stockApplied) return;
    if (!apply && !log.stockApplied) return;

    final medicine = await db.getMedicine(log.medicineId);
    if (medicine == null) return;
    final schedule = log.scheduleId == null
        ? null
        : await db.getSchedule(log.scheduleId!);
    final qty = schedule?.doseQty ?? medicine.doseQty;

    final delta = apply ? -qty : qty;
    final newBalance =
        (medicine.stockQty + delta).clamp(0, double.infinity).toDouble();

    await db.into(db.stockLedgers).insert(StockLedgersCompanion.insert(
          id: Ids.uuid(),
          medicineId: medicine.id,
          doseLogId: Value(log.id),
          delta: delta,
          balanceAfter: newBalance,
          reason: apply ? 'taken' : 'correction',
          familyId: Value(medicine.familyId),
          createdAt: _now(),
        ));

    await (db.update(db.medicines)..where((t) => t.id.equals(medicine.id)))
        .write(MedicinesCompanion(
      stockQty: Value(newBalance),
      updatedAt: Value(_now()),
    ));

    await (db.update(db.doseLogs)..where((t) => t.id.equals(log.id))).write(
      DoseLogsCompanion(stockApplied: Value(apply)),
    );
  }
}
