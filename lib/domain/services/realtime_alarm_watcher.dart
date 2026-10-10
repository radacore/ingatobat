import 'dart:async';

import '../../core/constants.dart';
import '../../data/database/app_database.dart';
import 'firebase_bootstrap.dart';
import 'firestore_sync_engine.dart';

/// Memantau `dose_logs/{id}` secara real-time saat alarm berbunyi (FR-18/NFR).
///
/// Bila anggota keluarga lain mengonfirmasi obat (status terminal), alarm keras
/// di HP ini dihentikan otomatis — tanpa Cloud Functions/FCM (tetap Zero-Bill).
/// Nonaktif saat Firebase belum dikonfigurasi.
class RealtimeAlarmWatcher {
  RealtimeAlarmWatcher(this.db);

  final AppDatabase db;
  final List<StreamSubscriptionHandle> _handles = [];

  /// Memasang listener untuk [doseLogIds]; [onRemoteTerminal] dipanggil sekali
  /// saat salah satu dosis dikonfirmasi/dilewati dari perangkat lain.
  Future<void> watch(
    List<String> doseLogIds, {
    required void Function() onRemoteTerminal,
  }) async {
    await stop();
    if (!FirebaseBootstrap.isReady || doseLogIds.isEmpty) return;

    final familyId = await db.getSetting(SettingKeys.currentFamilyId);
    if (familyId == null || familyId.isEmpty) return;

    final engine = FirestoreSyncEngine(db);
    for (final id in doseLogIds) {
      _handles.add(
        engine.watchDoseLog(
          familyId,
          id,
          onTerminal: (_) => onRemoteTerminal(),
        ),
      );
    }
  }

  Future<void> stop() async {
    for (final h in _handles) {
      await h.cancel();
    }
    _handles.clear();
  }
}
