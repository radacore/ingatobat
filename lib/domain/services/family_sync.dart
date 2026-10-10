import 'package:drift/drift.dart';

import '../../core/constants.dart';
import '../../core/utils/ids.dart';
import '../../data/database/app_database.dart';

int _now() => DateTime.now().millisecondsSinceEpoch;

/// Status sinkronisasi keluarga yang ditampilkan di UI.
enum SyncStatus { offline, syncing, synced, error }

class FamilyAccess {
  final String email;
  final String role;
  final String status;
  const FamilyAccess(this.email, this.role, this.status);
}

/// Lapisan sinkronisasi keluarga (FR-18).
///
/// Implementasi default berjalan penuh secara **offline lokal** (Zero-Bill):
/// grup keluarga, undangan email, dan data keluarga tetap tersimpan di SQLite.
/// Saat Firebase dikonfigurasi (google-services.json), implementasi Firestore
/// menggantikan operasi cloud tanpa mengubah UI.
abstract class FamilySyncService {
  Future<void> signInWithGoogle();
  Future<void> inviteEmail(String email);
  Future<void> revokeEmail(String email);
  Future<void> leaveFamily();
  Future<void> deleteAccountAndCloud();
  Future<List<FamilyAccess>> listAccess();
  Future<SyncStatus> syncNow();
}

class LocalFamilySyncService implements FamilySyncService {
  final AppDatabase db;
  LocalFamilySyncService(this.db);

  @override
  Future<void> signInWithGoogle() async {
    final email = await db.getSetting(SettingKeys.currentUserEmail);
    if (email != null && email.isNotEmpty) return;

    // Simulasi akun Google (offline-first, tanpa kartu kredit).
    final pseudoEmail = 'keluarga@ingatobat.local';
    final familyId = Ids.uuid();
    await db.setSetting(SettingKeys.currentUserEmail, pseudoEmail);
    await db.setSetting(SettingKeys.currentFamilyId, familyId);
    await db.setSetting(SettingKeys.familyName, 'Keluarga Saya');
    await db.setSetting(SettingKeys.currentUserRole, 'admin');
    await db.setSetting(SettingKeys.lastSyncAt, _now().toString());

    await db.into(db.familyGroups).insertOnConflictUpdate(
      FamilyGroupsCompanion.insert(
        id: familyId,
        name: 'Keluarga Saya',
        ownerEmail: pseudoEmail,
        createdAt: _now(),
        updatedAt: _now(),
      ),
    );
    await db.into(db.familyMemberAccesses).insertOnConflictUpdate(
      FamilyMemberAccessesCompanion.insert(
        id: Ids.uuid(),
        familyId: Value(familyId),
        email: pseudoEmail,
        role: const Value('admin'),
        status: const Value('joined'),
        joinedAt: Value(_now()),
        updatedAt: _now(),
      ),
    );
  }

  @override
  Future<void> inviteEmail(String email) async {
    final familyId = await db.getSetting(SettingKeys.currentFamilyId);
    if (familyId == null || familyId.isEmpty) {
      throw StateError('Belum tergabung ke grup keluarga.');
    }
    final lower = email.trim().toLowerCase();
    await db.into(db.familyMemberAccesses).insertOnConflictUpdate(
      FamilyMemberAccessesCompanion.insert(
        id: '$familyId:$lower',
        familyId: Value(familyId),
        email: lower,
        status: const Value('invited'),
        updatedAt: _now(),
      ),
    );
  }

  @override
  Future<void> revokeEmail(String email) async {
    await (db.delete(db.familyMemberAccesses)
          ..where((t) => t.email.equals(email.toLowerCase())))
        .go();
  }

  @override
  Future<void> leaveFamily() async {
    await db.setSetting(SettingKeys.currentFamilyId, '');
    await db.setSetting(SettingKeys.currentUserRole, '');
    await db.setSetting(SettingKeys.familyName, '');
    // Data lokal tetap dipertahankan (FR-18).
  }

  @override
  Future<void> deleteAccountAndCloud() async {
    await db.transaction(() async {
      await db.delete(db.doseLogs).go();
      await db.delete(db.stockLedgers).go();
      await db.delete(db.schedules).go();
      await db.delete(db.sideEffects).go();
      await db.delete(db.controlVisits).go();
      await db.delete(db.medicines).go();
      await db.delete(db.members).go();
      await db.delete(db.familyMemberAccesses).go();
      await db.delete(db.deviceMemberPrefs).go();
      await db.delete(db.devices).go();
      await db.delete(db.familyGroups).go();
    });
    for (final k in [
      SettingKeys.currentUserEmail,
      SettingKeys.currentFamilyId,
      SettingKeys.familyName,
      SettingKeys.currentUserRole,
      SettingKeys.lastSyncAt,
    ]) {
      await db.setSetting(k, '');
    }
  }

  @override
  Future<List<FamilyAccess>> listAccess() async {
    final rows = await db.select(db.familyMemberAccesses).get();
    return rows.map((r) => FamilyAccess(r.email, r.role, r.status)).toList();
  }

  @override
  Future<SyncStatus> syncNow() async {
    await db.setSetting(SettingKeys.lastSyncAt, _now().toString());
    return SyncStatus.synced;
  }
}
