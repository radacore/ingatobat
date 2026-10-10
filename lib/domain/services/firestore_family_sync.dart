import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../core/constants.dart';
import '../../core/utils/ids.dart';
import '../../data/database/app_database.dart';
import 'family_sync.dart';
import 'firebase_bootstrap.dart';
import 'firestore_sync_engine.dart';
import 'google_auth_service.dart';

int _now() => DateTime.now().millisecondsSinceEpoch;

/// Implementasi sinkronisasi keluarga berbasis Cloud Firestore (FR-18).
///
/// Bila Firebase belum dikonfigurasi ([FirebaseBootstrap.isReady] == false),
/// seluruh operasi dialihkan ke [LocalFamilySyncService] sehingga aplikasi
/// tetap berjalan penuh secara offline (Mode Offline Lokal).
class FirestoreFamilySyncService implements FamilySyncService {
  FirestoreFamilySyncService(this.db)
      : _local = LocalFamilySyncService(db),
        _engine = FirestoreSyncEngine(db);

  final AppDatabase db;
  final LocalFamilySyncService _local;
  final FirestoreSyncEngine _engine;

  bool get _online => FirebaseBootstrap.isReady;

  FirebaseFirestore get _fs => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _access(String familyId) =>
      _fs.collection('family_groups').doc(familyId).collection('access');

  Future<String?> get _familyId =>
      db.getSetting(SettingKeys.currentFamilyId);

  Future<String?> get _email =>
      db.getSetting(SettingKeys.currentUserEmail);

  @override
  Future<void> signInWithGoogle() async {
    if (!_online) {
      await _local.signInWithGoogle();
      return;
    }

    final email = (await GoogleAuthService.signIn()).trim().toLowerCase();
    final indexRef = _fs.collection('email_index').doc(email);
    final indexSnap = await indexRef.get();
    final invitedFamily = indexSnap.data()?['family_id'] as String?;

    String familyId;
    String role;
    var familyName = 'Keluarga Saya';

    if (invitedFamily != null && invitedFamily.isNotEmpty) {
      // Sudah diundang → gabung otomatis ke grup yang ada.
      familyId = invitedFamily;
      final accessSnap = await _access(familyId).doc(email).get();
      role = (accessSnap.data()?['role'] as String?) ?? 'member';
      familyName = (await _fs
                  .collection('family_groups')
                  .doc(familyId)
                  .get())
              .data()?['name'] as String? ??
          familyName;
      await _access(familyId).doc(email).set({
        'email': email,
        'role': role,
        'status': 'joined',
        'joined_at': _now(),
        'updated_at': _now(),
      }, SetOptions(merge: true));
      await indexRef.set(
        {'email': email, 'family_id': familyId, 'status': 'joined'},
        SetOptions(merge: true),
      );
    } else {
      // Belum diundang → buat grup keluarga baru sebagai admin.
      familyId = Ids.uuid();
      role = 'admin';
      await _fs.collection('family_groups').doc(familyId).set({
        'id': familyId,
        'name': familyName,
        'owner_email': email,
        'created_at': _now(),
        'updated_at': _now(),
        'server_updated_at': FieldValue.serverTimestamp(),
      });
      await _access(familyId).doc(email).set({
        'email': email,
        'role': 'admin',
        'status': 'joined',
        'joined_at': _now(),
        'updated_at': _now(),
      });
      await indexRef.set({
        'email': email,
        'family_id': familyId,
        'status': 'joined',
        'updated_at': _now(),
      });
    }

    // Simpan sesi + baris keluarga lokal.
    await db.setSetting(SettingKeys.currentUserEmail, email);
    await db.setSetting(SettingKeys.currentFamilyId, familyId);
    await db.setSetting(SettingKeys.familyName, familyName);
    await db.setSetting(SettingKeys.currentUserRole, role);
    await db.setSetting(SettingKeys.lastSyncAt, _now().toString());

    await db.into(db.familyGroups).insertOnConflictUpdate(
          FamilyGroupsCompanion.insert(
            id: familyId,
            name: familyName,
            ownerEmail: email,
            createdAt: _now(),
            updatedAt: _now(),
          ),
        );
    await db.into(db.familyMemberAccesses).insertOnConflictUpdate(
          FamilyMemberAccessesCompanion.insert(
            id: '$familyId:$email',
            familyId: Value(familyId),
            email: email,
            role: Value(role),
            status: const Value('joined'),
            joinedAt: Value(_now()),
            updatedAt: _now(),
          ),
        );

    await _registerDevice(familyId, email);
    await _engine.bootstrap(familyId);
  }

