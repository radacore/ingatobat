# Firebase Setup (v1.1 — FR-18 / FR-19)

IngatObat **tetap berjalan 100% offline** tanpa Firebase. Sinkronisasi keluarga
aktif otomatis begitu Firebase dikonfigurasi. Tidak ada langkah build khusus yang
wajib — aplikasi sudah siap.

## 1. Buat project Firebase (Spark / gratis)

1. Buka <https://console.firebase.google.com> → **Add project**.
2. Tambahkan aplikasi **Android** dengan package name: `com.ingatobat.ingatobat`.
3. Isi **SHA-1** debug keystore (dibutuhkan Google Sign-In):
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore \
     -alias androiddebugkey -storepass android -keypass android | grep SHA1
   ```
4. Unduh **`google-services.json`** → letakkan di `android/app/google-services.json`.

> Plugin Gradle Google Services diterapkan **otomatis hanya jika** file itu ada
> (`android/app/build.gradle.kts`). Tanpa file tersebut, build tetap sukses dan
> aplikasi berjalan di Mode Offline Lokal.

## 2. Aktifkan Authentication & Firestore

1. **Authentication → Sign-in method → Google → Enable.**
2. **Firestore Database → Create database** (mode *production*).
3. Deploy security rules dari repo ini:
   ```bash
   firebase deploy --only firestore:rules
   ```
   (atau salin `firestore.rules` ke tab *Rules* di console.)

## 3. Server client ID (opsional, disarankan)

Agar `idToken` tersedia saat login di Android, isi OAuth **Web client ID**
(Google Cloud Console → Credentials) saat build:

```bash
flutter build apk --debug \
  --dart-define=FIREBASE_SERVER_CLIENT_ID=1234567890-abc.apps.googleusercontent.com
```

## 4. Uji Security Rules (emulator)

```bash
firebase emulators:start --only firestore
```

Uji minimal yang harus lulus: `member` boleh baca/tulis data operasional,
`non-member` ditolak, dan anggota tidak bisa menaikkan `role` dirinya sendiri
menjadi `admin`.

## Model data Firestore

```
family_groups/{familyId}
  name, owner_email, created_at, updated_at, server_updated_at
  ├─ access/{emailLower}        role, status, joined_at, updated_at
  ├─ devices/{deviceId}         email, platform, fcm_token, last_seen_at
  ├─ members/{memberId}
  ├─ medicines/{medicineId}     (+ photo_thumb_b64 WebP < 20 KB)
  ├─ schedules/{scheduleId}
  ├─ dose_logs/{doseLogId}      (bootstrap: 90 hari terakhir)
  ├─ stock_ledger/{ledgerId}
  ├─ control_visits/{visitId}
  └─ side_effects/{sideEffectId}

email_index/{emailLower}        family_id, status
```

**Merge Policy:** `server_updated_at` sebagai arbiter; status `dose_log` memakai
presedensi terminal (`taken` > `skipped` > `missed`); decrement stok dijaga flag
`stock_applied`.
