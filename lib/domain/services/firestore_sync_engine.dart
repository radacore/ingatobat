import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';
import 'merge_policy.dart';

int _now() => DateTime.now().millisecondsSinceEpoch;

int _tsMs(dynamic v) {
  if (v == null) return 0;
  if (v is Timestamp) return v.millisecondsSinceEpoch;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return 0;
}

int? _asInt(dynamic v) => v == null ? null : _tsMs(v);
double _asDouble(dynamic v) => v is num ? v.toDouble() : 0.0;
double? _asDoubleN(dynamic v) => v is num ? v.toDouble() : null;
String? _asStr(dynamic v) => v as String?;
bool _asBool(dynamic v) => v == true;

/// Mesin sinkronisasi Delta + Merge Policy ke Cloud Firestore (FR-18).
///
/// - **Delta hemat kuota Spark:** hanya dokumen dengan `server_updated_at >
///   last_sync_at` yang ditarik.
/// - **Bootstrap hemat kuota:** data referensi ditarik penuh, `DOSE_LOG` hanya
///   **90 hari terakhir**.
/// - **Merge Policy:** `server_updated_at` sebagai arbiter; status `dose_log`
///   memakai presedensi terminal (`taken` > `skipped` > `missed`).
class FirestoreSyncEngine {
  FirestoreSyncEngine(this.db);

  final AppDatabase db;

  static const int bootstrapDays = 90;