  @override
  Future<void> inviteEmail(String email) async {
    await _local.inviteEmail(email);
    if (!_online) return;
    final familyId = await _familyId;
    final me = await _email;
    if (familyId == null || familyId.isEmpty) return;
    final lower = email.trim().toLowerCase();
    await _access(familyId).doc(lower).set({
      'email': lower,
      'role': 'member',
      'status': 'invited',
      'invited_by': me,
      'updated_at': _now(),
    }, SetOptions(merge: true));
    await _fs.collection('email_index').doc(lower).set({
      'email': lower,
      'family_id': familyId,
      'status': 'invited',
      'updated_at': _now(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> revokeEmail(String email) async {
    await _local.revokeEmail(email);
    if (!_online) return;
    final familyId = await _familyId;
    if (familyId == null || familyId.isEmpty) return;
    final lower = email.trim().toLowerCase();
    await _access(familyId).doc(lower).delete();
    await _fs.collection('email_index').doc(lower).delete();
  }

  @override
  Future<void> leaveFamily() async {
    final familyId = await _familyId;
    final email = await _email;
    await _local.leaveFamily();
    if (!_online) return;
    if (familyId == null || email == null) return;
    final lower = email.toLowerCase();
    await _access(familyId).doc(lower).delete();
    await _fs.collection('email_index').doc(lower).delete();
  }

  @override
  Future<void> deleteAccountAndCloud() async {
    final familyId = await _familyId;
    final email = await _email;
    await _local.deleteAccountAndCloud();
    if (!_online) return;
    if (email != null && email.isNotEmpty) {
      final lower = email.toLowerCase();
      await _fs.collection('email_index').doc(lower).delete();
      if (familyId != null && familyId.isNotEmpty) {
        await _access(familyId).doc(lower).delete();
      }
    }
    if (familyId != null && familyId.isNotEmpty) {
      final doc = await _fs.collection('family_groups').doc(familyId).get();
      final owner = doc.data()?['owner_email'] as String?;
      if (owner != null && owner == email?.toLowerCase()) {
        await _deleteFamilyTree(familyId);
      }
    }
    await GoogleAuthService.signOut();
  }

  @override
  Future<List<FamilyAccess>> listAccess() => _local.listAccess();

  @override
  Future<SyncStatus> syncNow() async {
    if (!_online) {
      return SyncStatus.offline;
    }
    final familyId = await _familyId;
    if (familyId == null || familyId.isEmpty) return SyncStatus.offline;

    final lastRaw = await db.getSetting(SettingKeys.lastSyncAt);
    final sinceMs = int.tryParse(lastRaw ?? '') ?? 0;
    try {
      await _engine.pushAll(familyId);
      if (sinceMs > 0) {
        await _engine.pullDelta(familyId, sinceMs);
      } else {
        await _engine.bootstrap(familyId);
      }
      await db.setSetting(SettingKeys.lastSyncAt, _now().toString());
      return SyncStatus.synced;
    } catch (_) {
      return SyncStatus.error;
    }
  }

  // --------------------------------------------------------------- Helpers

  Future<void> _registerDevice(String familyId, String email) async {
    var deviceId = await db.getSetting(SettingKeys.deviceId);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = Ids.uuid();
      await db.setSetting(SettingKeys.deviceId, deviceId);
    }
    await db.into(db.devices).insertOnConflictUpdate(
          DevicesCompanion.insert(
            id: deviceId,
            familyId: Value(familyId),
            email: email,
            lastSeenAt: _now(),
          ),
        );
    await _fs
        .collection('family_groups')
        .doc(familyId)
        .collection('devices')
        .doc(deviceId)
        .set({
      'id': deviceId,
      'email': email,
      'platform': 'android',
      'fcm_token': null,
      'last_seen_at': _now(),
    }, SetOptions(merge: true));
  }

  /// Menghapus dokumen grup beserta seluruh subkoleksi operasionalnya.
  Future<void> _deleteFamilyTree(String familyId) async {
    for (final name in const [
      'access',
      'devices',
      'members',
      'medicines',
      'schedules',
      'dose_logs',
      'stock_ledger',
      'control_visits',
      'side_effects',
    ]) {
      await _deleteCollection(
        _fs.collection('family_groups').doc(familyId).collection(name),
      );
    }
    await _fs.collection('family_groups').doc(familyId).delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> col,
  ) async {
    while (true) {
      final snap = await col.limit(200).get();
      if (snap.docs.isEmpty) break;
      final batch = _fs.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
