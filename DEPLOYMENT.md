# DEPLOYMENT.md: IngatObat

## Overview

Dokumen ini memuat strategi rilis **IngatObat** ke Google Play Store sebagai aplikasi Android berarsitektur **Hybrid Offline-First dengan Backend Firebase (Google Sign-In + Cloud Firestore pada Paket Gratis Spark Plan)**. Fokus pada AAB, signing, izin sensitif (Exact Alarm, Full-Screen Intent, DND), konfigurasi **Firebase Spark Plan Tanpa Kartu Kredit**, Data Safety, Account Deletion, dan pengujian tertutup.

## Environment Strategy

### Environment Tiers

| Environment | Purpose | Database & Sync | URL/Track |
|:---|:---|:---|:---|
| **Development** | Coding di emulator/fisik. | SQLite dev lokal + Firebase Dev (Spark Free) | `flutter run` |
| **Internal Testing** | Uji alarm & sinkronisasi keluarga di 3-5 HP fisik. | SQLite + Cloud Firestore (Spark Free) | Play Internal Testing |
| **Closed Testing** | Syarat akun baru 12 tester 14 hari. | SQLite + Cloud Firestore (Spark Free) | Play Closed Testing |
| **Production** | Rilis bertahap ke publik. | SQLite user + Cloud Firestore (Spark Free) | Play Production 20% → 100% |

### Build Config

```bash
flutter build appbundle --release
# output: build/app/outputs/bundle/release/app-release.aab
```

- `applicationId` mis. `id.ingatobat.app`, `versionCode` naik tiap upload, `versionName` mis. `1.0.0`.
- `minSdk 24`, `targetSdk 35`, 64-bit (`arm64` + `arm32`), support 16KB page size (AGP 8.5+).
- Konfigurasi `google-services.json` (untuk **Google Sign-In + Cloud Firestore**) dengan membiarkan project Firebase tetap di paket **Spark Plan (Gratis Selamanya & Tanpa Kartu Kredit)**. FCM **tidak** diaktifkan di jalur kritis (lihat catatan Zero-Bill di bawah).
- Play App Signing aktif; simpan upload key aman, jangan commit ke repo.