  FirebaseFirestore get _fs => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String familyId, String name) =>
      _fs.collection('family_groups').doc(familyId).collection(name);

  bool _dirty(int? serverUpdatedAt, int updatedAt) =>
      serverUpdatedAt == null || updatedAt > serverUpdatedAt;

  // ------------------------------------------------------------------ PUSH

  /// Mengunggah seluruh baris lokal yang belum tersinkron (dirty) ke Firestore.
  Future<int> pushAll(String familyId) async {
    var count = 0;
    final batch = <Future<void>>[];

    for (final r in await db.select(db.members).get()) {
      if (!_dirty(r.serverUpdatedAt, r.updatedAt)) continue;
      batch.add(_col(familyId, 'members').doc(r.id).set(_memberMap(r)));
      count++;
    }
    for (final r in await db.select(db.medicines).get()) {
      if (!_dirty(r.serverUpdatedAt, r.updatedAt)) continue;
      batch.add(_col(familyId, 'medicines').doc(r.id).set(_medicineMap(r)));
      count++;
    }
    for (final r in await db.select(db.schedules).get()) {
      if (!_dirty(r.serverUpdatedAt, r.updatedAt)) continue;
      batch.add(_col(familyId, 'schedules').doc(r.id).set(_scheduleMap(r)));
      count++;
    }
    for (final r in await db.select(db.doseLogs).get()) {
      if (!_dirty(r.serverUpdatedAt, r.updatedAt)) continue;
      batch.add(_col(familyId, 'dose_logs').doc(r.id).set(_doseLogMap(r)));
      count++;
    }
    for (final r in await db.select(db.stockLedgers).get()) {
      if (!_dirty(r.serverUpdatedAt, r.createdAt)) continue;
      batch.add(_col(familyId, 'stock_ledger').doc(r.id).set(_ledgerMap(r)));
      count++;
    }
    for (final r in await db.select(db.controlVisits).get()) {
      if (!_dirty(r.serverUpdatedAt, r.updatedAt)) continue;
      batch.add(_col(familyId, 'control_visits').doc(r.id).set(_visitMap(r)));
      count++;
    }
    for (final r in await db.select(db.sideEffects).get()) {
      if (!_dirty(r.serverUpdatedAt, r.updatedAt)) continue;
      batch.add(_col(familyId, 'side_effects').doc(r.id).set(_effectMap(r)));
      count++;
    }

    await Future.wait(batch);
    await _markPushed();
    return count;
  }

  /// Menandai baris lokal yang sudah diunggah sebagai tidak-dirty lagi.
  Future<void> _markPushed() async {
    await db.transaction(() async {
      await db.customStatement(
        'UPDATE members SET server_updated_at = updated_at '
        'WHERE server_updated_at IS NULL OR updated_at > server_updated_at',
      );
      await db.customStatement(
        'UPDATE medicines SET server_updated_at = updated_at '
        'WHERE server_updated_at IS NULL OR updated_at > server_updated_at',
      );
      await db.customStatement(
        'UPDATE schedules SET server_updated_at = updated_at '
        'WHERE server_updated_at IS NULL OR updated_at > server_updated_at',
      );
      await db.customStatement(
        'UPDATE dose_logs SET server_updated_at = updated_at '
        'WHERE server_updated_at IS NULL OR updated_at > server_updated_at',
      );
      await db.customStatement(
        'UPDATE stock_ledger SET server_updated_at = created_at '
        'WHERE server_updated_at IS NULL OR created_at > server_updated_at',
      );
      await db.customStatement(
        'UPDATE control_visits SET server_updated_at = updated_at '
        'WHERE server_updated_at IS NULL OR updated_at > server_updated_at',
      );
      await db.customStatement(
        'UPDATE side_effects SET server_updated_at = updated_at '
        'WHERE server_updated_at IS NULL OR updated_at > server_updated_at',
      );
    });
  }

  // ------------------------------------------------------------------ PULL

  /// Menarik perubahan server sejak [sinceMs] dan menggabungkannya (Merge Policy).
  Future<int> pullDelta(String familyId, int sinceMs) async {
    final since = Timestamp.fromMillisecondsSinceEpoch(sinceMs);
    var count = 0;

    Future<void> pull(String collection, Future<void> Function(Map<String, dynamic>) merge) async {
      final snap = await _col(familyId, collection)
          .where('server_updated_at', isGreaterThan: since)
          .get();
      for (final doc in snap.docs) {
        await merge(doc.data());
        count++;
      }
    }

    await pull('members', _mergeMember);
    await pull('medicines', _mergeMedicine);
    await pull('schedules', _mergeSchedule);
    await pull('dose_logs', _mergeDoseLog);
    await pull('stock_ledger', _mergeLedger);
    await pull('control_visits', _mergeVisit);
    await pull('side_effects', _mergeEffect);
    return count;
  }

  /// Bootstrap saat perangkat baru bergabung: referensi penuh + dose_log 90 hari.
  Future<void> bootstrap(String familyId) async {
    final sinceMs = _now() - bootstrapDays * 24 * 60 * 60 * 1000;

    Future<void> full(String collection, Future<void> Function(Map<String, dynamic>) merge) async {
      final snap = await _col(familyId, collection).get();
      for (final doc in snap.docs) {
        await merge(doc.data());
      }
    }

    await full('members', _mergeMember);
    await full('medicines', _mergeMedicine);
    await full('schedules', _mergeSchedule);
    await full('control_visits', _mergeVisit);
    await full('side_effects', _mergeEffect);

    final logs = await _col(familyId, 'dose_logs')
        .where('scheduled_at', isGreaterThan: sinceMs)
        .get();
    for (final doc in logs.docs) {
      await _mergeDoseLog(doc.data());
    }

    // Kirim data lokal HP ini agar perangkat lain menerimanya.
    await pushAll(familyId);
  }

  // --------------------------------------------------------------- REALTIME

  /// Listener realtime pada satu `dose_log` (dipasang saat alarm berbunyi).
  ///
  /// [onTerminal] dipanggil saat perangkat lain mengubah status menjadi terminal
  /// (`taken`/`skipped`) sehingga alarm di HP ini bisa dihentikan real-time.
  StreamSubscriptionHandle watchDoseLog(
    String familyId,
    String doseLogId, {
    void Function(String status)? onTerminal,
  }) {
    final sub = _col(familyId, 'dose_logs').doc(doseLogId).snapshots().listen(
          (snap) async {
            final data = snap.data();
            if (data == null) return;
            final status = data['status'] as String? ?? '';
            await _mergeDoseLog(data);
            if (status == 'taken' || status == 'skipped') {
              onTerminal?.call(status);
            }
          },
          onError: (_) {},
        );
    return StreamSubscriptionHandle(sub);
  }

  // --------------------------------------------------------------- MAPPINGS

  Map<String, dynamic> _memberMap(Member r) => {
        'id': r.id,
        'family_id': r.familyId,
        'name': r.name,
        'avatar_path': r.avatarPath,
        'avatar_thumb_b64': r.avatarThumbB64,
        'notes': r.notes,
        'is_archived': r.isArchived,
        'deleted_at': r.deletedAt,
        'created_at': r.createdAt,
        'updated_at': r.updatedAt,
        'server_updated_at': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> _medicineMap(Medicine r) => {
        'id': r.id,
        'family_id': r.familyId,
        'member_id': r.memberId,
        'name': r.name,
        'dosage': r.dosage,
        'dose_qty': r.doseQty,
        'unit': r.unit,
        'meal_relation': r.mealRelation,
        'photo_path': r.photoPath,
        'photo_thumb_b64': r.photoThumbB64,
        'stock_qty': r.stockQty,
        'low_stock_threshold': r.lowStockThreshold,
        'notes': r.notes,
        'is_archived': r.isArchived,
        'deleted_at': r.deletedAt,
        'created_at': r.createdAt,
        'updated_at': r.updatedAt,
        'server_updated_at': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> _scheduleMap(Schedule r) => {
        'id': r.id,
        'family_id': r.familyId,
        'member_id': r.memberId,
        'medicine_id': r.medicineId,
        'recurrence_type': r.recurrenceType,
        'times_json': r.timesJson,
        'interval_hours': r.intervalHours,
        'days_of_week': r.daysOfWeek,
        'dose_qty': r.doseQty,
        'meal_relation': r.mealRelation,
        'tts_enabled': r.ttsEnabled,
        'start_date': r.startDate,
        'end_date': r.endDate,
        'is_active': r.isActive,
        'created_at': r.createdAt,
        'updated_at': r.updatedAt,
        'server_updated_at': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> _doseLogMap(DoseLog r) => {
        'id': r.id,
        'family_id': r.familyId,
        'schedule_id': r.scheduleId,
        'member_id': r.memberId,
        'medicine_id': r.medicineId,
        'scheduled_at': r.scheduledAt,
        'effective_scheduled_at': r.effectiveScheduledAt,
        'snooze_count': r.snoozeCount,
        'status': r.status,
        'stock_applied': r.stockApplied,
        'action_by_email': r.actionByEmail,
        'action_at': r.actionAt,
        'note': r.note,
        'updated_at': r.updatedAt,
        'server_updated_at': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> _ledgerMap(StockLedger r) => {
        'id': r.id,
        'family_id': r.familyId,
        'medicine_id': r.medicineId,
        'dose_log_id': r.doseLogId,
        'delta': r.delta,
        'balance_after': r.balanceAfter,
        'reason': r.reason,
        'created_at': r.createdAt,
        'server_updated_at': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> _visitMap(ControlVisit r) => {
        'id': r.id,
        'family_id': r.familyId,
        'member_id': r.memberId,
        'hospital': r.hospital,
        'doctor': r.doctor,
        'visit_at': r.visitAt,
        'reminder_h2_at': r.reminderH2At,
        'reminder_h1_at': r.reminderH1At,
        'status': r.status,
        'notes': r.notes,
        'updated_at': r.updatedAt,
        'server_updated_at': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> _effectMap(SideEffect r) => {
        'id': r.id,
        'family_id': r.familyId,
        'member_id': r.memberId,
        'medicine_id': r.medicineId,
        'occurred_at': r.occurredAt,
        'kind': r.kind,
        'custom_kind': r.customKind,
        'severity': r.severity,
        'note': r.note,
        'updated_at': r.updatedAt,
        'server_updated_at': FieldValue.serverTimestamp(),
      };

  // ------------------------------------------------------------ MERGE (LWW)

  Future<void> _mergeMember(Map<String, dynamic> d) async {
    final id = d['id'] as String;
    if (!await _incomingWins(db.members, id, _tsMs(d['server_updated_at']))) {
      return;
    }
    final deletedAt = await _mergedDeletedAt('members', id, _asInt(d['deleted_at']));
    await db.into(db.members).insertOnConflictUpdate(MembersCompanion(
          id: Value(id),
          familyId: Value(_asStr(d['family_id'])),
          name: Value(d['name'] as String? ?? ''),
          avatarPath: Value(_asStr(d['avatar_path'])),
          avatarThumbB64: Value(_asStr(d['avatar_thumb_b64'])),
          notes: Value(_asStr(d['notes'])),
          isArchived: Value(_asBool(d['is_archived'])),
          deletedAt: Value(deletedAt),
          createdAt: Value(_asInt(d['created_at']) ?? 0),
          updatedAt: Value(_asInt(d['updated_at']) ?? 0),
          serverUpdatedAt: Value(_tsMs(d['server_updated_at'])),
        ));
  }

  Future<void> _mergeMedicine(Map<String, dynamic> d) async {
    final id = d['id'] as String;
    if (!await _incomingWins(db.medicines, id, _tsMs(d['server_updated_at']))) {
      return;
    }
    final deletedAt =
        await _mergedDeletedAt('medicines', id, _asInt(d['deleted_at']));
    await db.into(db.medicines).insertOnConflictUpdate(MedicinesCompanion(
          id: Value(id),
          familyId: Value(_asStr(d['family_id'])),
          memberId: Value(d['member_id'] as String? ?? ''),
          name: Value(d['name'] as String? ?? ''),
          dosage: Value(d['dosage'] as String? ?? ''),
          doseQty: Value(_asDouble(d['dose_qty'])),
          unit: Value(d['unit'] as String? ?? ''),
          mealRelation: Value(d['meal_relation'] as String? ?? 'none'),
          photoPath: Value(_asStr(d['photo_path'])),
          photoThumbB64: Value(_asStr(d['photo_thumb_b64'])),
          stockQty: Value(_asDouble(d['stock_qty'])),
          lowStockThreshold: Value(_asDouble(d['low_stock_threshold'])),
          notes: Value(_asStr(d['notes'])),
          isArchived: Value(_asBool(d['is_archived'])),
          deletedAt: Value(deletedAt),
          createdAt: Value(_asInt(d['created_at']) ?? 0),
          updatedAt: Value(_asInt(d['updated_at']) ?? 0),
          serverUpdatedAt: Value(_tsMs(d['server_updated_at'])),
        ));
  }

  Future<void> _mergeSchedule(Map<String, dynamic> d) async {
    final id = d['id'] as String;
    if (!await _incomingWins(db.schedules, id, _tsMs(d['server_updated_at']))) {
      return;
    }
    await db.into(db.schedules).insertOnConflictUpdate(SchedulesCompanion(
          id: Value(id),
          familyId: Value(_asStr(d['family_id'])),
          memberId: Value(d['member_id'] as String? ?? ''),
          medicineId: Value(d['medicine_id'] as String? ?? ''),
          recurrenceType: Value(d['recurrence_type'] as String? ?? 'daily'),
          timesJson: Value(d['times_json'] as String? ?? '[]'),
          intervalHours: Value(_asInt(d['interval_hours'])),
          daysOfWeek: Value(_asStr(d['days_of_week'])),
          doseQty: Value(_asDoubleN(d['dose_qty'])),
          mealRelation: Value(_asStr(d['meal_relation'])),
          ttsEnabled: Value(_asBool(d['tts_enabled'])),
          startDate: Value(_asInt(d['start_date']) ?? 0),
          endDate: Value(_asInt(d['end_date'])),
          isActive: Value(_asBool(d['is_active'])),
          createdAt: Value(_asInt(d['created_at']) ?? 0),
          updatedAt: Value(_asInt(d['updated_at']) ?? 0),
          serverUpdatedAt: Value(_tsMs(d['server_updated_at'])),
        ));
  }

  /// Status terminal menang atas status non-terminal, apa pun urutan waktunya.
  Future<void> _mergeDoseLog(Map<String, dynamic> d) async {
    final id = d['id'] as String;
    final incomingMs = _tsMs(d['server_updated_at']);
    final incomingStatus = d['status'] as String? ?? 'pending';
    final incomingEffective = _asInt(d['effective_scheduled_at']) ?? 0;
    final incomingSnooze = _asInt(d['snooze_count']) ?? 0;

    var effective = incomingEffective;
    var snooze = incomingSnooze;

    final existing = await (db.select(db.doseLogs)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (existing != null) {
      if (!doseLogIncomingWins(
        localStatus: existing.status,
        localServerMs: existing.serverUpdatedAt ?? 0,
        incomingStatus: incomingStatus,
        incomingServerMs: incomingMs,
      )) {
        return;
      }
      snooze = mergeSnoozeCount(existing.snoozeCount, incomingSnooze);
      effective = mergeEffectiveScheduledAt(
        existing.effectiveScheduledAt,
        incomingEffective,
      );
    }

    await db.into(db.doseLogs).insertOnConflictUpdate(DoseLogsCompanion(
          id: Value(id),
          familyId: Value(_asStr(d['family_id'])),
          scheduleId: Value(_asStr(d['schedule_id'])),
          memberId: Value(d['member_id'] as String? ?? ''),
          medicineId: Value(d['medicine_id'] as String? ?? ''),
          scheduledAt: Value(_asInt(d['scheduled_at']) ?? 0),
          effectiveScheduledAt: Value(effective),
          snoozeCount: Value(snooze),
          status: Value(incomingStatus),
          stockApplied: Value(_asBool(d['stock_applied'])),
          actionByEmail: Value(_asStr(d['action_by_email'])),
          actionAt: Value(_asInt(d['action_at'])),
          note: Value(_asStr(d['note'])),
          updatedAt: Value(_asInt(d['updated_at']) ?? 0),
          serverUpdatedAt: Value(incomingMs),
        ));
  }

  Future<void> _mergeLedger(Map<String, dynamic> d) async {
    final id = d['id'] as String;
    if (!await _incomingWins(db.stockLedgers, id, _tsMs(d['server_updated_at']))) {
      return;
    }
    await db.into(db.stockLedgers).insertOnConflictUpdate(StockLedgersCompanion(
          id: Value(id),
          familyId: Value(_asStr(d['family_id'])),
          medicineId: Value(d['medicine_id'] as String? ?? ''),
          doseLogId: Value(_asStr(d['dose_log_id'])),
          delta: Value(_asDouble(d['delta'])),
          balanceAfter: Value(_asDouble(d['balance_after'])),
          reason: Value(d['reason'] as String? ?? ''),
          createdAt: Value(_asInt(d['created_at']) ?? 0),
          serverUpdatedAt: Value(_tsMs(d['server_updated_at'])),
        ));
  }

  Future<void> _mergeVisit(Map<String, dynamic> d) async {
    final id = d['id'] as String;
    if (!await _incomingWins(db.controlVisits, id, _tsMs(d['server_updated_at']))) {
      return;
    }
    await db.into(db.controlVisits).insertOnConflictUpdate(ControlVisitsCompanion(
          id: Value(id),
          familyId: Value(_asStr(d['family_id'])),
          memberId: Value(d['member_id'] as String? ?? ''),
          hospital: Value(d['hospital'] as String? ?? ''),
          doctor: Value(_asStr(d['doctor'])),
          visitAt: Value(_asInt(d['visit_at']) ?? 0),
          reminderH2At: Value(_asInt(d['reminder_h2_at'])),
          reminderH1At: Value(_asInt(d['reminder_h1_at'])),
          status: Value(d['status'] as String? ?? 'upcoming'),
          notes: Value(_asStr(d['notes'])),
          updatedAt: Value(_asInt(d['updated_at']) ?? 0),
          serverUpdatedAt: Value(_tsMs(d['server_updated_at'])),
        ));
  }

  Future<void> _mergeEffect(Map<String, dynamic> d) async {
    final id = d['id'] as String;
    if (!await _incomingWins(db.sideEffects, id, _tsMs(d['server_updated_at']))) {
      return;
    }
    await db.into(db.sideEffects).insertOnConflictUpdate(SideEffectsCompanion(
          id: Value(id),
          familyId: Value(_asStr(d['family_id'])),
          memberId: Value(d['member_id'] as String? ?? ''),
          medicineId: Value(d['medicine_id'] as String? ?? ''),
          occurredAt: Value(_asInt(d['occurred_at']) ?? 0),
          kind: Value(d['kind'] as String? ?? 'other'),
          customKind: Value(_asStr(d['custom_kind'])),
          severity: Value(d['severity'] as String? ?? 'ringan'),
          note: Value(_asStr(d['note'])),
          updatedAt: Value(_asInt(d['updated_at']) ?? 0),
          serverUpdatedAt: Value(_tsMs(d['server_updated_at'])),
        ));
  }

  /// Mengembalikan `true` bila dokumen masuk lebih baru (LWW `server_updated_at`).
  Future<bool> _incomingWins(TableInfo table, String id, int incomingMs) async {
    final row = await db.customSelect(
      'SELECT server_updated_at AS s FROM ${table.actualTableName} WHERE id = ?',
      variables: [Variable.withString(id)],
    ).getSingleOrNull();
    if (row == null) return true;
    final localMs = row.read<int?>('s') ?? 0;
    return lwwIncomingWins(localMs, incomingMs);
  }

  /// Soft-delete monoton: `deleted_at` yang sudah ada tidak boleh kembali `null`.
  Future<int?> _mergedDeletedAt(String table, String id, int? incoming) async {
    final row = await db.customSelect(
      'SELECT deleted_at AS d FROM $table WHERE id = ?',
      variables: [Variable.withString(id)],
    ).getSingleOrNull();
    return mergeDeletedAt(row?.read<int?>('d'), incoming);
  }
}

/// Pembungkus langganan realtime agar bisa dihentikan pemanggil.
class StreamSubscriptionHandle {
  StreamSubscriptionHandle(this._sub);
  final dynamic _sub;
  Future<void> cancel() async => _sub.cancel();
}
