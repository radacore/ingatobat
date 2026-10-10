import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Inisialisasi Firebase + Cloud Firestore Offline Persistence (FR-18).
///
/// Bersifat *safe-fail*: bila `google-services.json` belum dikonfigurasi
/// (mis. saat pengembangan), aplikasi tetap berjalan penuh di **Mode Offline
/// Lokal** (SQLite) tanpa melempar error. Sinkronisasi cloud hanya aktif saat
/// Firebase berhasil diinisialisasi.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _ready = false;

  /// True bila Firebase + Firestore siap dipakai (mode keluarga aktif).
  static bool get isReady => _ready;

  /// Menyiapkan Firebase sekali saja. Mengembalikan `true` bila siap.
  static Future<bool> ensureInitialized() async {
    if (_ready) return true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _ready = true;
    } catch (_) {
      // Konfigurasi Firebase belum tersedia — tetap Mode Offline Lokal.
      _ready = false;
    }
    return _ready;
  }
}
