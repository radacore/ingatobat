import 'package:drift/drift.dart';

import '../../core/utils/ids.dart';
import '../database/app_database.dart';

int _now() => DateTime.now().millisecondsSinceEpoch;

/// CRUD seluruh entitas inti. Setiap perubahan menulis `updatedAt`.
class AppRepository {
  final AppDatabase db;
  AppRepository(this.db);

  // ---------------------------------------------------------------- Anggota

  Future<String> createMember({
    required String name,
    String? notes,
    String? avatarPath,
    String? avatarThumbB64,
    String? familyId,
  }) async {
    final id = Ids.uuid();
    await db.into(db.members).insert(MembersCompanion.insert(
          id: id,
          name: name,
          notes: Value(notes),
          avatarPath: Value(avatarPath),
          avatarThumbB64: Value(avatarThumbB64),
          familyId: Value(familyId),
          createdAt: _now(),
          updatedAt: _now(),
        ));
    return id;
  }

  Future<void> updateMember(
    String id, {
    required String name,
    String? notes,
    String? avatarPath,
    String? avatarThumbB64,
  }) async {
    await (db.update(db.members)..where((t) => t.id.equals(id))).write(
      MembersCompanion(
        name: Value(name),
        notes: Value(notes),
        avatarPath: Value(avatarPath),
        avatarThumbB64: Value(avatarThumbB64),
        updatedAt: Value(_now()),
      ),
    );
  }

  /// Soft delete: arsipkan anggota + nonaktifkan semua jadwal aktif.
  Future<void> archiveMember(String id) async {
    await db.transaction(() async {
      await (db.update(db.schedules)..where((t) => t.memberId.equals(id)))
          .write(SchedulesCompanion(
        isActive: const Value(false),
        updatedAt: Value(_now()),
      ));
      await (db.update(db.members)..where((t) => t.id.equals(id))).write(
        MembersCompanion(
          isArchived: const Value(true),
          deletedAt: Value(_now()),
          updatedAt: Value(_now()),
        ),
      );
    });
  }

  Future<void> restoreMember(String id) async {
    await (db.update(db.members)..where((t) => t.id.equals(id))).write(
      MembersCompanion(
        isArchived: const Value(false),
        deletedAt: const Value(null),
        updatedAt: Value(_now()),
      ),
    );
  }

  // ------------------------------------------------------------------- Obat

  Future<String> createMedicine({
    required String memberId,
    required String name,
    required String dosage,
    required String unit,
    double doseQty = 1.0,
    String mealRelation = 'none',
    String? photoPath,
    String? photoThumbB64,
    double stockQty = 0,
    double lowStockThreshold = 3,
    String? notes,
    String? familyId,
  }) async {
    final id = Ids.uuid();
    await db.transaction(() async {
      await db.into(db.medicines).insert(MedicinesCompanion.insert(
            id: id,
            memberId: memberId,
            name: name,
            dosage: dosage,
            unit: unit,
            doseQty: Value(doseQty),
            mealRelation: Value(mealRelation),
            photoPath: Value(photoPath),
            photoThumbB64: Value(photoThumbB64),
            stockQty: Value(stockQty),
            lowStockThreshold: Value(lowStockThreshold),
            notes: Value(notes),
            familyId: Value(familyId),
            createdAt: _now(),
            updatedAt: _now(),
          ));
      if (stockQty > 0) {
        await db.into(db.stockLedgers).insert(StockLedgersCompanion.insert(
              id: Ids.uuid(),
              medicineId: id,
              delta: stockQty,
              balanceAfter: stockQty,
              reason: 'restock',
              familyId: Value(familyId),
              createdAt: _now(),
            ));
      }
    });
    return id;
  }

