# PRD: IngatObat

## Executive Summary & Product Vision

Dokumen ini memuat kebutuhan produk untuk **IngatObat**, aplikasi mobile Android pengingat minum obat keluarga berarsitektur **Offline-First Hybrid dengan Sinkronisasi Keluarga Gratis (Login with Google & Invite Email)**.

Visi produk adalah memastikan tidak ada jadwal minum obat anggota keluarga yang terlewat, baik digunakan di **satu HP secara full offline** maupun **tersinkronisasi otomatis di banyak HP anggota keluarga** (mis. HP Anak di kantor memantau & mengatur jadwal, sementara HP Ibu di rumah membunyikan alarm). Aplikasi menembus mode diam (silent/DND) melalui alarm stream + full-screen intent, dilengkapi riwayat kepatuhan real-time, pengingat kontrol RS, dan dirancang dengan **Arsitektur Zero-Bill (Rp 0 biaya server/tanpa kartu kredit selamanya)**.

## Problem Statement & Target Users

**Problem:** Keluarga dengan beberapa anggota (adik, ibu, ayah) sering lupa jadwal minum obat yang berbeda-beda. Pengingat bawaan HP tidak tembus mode diam, tidak mendukung multi-profil serumah, dan ketika anak/pengelola sedang bekerja di luar rumah, ia tidak bisa mengatur jadwal atau memastikan apakah orang tua di rumah sudah minum obat.

**Target Users:**
- **Admin Pengelola (Pemilik Keluarga):** Anak/pengelola utama yang membuat jadwal anggota, obat, stok, dan kontrol RS (bisa dipakai offline lokal, atau *Login with Google* untuk mengundang email keluarga).
- **Anggota Keluarga Terundang (Caregiver / Pasien):** Ibu, ayah, atau adik yang menginstal aplikasi dan *Login with Google* menggunakan email yang sudah di-invite; data otomatis sinkron dan alarm lokal langsung terjadwal di HP mereka.
- **Profil Pasif:** Anggota keluarga (mis. balita/lansia tanpa HP) yang profilnya dikelola dan alarmnya dibunyikan di HP anggota keluarga yang ada di rumah.

## System Scope & User Roles

Sistem mendukung **Mode Offline Lokal (Tanpa Login)** dan **Mode Sinkronisasi Keluarga (Login with Google)**.

| Role | Description | Permissions |
|:---|:---|:---|
| **Admin Pengelola** | Pembuat grup keluarga (atau pengguna lokal tanpa login). | - Semua akses CRUD anggota, obat, jadwal, kontrol RS, stok, efek samping. - Login with Google & **Invite Email Keluarga**. - Atur preferensi bunyi alarm di HP-nya sendiri. - Backup/restore lokal & sinkronisasi cloud. |
| **Anggota Terundang (Family Member)** | Anggota keluarga yang login dengan email Google yang sudah di-invite. | - Otomatis menerima sinkronisasi seluruh jadwal, obat, dan kontrol RS keluarga. - Konfirmasi **Sudah Minum / Tunda / Lewati** (otomatis sinkron & mematikan alarm di HP keluarga lain). - Mengatur **Preferensi Alarm Perangkat** (profil siapa saja yang berbunyi keras di HP-nya vs hanya notifikasi pantau). |

## Functional Requirements

