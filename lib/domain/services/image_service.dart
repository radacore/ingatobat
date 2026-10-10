import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Kompresi foto obat (FR-02) + thumbnail mikro WebP < 20 KB untuk sinkronisasi.
class ImageService {
  /// Simpan foto terkompresi (max 1280px, JPEG 80) ke app-private storage.
  static Future<String> compressAndSave(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory(p.join(dir.path, 'photos'));
    if (!await photoDir.exists()) await photoDir.create(recursive: true);

    final target =
        p.join(photoDir.path, 'med_${DateTime.now().microsecondsSinceEpoch}.jpg');
    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      target,
      quality: 80,
      minWidth: 1280,
      minHeight: 1280,
      format: CompressFormat.jpeg,
    );
    return result?.path ?? sourcePath;
  }

  /// Buat thumbnail mikro WebP (Base64) < 20 KB, menurunkan kualitas bertahap.
  static Future<String?> makeThumbB64(String sourcePath) async {
    const maxBytes = 20 * 1024;
    var quality = 70;
    var width = 240;
    while (quality >= 20) {
      final bytes = await FlutterImageCompress.compressWithFile(
        sourcePath,
        quality: quality,
        minWidth: width,
        minHeight: width,
        format: CompressFormat.webp,
      );
      if (bytes != null && bytes.lengthInBytes <= maxBytes) {
        return base64Encode(bytes);
      }
      if (bytes != null && bytes.lengthInBytes > maxBytes) {
        quality -= 10;
        if (quality < 40) width = (width * 0.8).round();
      } else {
        break;
      }
    }
    // Fallback: kompresi terakhir apa pun hasilnya.
    final bytes = await FlutterImageCompress.compressWithFile(
      sourcePath,
      quality: 40,
      minWidth: 160,
      minHeight: 160,
      format: CompressFormat.webp,
    );
    return bytes == null ? null : base64Encode(bytes);
  }

  static Future<void> delete(String? path) async {
    if (path == null) return;
    final f = File(path);
    if (await f.exists()) await f.delete();
  }
}