  Future<void> updateMedicine(
    String id, {
    required String name,
    required String dosage,
    required String unit,
    required double doseQty,
    required String mealRelation,
    required double lowStockThreshold,
    String? photoPath,
    String? photoThumbB64,
    String? notes,
  }) async {
    await (db.update(db.medicines)..where((t) => t.id.equals(id))).write(
      MedicinesCompanion(
        name: Value(name),
        dosage: Value(dosage),
        unit: Value(unit),
        doseQty: Value(doseQty),
        mealRelation: Value(mealRelation),
        lowStockThreshold: Value(lowStockThreshold),
        photoPath: Value(photoPath),
        photoThumbB64: Value(photoThumbB64),
        notes: Value(notes),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> archiveMedicine(String id) async {
    await db.transaction(() async {
      await (db.update(db.schedules)..where((t) => t.medicineId.equals(id)))
          .write(SchedulesCompanion(
        isActive: const Value(false),
        updatedAt: Value(_now()),
      ));
      await (db.update(db.medicines)..where((t) => t.id.equals(id))).write(
        MedicinesCompanion(
          isArchived: const Value(true),
          deletedAt: Value(_now()),
          updatedAt: Value(_now()),
        ),
      );
    });
  }

  /// Restock / penyesuaian stok manual + tulis ledger (FR-07).
  Future<void> adjustStock(
    String medicineId,
    double delta, {
    String reason = 'restock',
  }) async {
    await db.transaction(() async {
      final med = await db.getMedicine(medicineId);
      if (med == null) return;
      final newBalance =
          (med.stockQty + delta).clamp(0, double.infinity).toDouble();
      await db.into(db.stockLedgers).insert(StockLedgersCompanion.insert(
            id: Ids.uuid(),
            medicineId: medicineId,
            delta: delta,
            balanceAfter: newBalance,
            reason: reason,
            familyId: Value(med.familyId),
            createdAt: _now(),
          ));
      await (db.update(db.medicines)..where((t) => t.id.equals(medicineId)))
          .write(MedicinesCompanion(
        stockQty: Value(newBalance),
        updatedAt: Value(_now()),
      ));
    });
  }

  // ---------------------------------------------------------------- Jadwal

  Future<String> createSchedule({
    required String memberId,
    required String medicineId,
    required String recurrenceType,
    required List<String> times,
    int? intervalHours,
    List<int>? daysOfWeek,
    double? doseQty,
    String? mealRelation,
    bool ttsEnabled = true,
    required DateTime startDate,
    DateTime? endDate,
    String? familyId,
  }) async {
    final id = Ids.uuid();
    await db.into(db.schedules).insert(SchedulesCompanion.insert(
          id: id,
          memberId: memberId,
          medicineId: medicineId,
          recurrenceType: recurrenceType,
          timesJson: _encodeList(times),
          intervalHours: Value(intervalHours),
          daysOfWeek: Value(daysOfWeek == null ? null : _encodeList(
              daysOfWeek.map((e) => e.toString()).toList())),
          doseQty: Value(doseQty),
          mealRelation: Value(mealRelation),
          ttsEnabled: Value(ttsEnabled),
          startDate: startDate.millisecondsSinceEpoch,
          endDate: Value(endDate?.millisecondsSinceEpoch),
          familyId: Value(familyId),
          createdAt: _now(),
          updatedAt: _now(),
        ));
    return id;
  }

  Future<void> updateSchedule(
    String id, {
    required String recurrenceType,
    required List<String> times,
    int? intervalHours,
    List<int>? daysOfWeek,
    double? doseQty,
    String? mealRelation,
    required bool ttsEnabled,
    required DateTime startDate,
    DateTime? endDate,
    required bool isActive,
  }) async {
    await (db.update(db.schedules)..where((t) => t.id.equals(id))).write(
      SchedulesCompanion(
        recurrenceType: Value(recurrenceType),
        timesJson: Value(_encodeList(times)),
        intervalHours: Value(intervalHours),
        daysOfWeek: Value(daysOfWeek == null
            ? null
            : _encodeList(daysOfWeek.map((e) => e.toString()).toList())),
        doseQty: Value(doseQty),
        mealRelation: Value(mealRelation),
        ttsEnabled: Value(ttsEnabled),
        startDate: Value(startDate.millisecondsSinceEpoch),
        endDate: Value(endDate?.millisecondsSinceEpoch),
        isActive: Value(isActive),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> setScheduleActive(String id, bool active) async {
    await (db.update(db.schedules)..where((t) => t.id.equals(id))).write(
      SchedulesCompanion(isActive: Value(active), updatedAt: Value(_now())),
    );
  }

  Future<void> deleteSchedule(String id) async {
    await (db.delete(db.schedules)..where((t) => t.id.equals(id))).go();
  }

  // ------------------------------------------------------------ Kontrol RS

  Future<String> createControlVisit({
    required String memberId,
    required String hospital,
    String? doctor,
    required DateTime visitAt,
    String? notes,
    int? reminderH2At,
    int? reminderH1At,
    String? familyId,
  }) async {
    final id = Ids.uuid();
    await db.into(db.controlVisits).insert(ControlVisitsCompanion.insert(
          id: id,
          memberId: memberId,
          hospital: hospital,
          doctor: Value(doctor),
          visitAt: visitAt.millisecondsSinceEpoch,
          reminderH2At: Value(reminderH2At),
          reminderH1At: Value(reminderH1At),
          notes: Value(notes),
          familyId: Value(familyId),
          updatedAt: _now(),
        ));
    return id;
  }

  Future<void> updateControlVisit(
    String id, {
    required String hospital,
    String? doctor,
    required DateTime visitAt,
    String? notes,
    int? reminderH2At,
    int? reminderH1At,
    required String status,
  }) async {
    await (db.update(db.controlVisits)..where((t) => t.id.equals(id))).write(
      ControlVisitsCompanion(
        hospital: Value(hospital),
        doctor: Value(doctor),
        visitAt: Value(visitAt.millisecondsSinceEpoch),
        notes: Value(notes),
        reminderH2At: Value(reminderH2At),
        reminderH1At: Value(reminderH1At),
        status: Value(status),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> deleteControlVisit(String id) async {
    await (db.delete(db.controlVisits)..where((t) => t.id.equals(id))).go();
  }

  // ----------------------------------------------------------- Efek samping

  Future<String> createSideEffect({
    required String memberId,
    required String medicineId,
    required DateTime occurredAt,
    required String kind,
    String? customKind,
    required String severity,
    String? note,
    String? familyId,
  }) async {
    final id = Ids.uuid();
    await db.into(db.sideEffects).insert(SideEffectsCompanion.insert(
          id: id,
          memberId: memberId,
          medicineId: medicineId,
          occurredAt: occurredAt.millisecondsSinceEpoch,
          kind: kind,
          customKind: Value(customKind),
          severity: severity,
          note: Value(note),
          familyId: Value(familyId),
          updatedAt: _now(),
        ));
    return id;
  }

  Future<void> deleteSideEffect(String id) async {
    await (db.delete(db.sideEffects)..where((t) => t.id.equals(id))).go();
  }

  // ------------------------------------------------------------- Pengaturan

  Future<void> setAlarmMode(String memberId, String mode) async {
    await db.into(db.deviceMemberPrefs).insertOnConflictUpdate(
      DeviceMemberPrefsCompanion.insert(
        memberId: memberId,
        alarmMode: Value(mode),
        updatedAt: _now(),
      ),
    );
  }

  static String _encodeList(List<String> list) =>
      '[${list.map((e) => '"$e"').join(',')}]';
}
