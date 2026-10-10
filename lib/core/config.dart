/// Konfigurasi build-time untuk integrasi Firebase (FR-18).
///
/// Nilai dapat di-override lewat `--dart-define`:
/// `flutter run --dart-define=FIREBASE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com`
class FirebaseConfig {
  FirebaseConfig._();

  /// OAuth Web client ID (Google Cloud Console). Dibutuhkan di Android agar
  /// `idToken` tersedia untuk `signInWithCredential`. Kosong = login Google
  /// dinonaktifkan (aplikasi tetap Mode Offline Lokal).
  static const String serverClientId = String.fromEnvironment(
    'FIREBASE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}
