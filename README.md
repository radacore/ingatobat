# IngatObat

Aplikasi pengingat minum obat untuk keluarga — Android-only, **offline-first**,
Bahasa Indonesia, dan **Zero-Bill** (Rp 0 biaya operasional; Firebase Spark Plan).

Aplikasi berjalan 100% penuh **tanpa login**. Sinkronisasi keluarga (opsional)
aktif otomatis begitu Firebase dikonfigurasi — lihat [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

## Fitur

| Kode | Fitur |
|:--|:--|
| FR-01..FR-03 | Profil anggota keluarga, data obat + foto, jadwal fleksibel |
| FR-04..FR-06 | Alarm native (`AlarmManager` + Foreground Service + FSI), TTS, aksi cepat (Sudah Minum / Tunda / Lewati), eskalasi |
| FR-07 | Daftar beli ulang + pengingat stok menipis |
| FR-08..FR-09 | Riwayat & rekap kepatuhan (CSV/PDF), jadwal kontrol + pengingat H-2/H-1 |
| FR-10 | Izin sistem, tes suara, backup/restore ZIP via SAF, auto-backup mingguan |
| FR-11..FR-14 | TTS, eskalasi, aksesibilitas (font/tombol/kontras), widget home screen |
| FR-15..FR-17 | Efek samping, ekspor PDF, auto-backup terjadwal |
| FR-18..FR-19 | **v1.1** Login Google + invite email keluarga, delta sync Firestore, routing alarm per perangkat |

## Arsitektur

- **Flutter + Riverpod** (UI) → **Repository** → **drift/SQLite** (sumber kebenaran lokal).
- **Alarm native Kotlin** via MethodChannel `com.ingatobat/alarm` (alarm tepat waktu, notifikasi, TTS, widget).
- **WorkManager** (≥15 menit) untuk rekonsiliasi dosis terlewat & auto-backup.
- **v1.1:** `FirestoreSyncEngine` (delta sync hemat kuota Spark + Merge Policy `server_updated_at`) dan `FirestoreFamilySyncService`.

Detail lengkap ada di [PRD.md](PRD.md), [ARCHITECTURE.md](ARCHITECTURE.md),
[DATABASE.md](DATABASE.md), [API.md](API.md), [USER_FLOW.md](USER_FLOW.md).

## Build & Jalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug        # atau --release
```

Jalankan di perangkat/emulator Android:

```bash
flutter run -d <device-id>
```

> Aplikasi **Android-only** (tidak menyediakan target iOS/desktop).

## Uji & Kualitas

```bash
flutter analyze        # bersih, 0 issue
flutter test           # smoke test + unit test Merge Policy lulus
firebase emulators:start --only firestore   # uji Security Rules (FR-18)
```

## Lisensi

Proyek internal keluarga. Lihat [DEPLOYMENT.md](DEPLOYMENT.md) untuk prosedur rilis.
