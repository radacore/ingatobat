import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/config.dart';

/// Login Google → FirebaseAuth (FR-18).
///
/// Dipakai hanya saat [FirebaseBootstrap.isReady]; bila belum dikonfigurasi,
/// pemanggil jatuh kembali ke Mode Offline Lokal.
class GoogleAuthService {
  GoogleAuthService._();

  static bool _initialized = false;

  static Future<void> _ensureInit() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: FirebaseConfig.serverClientId.isEmpty
          ? null
          : FirebaseConfig.serverClientId,
    );
    _initialized = true;
  }

  /// Melakukan login interaktif dan mengembalikan email akun Google.
  static Future<String> signIn() async {
    await _ensureInit();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'ID token Google tidak tersedia. Pastikan konfigurasi OAuth '
        '(serverClientId / google-services.json) sudah benar.',
      );
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCred =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return userCred.user?.email ?? account.email;
  }

  /// Email akun yang sedang login (bila ada).
  static String? get currentEmail => FirebaseAuth.instance.currentUser?.email;

  static Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // abaikan bila belum pernah login
    }
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // abaikan
    }
  }
}