- **FR-01: Kelola Profil Anggota:** CRUD profil anggota rumah (nama, foto/Avatar, catatan) dengan mekanisme *soft delete* (`is_archived`) agar histori kepatuhan tetap utuh. Menggunakan UUID (`TEXT`) agar aman disinkronkan lintas perangkat.
- **FR-02: Kelola Data Obat + Foto:** CRUD obat per anggota (nama, kekuatan dosis mis. 500mg, takaran per minum `dose_qty` mis. 1 tablet / 0.5 tablet / 5 ml, satuan, aturan makan, foto kemasan + thumbnail mikro WebP `< 20 KB` untuk sinkronisasi hemat kuota).
- **FR-03: Jadwal Minum Fleksibel:** Jadwal harian (jam tertentu), mingguan (hari tertentu), interval jam (mis. tiap 8 jam dari jam awal/`anchor_time`), relasi makan (sebelum/sesudah makan), tanggal mulai/selesai, aktif/nonaktif.
- **FR-04: Alarm Tembus Silent/DND & Grouped Alarm:** Alarm memakai alarm stream + notification channel importance max + full-screen intent + bypassDnd (dengan izin DND Access). Berbunyi walau silent/DND, tampil full-screen. Mendukung tampilan gabungan (*Grouped Alarm*) bila ada beberapa obat/anggota di jam yang sama.
- **FR-05: Aksi Cepat & Sinkronisasi Pembatalan Alarm:** Dari notifikasi/full-screen: Sudah Minum (per obat atau Konfirmasi Semua), Tunda (snooze 5/10/15 menit, maks 5x per dosis), Lewati dengan alasan opsional. Saat satu HP menekan "Sudah Minum", **Firestore Real-time Snapshot Listener** (Zero-Bill, tanpa server) otomatis menghentikan eskalasi alarm di HP anggota keluarga lain yang sedang berbunyi.
- **FR-06: Riwayat Minum & Koreksi Status:** Log tiap jadwal terjadwal dengan status taken/snoozed/skipped/missed, mencatat siapa yang mengonfirmasi (`action_by_email`), filter per anggota/obat/tanggal, serta fitur koreksi/ubah status log yang otomatis menyesuaikan stok.
- **FR-07: Stok Fleksibel + Beli Ulang:** Stok per obat (mendukung angka bulat maupun desimal/ml) berkurang otomatis sebesar `dose_qty` tepat 1 kali (*idempotent* lintas HP) saat konfirmasi minum, ambang batas stok menipis, dan pengingat beli ulang.
- **FR-08: Laporan Kepatuhan:** Rekap per anggota dan per obat: persentase tepat waktu, terlewat, ditunda dalam rentang tanggal.
- **FR-09: Pengingat Kontrol RS:** CRUD jadwal kontrol (RS, dokter, tanggal & jam kunjungan, catatan) dengan alarm pengingat **H-2 Hari (pukul 08:00)** dan **H-1 Hari (pukul 08:00)** sebelum hari kontrol.
- **FR-10: Pengaturan + Izin + Backup:** Pengaturan nada, volume alarm, snooze default, permintaan izin (notification, exact alarm, DND access, battery exemption guide), export/import backup SQLite + foto ke file lokal, serta tombol **Hapus Akun & Data Cloud** (syarat kepatuhan Play Store).
- **FR-11: Pengumuman Suara TTS:** Alarm menyebut nama anggota + obat + dosis via engine sistem text-to-speech offline Bahasa Indonesia (mis. "Waktunya Ibu minum Amlodipine 5mg, 1 tablet"), dapat dimatikan per jadwal (`tts_enabled`).
- **FR-12: Eskalasi Alarm Presisi:** Nada berulang via rantai `AlarmManager` exact dengan volume menanjak (60%→100%) tiap 5 menit maks 6x (30 menit sejak waktu trigger aktif terakhir/setelah snooze) hingga dikonfirmasi sebelum ditandai `missed`.
- **FR-13: Aksesibilitas Fleksibel:** Pengaturan skala font (S/M/L/XL), ukuran tombol (standar/besar), dan tema kontras (normal/kontras tinggi) yang berlaku global termasuk layar alarm.
- **FR-14: Widget Home:** Widget agenda hari ini serumah (daftar jam + nama + obat) dengan refresh otomatis tiap 30 menit dan tap untuk buka aplikasi.
- **FR-15: Catatan Efek Samping:** Log efek samping per obat per anggota (mual, pusing, gatal, kustom) dengan tanggal dan tingkat keparahan untuk dibawa ke dokter.
- **FR-16: Laporan PDF Offline:** Rekap kepatuhan + efek samping + kontrol RS ke file PDF lokal yang bisa dibagikan via share sheet.
- **FR-17: Backup Otomatis Mingguan:** Backup zip DB + foto otomatis tiap minggu ke folder lokal pilihan (SAF dengan *persistable URI permission*) dengan retensi 4 file terakhir.
- **FR-18: Login with Google & Invite Email Keluarga (Auto-Sync):** Pengguna dapat memakai aplikasi tanpa login (offline) atau *Login with Google* untuk membuat grup keluarga (`FAMILY_GROUP`) dan mengundang alamat email Google anggota keluarga lain (`FAMILY_MEMBER_ACCESS`). Jika aplikasi terinstal di HP anggota yang diundang dan mereka login dengan email tersebut, seluruh data anggota, obat, jadwal, dan log otomatis tersinkronisasi (*Delta Sync*) dan `AlarmManager` lokal langsung terjadwal.
- **FR-19: Pengaturan Bunyi Alarm Per Perangkat (Per-Device Alarm Routing):** Setiap HP yang terhubung dalam grup keluarga dapat mengatur profil anggota mana saja yang membunyikan **Alarm Keras (Full-Screen + Tembus Silent)** di HP tersebut (mis. HP Ibu di rumah membunyikan alarm Ibu), dan profil mana yang hanya menampilkan **Notifikasi Pantau / Peringatan Terlewat** (mis. HP Anak di kantor tidak berbunyi weker keras saat rapat, tetapi menerima info saat Ibu sudah minum atau jika Ibu melewatkan dosis).

