import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    FamilyGroups,
    FamilyMemberAccesses,
    Devices,
    DeviceMemberPrefs,
    Members,
    Medicines,
    StockLedgers,
    Schedules,
    DoseLogs,
    ControlVisits,
    SideEffects,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ---------------------------------------------------------------------------
  // Anggota
  // ---------------------------------------------------------------------------

  Stream<List<Member>> watchActiveMembers() {
    return (select(members)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch();
  }

  Future<List<Member>> getActiveMembers() {
    return (select(members)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
  }

  Future<Member?> getMember(String id) {
    return (select(members)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // Obat
  // ---------------------------------------------------------------------------

  Stream<List<Medicine>> watchMedicinesOfMember(String memberId) {
    return (select(medicines)
          ..where((t) => t.memberId.equals(memberId) & t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<List<Medicine>> getMedicinesOfMember(String memberId) {
    return (select(medicines)
          ..where((t) => t.memberId.equals(memberId) & t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Future<Medicine?> getMedicine(String id) {
    return (select(medicines)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Medicine>> getLowStockMedicines() {
    return (select(medicines)
          ..where((t) =>
              t.isArchived.equals(false) &
              t.stockQty.isSmallerOrEqual(t.lowStockThreshold))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Stream<List<Medicine>> watchLowStockMedicines() {
    return (select(medicines)
          ..where((t) =>
              t.isArchived.equals(false) &
              t.stockQty.isSmallerOrEqual(t.lowStockThreshold))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  // ---------------------------------------------------------------------------
  // Jadwal
  // ---------------------------------------------------------------------------

  Stream<List<Schedule>> watchSchedulesOfMember(String memberId) {
    return (select(schedules)
          ..where((t) => t.memberId.equals(memberId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch();
  }

  Future<List<Schedule>> getActiveSchedules() {
    return (select(schedules)..where((t) => t.isActive.equals(true))).get();
  }

  Future<List<Schedule>> getSchedulesOfMedicine(String medicineId) {
    return (select(schedules)
          ..where((t) => t.medicineId.equals(medicineId) & t.isActive.equals(true)))
        .get();
  }

  Future<Schedule?> getSchedule(String id) {
    return (select(schedules)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // Log dosis
  // ---------------------------------------------------------------------------

  Future<DoseLog?> getDoseLog(String id) {
    return (select(doseLogs)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<DoseLog>> getDoseLogsByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value(const []);
    return (select(doseLogs)..where((t) => t.id.isIn(ids))).get();
  }

  Future<DoseLog?> findDoseLogByScheduleAndTime(
      String scheduleId, int scheduledAt) {
    return (select(doseLogs)
          ..where((t) =>
              t.scheduleId.equals(scheduleId) & t.scheduledAt.equals(scheduledAt)))
        .getSingleOrNull();
  }

  Stream<List<DoseLog>> watchDoseLogsBetween(int fromMs, int toMs) {
    return (select(doseLogs)
          ..where((t) => t.scheduledAt.isBiggerOrEqualValue(fromMs) &
              t.scheduledAt.isSmallerThanValue(toMs))
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledAt)]))
        .watch();
  }

  Future<List<DoseLog>> getPendingDoseLogs() {
    return (select(doseLogs)
          ..where((t) => t.status.isIn(const ['pending', 'snoozed']))
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledAt)]))
        .get();
  }

  /// Riwayat dengan filter opsional.
  Stream<List<DoseLog>> watchHistory({
    String? memberId,
    String? medicineId,
    String? status,
    int? fromMs,
    int? toMs,
  }) {
    final q = select(doseLogs);
    if (memberId != null) q.where((t) => t.memberId.equals(memberId));
    if (medicineId != null) q.where((t) => t.medicineId.equals(medicineId));
    if (status != null) q.where((t) => t.status.equals(status));
    if (fromMs != null) {
      q.where((t) => t.scheduledAt.isBiggerOrEqualValue(fromMs));
    }
    if (toMs != null) {
      q.where((t) => t.scheduledAt.isSmallerThanValue(toMs));
    }
    q.orderBy([(t) => OrderingTerm(expression: t.scheduledAt, mode: OrderingMode.desc)]);
    return q.watch();
  }

  // ---------------------------------------------------------------------------
  // Ledger stok
  // ---------------------------------------------------------------------------

  Stream<List<StockLedger>> watchLedgerOfMedicine(String medicineId) {
    return (select(stockLedgers)
          ..where((t) => t.medicineId.equals(medicineId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // ---------------------------------------------------------------------------
  // Kontrol RS
  // ---------------------------------------------------------------------------

  Stream<List<ControlVisit>> watchControlVisitsOfMember(String memberId) {
    return (select(controlVisits)
          ..where((t) => t.memberId.equals(memberId))
          ..orderBy([(t) => OrderingTerm(expression: t.visitAt)]))
        .watch();
  }

  Future<List<ControlVisit>> getUpcomingControlVisits() {
    return (select(controlVisits)
          ..where((t) => t.status.equals('upcoming'))
          ..orderBy([(t) => OrderingTerm(expression: t.visitAt)]))
        .get();
  }

  Future<ControlVisit?> getControlVisit(String id) {
    return (select(controlVisits)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // Efek samping
  // ---------------------------------------------------------------------------

  Stream<List<SideEffect>> watchSideEffectsOfMedicine(String medicineId) {
    return (select(sideEffects)
          ..where((t) => t.medicineId.equals(medicineId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Stream<List<SideEffect>> watchSideEffectsOfMember(String memberId) {
    return (select(sideEffects)
          ..where((t) => t.memberId.equals(memberId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // ---------------------------------------------------------------------------
  // Pengaturan
  // ---------------------------------------------------------------------------

  Future<String?> getSetting(String key) async {
    final row = await (select(settings)..where((t) => t.settingKey.equals(key)))
        .getSingleOrNull();
    return row?.settingValue;
  }

  Stream<String?> watchSetting(String key) {
    return (select(settings)..where((t) => t.settingKey.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.settingValue);
  }

  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(settingKey: key, settingValue: value),
    );
  }

  // ---------------------------------------------------------------------------
  // Preferensi alarm per perangkat
  // ---------------------------------------------------------------------------

  Future<String> alarmModeFor(String memberId) async {
    final row = await (select(deviceMemberPrefs)
          ..where((t) => t.memberId.equals(memberId)))
        .getSingleOrNull();
    return row?.alarmMode ?? 'monitor_only';
  }

  Stream<Map<String, String>> watchAlarmModes() {
    return select(deviceMemberPrefs).watch().map(
          (rows) => {for (final r in rows) r.memberId: r.alarmMode},
        );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ingatobat.sqlite'));

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
