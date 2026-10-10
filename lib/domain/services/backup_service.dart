import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';
import '../../data/database/app_database.dart';

/// Backup & restore lokal (FR-10, FR-17).
///
/// Format: satu file ZIP berisi `ingatobat.sqlite`, folder `photos/`, dan
/// `manifest.json` (versi skema untuk validasi sebelum menimpa).
class BackupService {
  final AppDatabase db;
  BackupService(this.db);

  static const _schemaVersion = 1;

  Future<String> dbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'ingatobat.sqlite');
  }

  Future<Directory> photosDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory(p.join(dir.path, 'photos'));
  }

  Future<Directory> backupsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(dir.path, 'backups'));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  /// Ekspor DB + foto menjadi satu file ZIP lokal. Mengembalikan file ZIP.
  Future<File> exportZip() async {
    final tmp = await getTemporaryDirectory();
    final snapshotPath =
        p.join(tmp.path, 'snapshot_${DateTime.now().millisecondsSinceEpoch}.sqlite');

    // Salinan konsisten DB via VACUUM INTO.
    await db.customStatement("VACUUM INTO '$snapshotPath'");

    final archive = Archive();
    final snapshotBytes = await File(snapshotPath).readAsBytes();
    archive.addFile(ArchiveFile.bytes('ingatobat.sqlite', snapshotBytes));

    final photos = await photosDir();
    if (await photos.exists()) {
      await for (final entity in photos.list()) {
        if (entity is File) {
          archive.addFile(ArchiveFile.bytes(
            'photos/${p.basename(entity.path)}',
            await entity.readAsBytes(),
          ));
        }
      }
    }

    final manifest = jsonEncode({
      'schemaVersion': _schemaVersion,
      'appVersion': AppInfo.version,
      'createdAt': DateTime.now().toIso8601String(),
    });
    archive.addFile(ArchiveFile.string('manifest.json', manifest));

    final bytes = ZipEncoder().encodeBytes(archive);
    final out = File(
        p.join((await backupsDir()).path, 'ingatobat_backup_${_stamp()}.zip'));
    await out.writeAsBytes(bytes);

    try {
      await File(snapshotPath).delete();
    } catch (_) {
      // abaikan bila snapshot sudah tidak ada
    }

    // Retensi lokal: simpan 4 file terbaru.
    await _pruneLocal(4);
    return out;
  }

  Future<void> _pruneLocal(int keep) async {
    final dir = await backupsDir();
    final files = (await dir.list().toList())
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (var i = keep; i < files.length; i++) {
      await files[i].delete().catchError((_) => files[i]);
    }
  }

  /// Validasi + restore dari byte ZIP. Menimpa DB & foto lokal.
  Future<RestoreResult> restoreFromBytes(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);

    ArchiveFile? manifestFile;
    ArchiveFile? dbFile;
    final photos = <ArchiveFile>[];
    for (final f in archive) {
      if (f.name == 'manifest.json') manifestFile = f;
      if (f.name == 'ingatobat.sqlite') dbFile = f;
      if (f.name.startsWith('photos/') && f.isFile) photos.add(f);
    }

    if (dbFile == null) {
      return const RestoreResult(false, 'File backup tidak valid: DB tidak ditemukan.');
    }
    if (manifestFile == null) {
      return const RestoreResult(false, 'File backup tidak valid: manifest tidak ditemukan.');
    }
    final manifest = jsonDecode(utf8.decode(manifestFile.readBytes() ?? []));
    final version = manifest['schemaVersion'];
    if (version != _schemaVersion) {
      return RestoreResult(
          false, 'Versi skema tidak cocok (backup: $version, aplikasi: $_schemaVersion).');
    }

    final dbBytes = dbFile.readBytes();
    if (dbBytes == null) {
      return const RestoreResult(false, 'Gagal membaca isi DB pada backup.');
    }

    await db.close();
    await File(await dbPath()).writeAsBytes(dbBytes, flush: true);

    final photosDir_ = await photosDir();
    if (!await photosDir_.exists()) await photosDir_.create(recursive: true);
    for (final f in photos) {
      final name = p.basename(f.name);
      final data = f.readBytes();
      if (data != null) {
        await File(p.join(photosDir_.path, name)).writeAsBytes(data, flush: true);
      }
    }

    return const RestoreResult(true, 'Restore berhasil. Muat ulang aplikasi.');
  }

  static String _stamp() {
    final n = DateTime.now();
    return '${n.year}${n.month.toString().padLeft(2, '0')}${n.day.toString().padLeft(2, '0')}_'
        '${n.hour.toString().padLeft(2, '0')}${n.minute.toString().padLeft(2, '0')}';
  }
}

class RestoreResult {
  final bool success;
  final String message;
  const RestoreResult(this.success, this.message);
}
