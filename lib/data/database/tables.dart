import 'package:drift/drift.dart';

/// Tabel-tabel drift (SQLite) sesuai DATABASE.md.
/// UUID sebagai Primary Key agar aman dibuat offline & siap multi-device.

class FamilyGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get ownerEmail => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FamilyMemberAccesses extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get email => text()();
  TextColumn get role => text().withDefault(const Constant('member'))();
  TextColumn get status => text().withDefault(const Constant('invited'))();
  IntColumn get joinedAt => integer().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get email => text()();
  TextColumn get fcmToken => text().nullable()();
  TextColumn get platform => text().withDefault(const Constant('android'))();
  IntColumn get lastSeenAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class DeviceMemberPrefs extends Table {
  TextColumn get memberId => text()();
  TextColumn get alarmMode =>
      text().withDefault(const Constant('monitor_only'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {memberId};
}

class Members extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get avatarThumbB64 => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Medicines extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text()();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  RealColumn get doseQty => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text()();
  TextColumn get mealRelation => text().withDefault(const Constant('none'))();
  TextColumn get photoPath => text().nullable()();
  TextColumn get photoThumbB64 => text().nullable()();
  RealColumn get stockQty => real().withDefault(const Constant(0.0))();
  RealColumn get lowStockThreshold => real().withDefault(const Constant(3.0))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class StockLedgers extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get medicineId => text()();
  TextColumn get doseLogId => text().nullable()();
  RealColumn get delta => real()();
  RealColumn get balanceAfter => real()();
  TextColumn get reason => text()();
  IntColumn get createdAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Schedules extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text()();
  TextColumn get medicineId => text()();
  TextColumn get recurrenceType => text()();
  TextColumn get timesJson => text()();
  IntColumn get intervalHours => integer().nullable()();
  TextColumn get daysOfWeek => text().nullable()();
  RealColumn get doseQty => real().nullable()();
  TextColumn get mealRelation => text().nullable()();
  BoolColumn get ttsEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get startDate => integer()();
  IntColumn get endDate => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DoseLogs extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get scheduleId => text().nullable()();
  TextColumn get memberId => text()();
  TextColumn get medicineId => text()();
  IntColumn get scheduledAt => integer()();
  IntColumn get effectiveScheduledAt => integer()();
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  BoolColumn get stockApplied => boolean().withDefault(const Constant(false))();
  TextColumn get actionByEmail => text().nullable()();
  IntColumn get actionAt => integer().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {scheduleId, scheduledAt},
      ];
}

class ControlVisits extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text()();
  TextColumn get hospital => text()();
  TextColumn get doctor => text().nullable()();
  IntColumn get visitAt => integer()();
  IntColumn get reminderH2At => integer().nullable()();
  IntColumn get reminderH1At => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('upcoming'))();
  TextColumn get notes => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SideEffects extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text()();
  TextColumn get medicineId => text()();
  IntColumn get occurredAt => integer()();
  TextColumn get kind => text()();
  TextColumn get customKind => text().nullable()();
  TextColumn get severity => text()();
  TextColumn get note => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();
}
