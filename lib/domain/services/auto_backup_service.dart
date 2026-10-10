import '../../core/constants.dart';
import '../../data/database/app_database.dart';
import 'alarm_service.dart';
import 'backup_service.dart';

/// Backup otomatis mingguan ke folder SAF (FR-17).
class AutoBackupService {
  final AppDatabase db;
  AutoBackupService(this.db);

  static const _intervalMs = 7 * 24 * 60 * 60 * 1000;
  static const _keep = 4;

  /// Jalankan bila sudah lewat 7 hari sejak backup terakhir.
  Future<bool> maybeRunWeekly() async {
    final uri = await db.getSetting(SettingKeys.autoBackupUri);
    if (uri == null || uri.isEmpty) return false;

    final lastAt =
        int.tryParse(await db.getSetting(SettingKeys.autoBackupLastAt) ?? '0') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastAt < _intervalMs) return false;

    return runNow();
  }

  /// Jalankan backup sekarang ke folder SAF yang tersimpan.
  Future<bool> runNow() async {
    final uri = await db.getSetting(SettingKeys.autoBackupUri);
    if (uri == null || uri.isEmpty) return false;

    try {
      final service = BackupService(db);
      final zip = await service.exportZip();
      final bytes = await zip.readAsBytes();
      final name = zip.uri.pathSegments.last;

      await AlarmService.writeBackupToFolder(uri, name, bytes);
      await _prune(uri);

      await db.setSetting(
          SettingKeys.autoBackupLastAt, DateTime.now().millisecondsSinceEpoch.toString());
      return true;
    } catch (_) {
      // Gagal backup: beri tahu sekali (ditangani pemanggil bila perlu).
      return false;
    }
  }

  Future<void> _prune(String treeUri) async {
    final files = await AlarmService.listBackups(treeUri);
    if (files.length <= _keep) return;
    // Urutkan menurun berdasarkan nama (timestamp) lalu hapus sisanya.
    files.sort((a, b) => (b['name'] ?? '').compareTo(a['name'] ?? ''));
    for (var i = _keep; i < files.length; i++) {
      final docUri = files[i]['uri'];
      if (docUri != null) await AlarmService.deleteDocument(docUri);
    }
  }

  Future<void> setFolder(String uri) async {
    await db.setSetting(SettingKeys.autoBackupUri, uri);
  }
}