### Permissions Manifest (ringkas)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />
```

## Play Console Setup

1. Buat aplikasi, isi nama, kategori Medical, kontak developer.
2. **Isi Data Safety (Kepatuhan Sinkronisasi Keluarga):**
   - **Data Collected (Opsional saat user Login Google):** *Personal Info* (Nama & Alamat Email Google untuk undangan keluarga) dan *Health & Fitness* (Jadwal & Riwayat Obat untuk sinkronisasi keluarga).
   - **Security Practices:** Data dienkripsi saat transit (*Encrypted in transit via TLS*), tidak dijual/dibagikan ke pihak ketiga (*No data shared with third parties*), dan **menyediakan mekanisme penghapusan akun & data cloud** (*Account Deletion URL & In-App Button*).
3. **Isi Declarations sensitif:**
   - Exact Alarm (`SCHEDULE_EXACT_ALARM`): pilih use-case alarm pengingat obat, sertakan video demo alarm tembus silent (hindari `USE_EXACT_ALARM` agar tidak ditolak otomatis oleh filter Play Store).
   - Full-Screen Intent (`USE_FULL_SCREEN_INTENT`): justifikasi panggilan/alarm prioritas tinggi (medication reminder).
   - Foreground Service: deklarasikan penggunaan untuk memutar suara alarm + TTS Bahasa Indonesia. **Risiko Play:** `FOREGROUND_SERVICE_MEDIA_PLAYBACK` berpotensi ditolak untuk use-case pengingat obat (bukan pemutar media). **Verifikasi di Phase 1–2**; jika ditolak, siapkan fallback `FOREGROUND_SERVICE_SPECIAL_USE` (`specialUse` subtype `medication_reminder`) dengan justifikasi, agar tidak perlu refactor manifest di Phase 5.
4. Sediakan **Privacy Policy URL** dan **Account Deletion Instructions URL** (bisa di-host gratis di GitHub Pages / Firebase Hosting Spark Plan).
5. Upload AAB ke Internal → Closed (12 tester opt-in 14 hari) → Production bertahap.
6. Isi content rating (IARC), target audience, dan screenshots HP 16:9 + 7 inch + icon 512 + feature graphic.

## Infrastruktur Firebase Zero-Bill (Rp 0 Selamanya & Tanpa Kartu Kredit)

- **Satu Ekosistem Google (Firebase Spark Plan):** Menggunakan **Firebase Auth (`google_sign_in`)** + **Cloud Firestore** yang sudah satu akun dengan Google Play Console. **FCM tidak dipakai** (pengiriman butuh kredensial server; relay Cloud Functions butuh Blaze/kartu kredit).
- **Tanpa Kartu Kredit (100% Aman dari Tagihan):** Project Firebase dioperasikan pada paket **Spark (Free Tier)** yang memberikan gratis 1 GiB storage Firestore, 50.000 dokumen read/hari, 20.000 write/hari. Karena tidak memasang kartu kredit (tidak upgrade ke Blaze), mustahil muncul tagihan uang.
- **Real-time Offline Sync + Stop Alarm Otomatis:** Cloud Firestore memiliki fitur *Offline Persistence* bawaan dan *Real-time Snapshot Listener* yang memasang listener pada dosis yang sedang berbunyi untuk langsung mematikan alarm di HP anggota keluarga lain saat obat sudah diminum. Saat aplikasi tidak aktif, rekonsiliasi dijalankan `WorkManager` periodik (≥15 menit).
- **Deploy Security Rules:** `firebase deploy --only firestore:rules` menggunakan `firestore.rules` yang memverifikasi `access/{email}` per `family_id` (lihat ARCHITECTURE.md). Wajib diuji dengan Firestore Rules Emulator sebelum rilis.
- **Imunitas Offline-First:** Seluruh jadwal `AlarmManager` tetap di-trigger dari SQLite lokal (`drift`) di masing-masing HP, sehingga alarm obat tetap berbunyi 100% normal dalam kondisi offline apa pun.

## Monitoring

- Tanpa analitik wajib agar patuh privasi.
- Crash: Play Android Vitals + opsional Firebase Crashlytics (dengan persetujuan + deklarasi Data Safety).
- Log alarm lokal (fire/delay) untuk debug OEM, tanpa kirim keluar.

## Caching & Backup

- Cache thumbnail di disk privat dengan batas 200MB + LRU.
- Backup manual & otomatis mingguan: zip (db + foto + `version.json`) ke folder SAF yang sudah diikat dengan `takePersistableUriPermission` agar tetap bisa diakses `WorkManager` setelah perangkat di-reboot; restore memvalidasi versi skema; backup otomatis sebelum migrasi mayor ke folder privat.

## Rollback

- Produksi bertahap: hentikan rollout di Play Console bila crash > 1% atau laporan alarm gagal > 2%.
- Rollback via rilis patch versionCode baru (Play tidak mendukung downgrade langsung).
- Data user aman karena migrasi forward-only + backup pra-migrasi.

## Security Hardening

- Minify + obfuscate Dart (`--obfuscate --split-debug-info`), simpan mapping untuk deobfuscate Vitals.
- Verifikasi widget di launcher berbeda (One UI, MIUI, ColorOS); TTS uji tanpa internet dengan paket id-ID dan fallback nada.
- PDF generate diuji di HP RAM 3GB untuk 3 bulan data (< 5 detik); backup otomatis diuji retensi 4 file.
- DB privat (MODE_PRIVATE), tidak di external storage.
- PIN/biometrik **belum ada di v1.0** (masuk v1.2). Bila diimplementasikan, gunakan PIN hash + salt dan jangan log data obat ke logcat rilis.
- Validasi import zip (cek magic, versi skema, batas ukuran).

## Disaster Recovery (RTO/RPO)

- RTO: install ulang + restore backup < 10 menit.
- RPO: kehilangan maksimal sejak backup manual terakhir; sarankan backup mingguan via pengingat di aplikasi.

## Runbook

1. Alarm tidak bunyi: cek status izin di Pengaturan → aktifkan Exact Alarm + DND access → matikan battery optimization untuk IngatObat → uji alarm 1 menit.
2. Setelah reboot tidak ada alarm: pastikan RECEIVE_BOOT_COMPLETED aktif, buka aplikasi sekali untuk reschedule.
3. Restore gagal: cek versi backup vs aplikasi; update aplikasi dulu baru restore.
4. Penolakan Play (Exact Alarm/FSI): lengkapi video demo + deskripsi justifikasi, ajukan banding dengan teks standar di bawah.
   - Teks justifikasi: "IngatObat adalah pengingat minum obat untuk keluarga; alarm harus exact dan full-screen agar tidak terlewat walau silent/DND. Tanpa izin ini fungsi inti gagal."