## Non-Functional Requirements

| Category | Requirement | Metric / Target |
|:---|:---|:---|
| **Performance** | Alarm tepat waktu offline, sinkronisasi ringan | - Alarm fire delay < 60 detik (100% via SQLite lokal, tidak butuh internet saat bunyi). - Cold start < 2 detik di HP RAM 3GB. - Real-time stop alarm < 3 detik via Firestore Snapshot Listener saat kedua HP online. |
| **Zero-Bill Cost** | 100% Gratis untuk Developer & User | - **Rp 0 biaya bulanan** menggunakan **Firebase Spark Plan (Gratis Selamanya & Tanpa Kartu Kredit)**: Firebase Auth (Google Sign-In) + Cloud Firestore (Offline Persistence + Delta Sync + Real-time Snapshot Listener) + Thumbnail Mikro WebP `< 20 KB`. **Tanpa Cloud Functions/FCM sender di jalur kritis** (keduanya butuh kartu kredit) — sinkronisasi real-time murni via listener Firestore di klien. |
| **Security & Privacy** | Data kesehatan terproteksi | - Enkripsi TLS selama sinkronisasi. - **Firestore Security Rules** memastikan hanya email yang di-invite di `family_member_access` yang bisa membaca/menulis dokumen keluarga tersebut. - Fitur Hapus Akun & Data Cloud tersedia. |
| **Reliability** | Offline-First & Tahan Reboot | - Reschedule otomatis setelah reboot. - Jika internet mati atau kuota harian Spark penuh, alarm lokal tetap berjalan 100% normal di atas SQLite. - Crash-free sessions > 99%. |
| **Usability** | Full Bahasa Indonesia & aksesibel | - Seluruh UI, notifikasi, error, laporan, PDF full Bahasa Indonesia (`id-ID` terkunci). - Target sentuh min 48dp, kontras WCAG AA. |
| **Compliance Play Store** | Lolos review Play Console | - `targetSdk 35`, AAB, 64-bit, 16KB page size. - Deklarasi Exact Alarm + Full-Screen Intent + Data Safety (Email & Data Kesehatan terenkripsi untuk sinkronisasi keluarga) + Account Deletion. |

## Technology Stack & Rationale

| Komponen | Teknologi | Alasan |
|:---|:---|:---|
| Framework | Flutter 3 (Dart) | Satu codebase Android, Material 3, performa baik untuk offline-first. |
| Local Database | SQLite via `drift` (UUID PK) | Sumber kebenaran lokal (*local source of truth*) untuk `AlarmManager` agar alarm tetap bekerja 100% walau tanpa internet. |
| Auth & Invite | **Firebase Auth (`google_sign_in`)** | Satu ekosistem dengan akun Google/Play Console; login 1-klik & validasi email undangan keluarga (100% Gratis di Spark Plan). |
| Cloud Sync & Realtime | **Cloud Firestore (Firebase Spark Plan)** | Fitur **Offline Sync otomatis** + *Real-time Snapshot Listener* untuk langsung mematikan alarm saat obat diminum di HP keluarga lain (**Tanpa Kartu Kredit = 0 risiko tagihan**). |
| Push / Wake-up (Opsional, di luar jalur kritis) | **Realtime Listener (kritis) + WorkManager (reconcile) + FCM (opsional/masa depan)** | Stop alarm lintas HP memakai Firestore Realtime Listener yang aktif selama `AlarmForegroundService` berbunyi. Notifikasi pantau saat aplikasi mati disinkronkan via `WorkManager` periodik (≥15 menit). FCM **tidak** dipakai di v1.0 karena pengiriman butuh kredensial server (Cloud Functions = butuh kartu kredit, melanggar Zero-Bill); disimpan sebagai enhancement opsional di rilis lanjutan bila relay server tersedia. |
| Penjadwalan | `AlarmManager` + `BroadcastReceiver` + `AlarmForegroundService` | Alarm exact walau idle/doze, reschedule reboot, bebas timeout BroadcastReceiver. |
| Notifikasi | `flutter_local_notifications`, channel `USAGE_ALARM` | Alarm stream + `fullScreenIntent` + `bypassDnd`, aksi cepat. |
| Foto & Sync | `image_picker` + WebP Thumbnail `< 20KB` + Google Drive `appDataFolder` (opsional) | Foto tajam di lokal/Drive milik user sendiri; thumbnail mikro WebP `< 20KB` langsung tersinkron di dokumen Firestore tanpa biaya Cloud Storage. |
| TTS offline | Android Native `TextToSpeech` + `flutter_tts` | Pengumuman suara tanpa internet, Bahasa Indonesia bila paket tersedia. |
| PDF & Widget | `pdf` + `printing`, `home_widget` + `WorkManager` | Generate laporan PDF full offline & widget agenda hari ini di home screen. |

## Success Metrics & KPIs

| Metric | KPI | Target |
|:---|:---|:---|
| Kepatuhan | Jadwal tepat waktu | > 85% dosis tepat waktu per bulan. |
| Sinkronisasi Keluarga | Kecepatan sinkron status "Sudah Minum" antar-HP | < 3 detik via Firestore Real-time Snapshot Listener saat kedua HP online & alarm aktif. |
| Setup & Invite | Waktu tambah jadwal + invite email keluarga | < 5 menit hingga HP keluarga yang diundang tersinkron. |
| Keandalan | Alarm berbunyi sesuai jadwal (walau offline) | > 98% fire rate di uji 7 hari. |
| Biaya Operasional | Tagihan Cloud / Server Developer | **Rp 0 (100% berjalan di dalam Firebase Spark Plan Tanpa Kartu Kredit)**. |

## Risk Analysis & Mitigation

| Risk | Impact | Mitigation Strategy |
|:---|:---|:---|
| **Lonjakan pengguna memicu biaya server** | High | Gunakan **Firebase Spark Plan (Tanpa Kartu Kredit)** yang memiliki *hard-limit* otomatis sehingga mustahil timbul tagihan. Optimalkan kuota Firestore dengan *Delta Sync* (`server_updated_at > last_sync_at`, fallback `updated_at`) dan thumbnail mikro `< 20KB`. |
| **Kuota Free Tier cloud penuh / Internet mati** | Medium | Karena arsitektur **Offline-First (SQLite + Firestore Offline Cache)**, seluruh alarm di tiap HP dieksekusi lokal; gangguan cloud tidak pernah mematikan alarm obat. |
| **Semua HP keluarga berbunyi keras di kantor** | Medium | Sediakan fitur **Per-Device Alarm Routing (`FR-19`)**: HP di kantor cukup mode *Notifikasi Pantau*, HP di rumah mode *Alarm Keras*. |
| **Konflik stok berkurang 2x saat ditekan bersamaan** | Medium | Gunakan ID dokumen deterministik `UUIDv5(schedule_id + scheduled_at)` di `DOSE_LOG` (*idempotent confirm*); hanya aksi pertama yang mengurangi stok. |
| **Alarm tidak bunyi (Doze/battery killer)** | High | Pakai `setExactAndAllowWhileIdle`, minta abaikan battery optimization via panduan, uji di Samsung/Xiaomi/Oppo, reschedule reboot. |

## Constraints & Assumptions

- **Constraint:** Android-only, mendukung **Mode Offline Lokal (Tanpa Login)** maupun **Mode Sinkronisasi Keluarga (Login with Google)**.
- **Constraint:** Stack pengembangan wajib **Zero-Bill (Rp 0 biaya operasional / tanpa kewajiban kartu kredit)**.
- **Constraint:** Bahasa aplikasi full Bahasa Indonesia (`id-ID` terkunci).
- **Assumption:** Anggota keluarga yang diundang memiliki akun Google (email Gmail) yang aktif di HP Android mereka.

## Release Scope (Phasing)

Untuk menekan risiko jadwal dan memvalidasi keandalan alarm lebih dulu, rilis dipecah:

- **v1.0 — Offline-First (tanpa login):** seluruh FR-01 s/d FR-17 (multi-profil serumah, alarm tembus silent, aksi cepat, riwayat, stok, laporan, kontrol RS, TTS, aksesibilitas, widget, efek samping, PDF, auto-backup). Dapat dipakai penuh tanpa akun/internet.
- **v1.1 — Family Sync:** FR-18 & FR-19 (Login with Google, Invite Email, Delta Sync, Per-Device Alarm Routing). Ditambahkan setelah v1.0 lolos closed testing keandalan alarm.

## Out of Scope

Rilis awal **TIDAK** mencakup:
- Versi iOS.
- Telemedicine, chat dokter, atau beli obat online.
- Integrasi smartwatch/wearable.
- Rekomendasi dosis otomatis oleh AI.
