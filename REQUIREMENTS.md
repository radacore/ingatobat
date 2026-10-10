# REQUIREMENTS.md: IngatObat

## 1. Functional Requirements

### 1.1. Manajemen Anggota, Obat, dan Jadwal

**FR-01: Kelola Profil Anggota**
The system SHALL menyediakan CRUD profil anggota rumah dengan dukungan *soft delete* (`is_archived`).
- Admin MUST dapat menambah profil dengan nama wajib, foto opsional, catatan opsional.
- Admin MUST dapat mengubah dan menghapus (arsip/`soft delete`) profil; menghapus profil yang punya obat aktif SHALL meminta konfirmasi, menonaktifkan semua jadwal aktif (`is_active = 0`), dan membatalkan alarm terkait sambil tetap mempertahankan histori `DOSE_LOG` dan laporan.
- Daftar anggota SHOULD menampilkan jumlah jadwal aktif hari ini per anggota.

**FR-02: Kelola Data Obat + Foto**
The system SHALL menyediakan CRUD obat per anggota beserta foto dan takaran dosis fleksibel.
- Obat MUST memiliki nama, kekuatan dosis (`dosage`, mis. "500mg"), takaran sekali minum (`dose_qty` bertipe angka/desimal, default `1.0`, mendukung bulat seperti `1` atau pecahan/volume seperti `0.5` tablet / `5` ml), satuan (tablet/kapsul/ml/tetes/bungkus), dan anggota pemilik.
- Foto MUST disimpan di app-private storage terkompresi (max 1280px, JPEG 80).
- Aturan makan (sebelum/sesudah/tanpa relasi) SHOULD tersimpan per obat dan dapat dioverride per jadwal.
- Menghapus obat yang sudah memiliki riwayat minum MUST menggunakan *soft delete* (`is_archived = 1`) agar riwayat log tidak hilang.

**FR-03: Jadwal Minum Fleksibel**
The system SHALL mendukung jadwal harian, mingguan, interval jam, dan relasi makan.
- Jadwal MUST memiliki obat, anggota, waktu mulai/selesai, status aktif, serta opsi override `dose_qty` dan `tts_enabled`.
- Tipe harian MUST menyimpan daftar jam dalam `times_json` (mis. `["08:00", "13:00", "20:00"]`).
- Tipe mingguan MUST menyimpan hari (`days_of_week` Senin=1 s/d Minggu=7) + daftar jam (`times_json`).
- Tipe interval MUST menyimpan `interval_hours` (1–24 jam) dan jam awal (`anchor_time` di elemen pertama `times_json`, mis. `["06:00"]` untuk jadwal tetap pukul 06:00, 14:00, 22:00).
- **Algoritma ekspansi interval MUST terdefinisi:** mulai dari `anchor_time` pada `start_date`, bangkitkan dosis tiap `interval_hours` secara **harian-terbatas (day-clamped)**: hanya dosis yang jatuh pada hari kalender yang sama dengan `anchor_time` yang dijadwalkan (mis. `anchor_time=06:00` + `interval=8` → 06:00, 14:00, 22:00, lalu berhenti; bukan bergulir ke 06:00 hari berikutnya dalam rantai yang sama). Hari berikutnya rantai diulang dari `anchor_time`. Jika `interval_hours` tidak membagi 24 secara rapi (mis. 7), dosis terakhir tiap hari digeser dan sisa jam diabaikan sampai hari berikutnya (dokumentasikan sebagai perilaku resmi). Dosis yang jatuh setelah `end_date` MUST tidak dijadwalkan.
- Jadwal nonaktif SHALL tidak menjadwalkan alarm tetapi tetap tersimpan.

**FR-04: Alarm Tembus Silent/DND & Penanganan Alarm Serentak**
The system SHALL membunyikan alarm via alarm stream dengan full-screen intent walau silent/DND (jika izin diberikan).
- Channel notifikasi MUST memakai importance max, sound alarm stream, bypassDnd true, fullScreenIntent.
- Penjadwalan MUST memakai exact alarm (`SCHEDULE_EXACT_ALARM`) yang survive idle/doze dan dijadwal ulang setelah reboot.
- Jika terdapat >1 jadwal pada menit yang sama (multi-obat atau multi-anggota), system MUST menggabungkannya ke dalam **satu tampilan Full-Screen Alarm Gabungan (*Grouped Alarm*)** dengan daftar kartu obat terkait serta opsi aksi per obat maupun tombol "Konfirmasi Semua".
- **Aturan aksi pada *Grouped Alarm*:** setiap kartu obat pada grup dikelola sebagai `DOSE_LOG` independen. Aksi per kartu (Sudah Minum / Tunda / Lewati) hanya mengubah log kartu tersebut. Rantai eskalasi grup **dipisah per log**: selama masih ada ≥1 log pada grup yang berstatus `pending`/`snoozed`, layar/notifikasi grup tetap tampil dan eskalasi berlanjut hanya untuk log yang belum selesai; log yang sudah `taken`/`skipped` dikeluarkan dari grup dan eskalasinya dibatalkan. Tombol "Konfirmasi Semua" menerapkan `taken` ke seluruh log grup yang masih `pending`/`snoozed` sekaligus.
- Jika izin DND/exact alarm ditolak, system SHOULD fallback ke notifikasi high-priority dan menandai status izin di Pengaturan.

**FR-05: Aksi Cepat Notifikasi**
The system SHALL menyediakan aksi Sudah Minum, Tunda, Lewati dari notifikasi dan full-screen.
- Tunda MUST menawarkan 5/10/15 menit (maksimal 5x snooze per dosis, dilacak via `snooze_count`), memperbarui `effective_scheduled_at`, dan menjadwalkan ulang satu tembakan exact alarm. **Batas total:** jumlah snooze + eskalasi tidak boleh melampaui **90 menit sejak `scheduled_at` asli**; setelah itu dosis dipaksa `missed` dan seluruh alarm dibatalkan (mencegah alarm hidup berjam-jam).
- Konfirmasi minum MUST mengurangi stok sebesar `dose_qty` (mis. `-1` tablet, `-0.5` tablet, atau `-5` ml) dan menulis `DOSE_LOG` berstatus `taken`.
- Lewati SHOULD meminta alasan opsional dan menulis status `skipped`.

**FR-06: Riwayat Minum & Koreksi Status**
The system SHALL mencatat tiap kejadian terjadwal dan aktual serta mengizinkan koreksi pencatatan.
- Setiap alarm terjadwal MUST membuat entri `pending`; jika tidak ada aksi hingga **+30 menit (6x eskalasi) sejak waktu alarm aktif terakhir (`effective_scheduled_at`)**, dosis SHALL ditandai `missed` otomatis.
- Riwayat MUST dapat difilter per anggota, obat, tanggal, dan status.
- Admin MUST dapat mengoreksi/mengubah status riwayat (`missed`/`skipped` ↔ `taken` atau membatalkan `taken` yang salah pencet) yang secara otomatis mengurangi atau mengembalikan `stock_qty` sebesar `dose_qty`.

### 1.2. Stok, Laporan, Kontrol RS, Pengaturan

**FR-07: Stok Fleksibel + Beli Ulang**
The system SHALL mengelola stok per obat secara fleksibel (angka bulat maupun desimal).
- Stok (`stock_qty` bertipe `REAL`) MUST berkurang sebesar `dose_qty` per konfirmasi `taken` (dan tidak berkurang untuk `skipped`/`missed`).
- Ambang batas (`low_stock_threshold`) MUST memicu daftar beli ulang dan satu pengingat harian jam 09:00 jika ada stok menipis (`stock_qty <= low_stock_threshold`).
- Admin MUST dapat menambah stok (restock). Setiap perubahan stok (decrement dari `taken`, restock manual, penyesuaian dari koreksi status) MUST dicatat sebagai baris ledger pada tabel `STOCK_LEDGER` (`delta`, `reason`, `ref_id`, `created_at`) sehingga `stock_qty` selalu dapat direkonsiliasi dan diaudit. `stock_qty` adalah nilai turunan yang dijaga konsisten dengan ledger (bukan satu-satunya sumber kebenaran riwayat stok).

**FR-08: Laporan Kepatuhan**
The system SHALL menghitung rekap per anggota dan per obat dalam rentang tanggal.
- Metrik MUST mencakup total terjadwal, taken, missed, skipped, snoozed, dan persentase tepat waktu.
- Laporan SHOULD dapat dibagikan sebagai teks/CSV lokal tanpa internet.

**FR-09: Pengingat Kontrol RS**
The system SHALL menyediakan CRUD kontrol RS dengan alarm pengingat hari sebelumnya.
- Kontrol MUST memiliki anggota, RS, dokter opsional, tanggal & jam kunjungan (`visit_at`), serta pengingat **H-2 Hari (2 hari sebelumnya pukul 08:00)** dan **H-1 Hari (1 hari sebelumnya pukul 08:00)**.
- Status selesai/batal MUST menghentikan seluruh alarm sisa.
- **Edge case pembuatan mendadak:** bila kontrol dibuat pada H-1 atau hari-H, pengingat yang waktunya sudah terlewat MUST **tidak dijadwalkan ke masa lalu**; aplikasi hanya menjadwalkan pengingat yang masih di masa depan dan menampilkan peringatan inline (mis. "Pengingat H-2 dilewati karena kontrol tinggal 1 hari").

**FR-10: Pengaturan + Izin + Backup**
The system SHALL menyediakan pengaturan nada, izin, dan backup lokal.
- Pengaturan MUST mencakup nada alarm, volume preview, snooze default; bahasa aplikasi terkunci full Bahasa Indonesia (tanpa pilihan bahasa lain).
- **Kunci aplikasi (PIN/biometrik) berada di luar scope v1.0** (P1 post-launch) dan MUST tidak diimplementasikan pada rilis awal.
- Status izin (notification, exact alarm, DND access) MUST terlihat dengan tombol minta izin dan panduan OEM.
- Backup MUST mengekspor DB + foto ke satu file zip lokal; restore MUST validasi versi skema sebelum menimpa.

**FR-11: Pengumuman Suara TTS**
The system SHALL mengucapkan nama anggota + obat + dosis saat alarm bila diaktifkan.
- TTS MUST dijalankan via Android Native `TextToSpeech` (offline system engine) dari foreground service alarm agar tidak terputus batas timeout BroadcastReceiver; jika paket Bahasa Indonesia (`id-ID`) belum ada, SHALL fallback ke nada saja dengan info di Pengaturan.
- Opsi per jadwal (`tts_enabled` di tabel `SCHEDULE`, on/off) MUST tersimpan; default `on`. Jika alarm bersifat *Grouped Alarm*, TTS membacakan daftar anggota dan obat secara berurutan.
- Uji suara MUST tersedia di Pengaturan.

**FR-12: Eskalasi Alarm**
The system SHALL mengulang alarm dengan volume menanjak hingga dikonfirmasi.
- Pola MUST: dijadwalkan via rantai `AlarmManager.setExactAndAllowWhileIdle` tiap 5 menit, maks 6x per segmen (total 30 menit sejak `effective_scheduled_at`); volume mulai 60% naik bertahap ke 100%.
- Konfirmasi (`taken`/`skip`) atau aksi `snooze` MUST membatalkan rantai eskalasi yang sedang berjalan.
- Setelah 6x eskalasi tanpa aksi pada segmen berjalan SHALL ditandai `missed`.
- **Batas absolut:** terlepas dari jumlah snooze, sebuah dosis tidak boleh tetap berbunyi lebih dari **90 menit sejak `scheduled_at` asli**; setelah itu dipaksa `missed` dan semua alarm dibatalkan.

**FR-13: Aksesibilitas Fleksibel**
The system SHALL menyediakan skala font, ukuran tombol, dan tema kontras global.
- Font MUST: S/M/L/XL (14/16/20/24sp baseline); tombol MUST: standar 48dp / besar 64dp.
- Tema MUST: normal dan kontras tinggi (teks putih di atas hitam / kuning di atas hitam untuk alarm).
- Berlaku MUST di semua layar termasuk full-screen alarm dan widget teks besar.

**FR-14: Widget Home**
The system SHALL menyediakan widget agenda hari ini.
- Widget MUST menampilkan 5 agenda terdekat (jam + anggota + obat); tap membuka aplikasi ke Hari Ini.
- Refresh MUST tiap 30 menit dan setiap ada perubahan jadwal/aksi.

**FR-15: Catatan Efek Samping**
The system SHALL mencatat efek samping per obat per anggota.
- Entri MUST memiliki tanggal, jenis (mual/pusing/gatal/kustom), tingkat (ringan/sedang/berat), catatan opsional. Jika jenis `kustom`, field teks `custom_kind` MUST terisi (nama efek samping bebas) dan wajib tervalidasi tidak kosong.
- Riwayat efek samping MUST tampil di detail obat dan masuk laporan.

**FR-16: Laporan PDF Offline**
The system SHALL mengekspor rekap ke PDF lokal.
- PDF MUST memuat identitas anggota, rentang tanggal, tabel kepatuhan, daftar efek samping, kontrol RS mendatang.
- Generate MUST full offline; bagikan via share sheet.

**FR-17: Backup Otomatis Mingguan**
The system SHALL membuat backup zip otomatis tiap minggu.
- Jadwal MUST default Minggu 02:00; folder tujuan dipilih via SAF dan disimpan dengan `takePersistableUriPermission` agar tetap valid setelah reboot; retensi MUST 4 file terakhir (hapus tertua otomatis).
- Gagal backup SHALL memunculkan notifikasi sekali, tidak mengulang spam.

### 1.3. Kolaborasi & Sinkronisasi Keluarga (Mode Hybrid Offline-First)

**FR-18: Login with Google & Invite Email Keluarga (Auto-Sync)**
The system SHALL menyediakan opsi Login with Google dan undangan email anggota keluarga untuk sinkronisasi otomatis lintas perangkat.
- Aplikasi MUST tetap dapat digunakan langsung secara penuh tanpa login (**Mode Offline Lokal**).
- Saat pengguna melakukan **Login with Google**, system MUST membuat `FAMILY_GROUP` baru (jika belum tergabung) atau otomatis menggabungkan perangkat ke `FAMILY_GROUP` yang sudah mengundang alamat email Google tersebut.
- Admin MUST dapat menambahkan alamat email Google anggota keluarga (`Invite by Email` ke tabel `FAMILY_MEMBER_ACCESS`) dan mencabut aksesnya kapan saja.
- Ketika anggota keluarga yang diundang menginstal aplikasi dan *Login with Google*, aplikasi MUST otomatis mengunduh data keluarga (`MEMBER`, `MEDICINE` beserta thumbnail mikro WebP `< 20 KB`, `SCHEDULE`, `CONTROL_VISIT`, `SIDE_EFFECT`) ke SQLite lokal dan langsung menjadwalkan `AlarmManager` di HP tersebut. **Bootstrap sync dibatasi:** `DOSE_LOG` hanya ditarik **90 hari terakhir** (histori lebih lama tetap tersimpan lokal di HP asal dan tidak diunduh ulang) untuk mencegah lonjakan kuota Spark pada hari pertama join; histori lebih lama dapat ditarik on-demand per anggota saat dibuka.
- Setiap perubahan jadwal atau aksi konfirmasi minum (`taken`/`snoozed`/`skipped`) MUST disinkronkan secara *Delta Sync* (`server_updated_at > last_sync_at`, fallback `updated_at`). **Penghentian alarm lintas HP** dilakukan via **Firestore Real-time Snapshot Listener** yang aktif selama `AlarmForegroundService` berbunyi (tanpa server/FCM); HP lain yang sedang tidak membunyikan alarm merekonsiliasi status pada siklus `WorkManager` periodik (≥15 menit) atau saat aplikasi dibuka. Stok hanya berkurang 1 kali (*idempotent*, lihat `FR-06` & Merge Policy di ARCHITECTURE.md).
- **Merge/konflik & keamanan MUST terdefinisi:** resolusi konflik memakai `server_updated_at` (fallback `updated_at`) dengan presedensi status terminal (`taken` > `skipped` > `missed`) dan flag `stock_applied` untuk mencegah double-decrement; hanya `role = 'admin'` yang boleh invite/revoke; Firestore Security Rules membatasi akses per `family_id` (lihat ARCHITECTURE.md & DATABASE.md).
- Admin MUST dapat **mencabut akses** email kapan saja (revoke) dan anggota MUST dapat **keluar dari grup keluarga** (leave) tanpa menghapus data lokalnya.
- Pengaturan MUST menyediakan tombol **Hapus Akun & Data Cloud** untuk mematuhi syarat penghapusan akun Google Play Store.

**FR-19: Pengaturan Bunyi Alarm Per Perangkat (Per-Device Alarm Routing)**
The system SHALL menyediakan pengaturan lokal di masing-masing HP untuk menentukan profil anggota mana yang membunyikan alarm keras di HP tersebut.
- Setiap perangkat dalam `FAMILY_GROUP` MUST menyimpan preferensi `DEVICE_MEMBER_PREF` per profil anggota dengan 2 pilihan mode:
  1. **Mode Alarm Keras (`full_alarm`):** Membunyikan suara alarm tembus silent (`USAGE_ALARM`) + *Full-Screen Intent* + TTS saat jadwal tiba (cocok untuk HP Ibu di rumah).
  2. **Mode Pantau (`monitor_only`):** Tidak membunyikan weker keras di HP tersebut, melainkan hanya menampilkan notifikasi standar ketika obat sudah diminum oleh anggota keluarga di rumah, atau menampilkan peringatan bila obat belum diminum hingga lewat batas waktu (`missed`) (cocok untuk HP Anak yang sedang bekerja di kantor).
- Secara default saat baru bergabung ke grup keluarga, aplikasi SHOULD meminta pengguna memilih profil mana saja yang ingin diaktifkan *Mode Alarm Keras*-nya di HP tersebut.
- **Anggota yang ditambahkan setelah join:** profil anggota baru MUST default ke `monitor_only` (aman, tidak membunyikan weker keras di HP mana pun secara tiba-tiba) dan aplikasi MUST menampilkan banner di Beranda untuk meminta pengguna mengaktifkan *Mode Alarm Keras* pada HP yang diinginkan. `DEVICE_MEMBER_PREF` lama MUST tetap dipertahankan (tidak ter-reset saat sinkronisasi).

## 2. Non-Functional

- **NFR-Performance:** Alarm delay < 60 detik (dieksekusi 100% dari SQLite lokal tanpa bergantung koneksi internet); cold start < 2 detik (RAM 3GB); sinkronisasi Cloud Firestore < 2 detik saat online.
- **NFR-Zero-Bill (Biaya Rp 0 Selamanya di Firebase Spark Plan):** Seluruh layanan cloud menggunakan **Firebase Spark Plan (Gratis Selamanya & Tanpa Kartu Kredit)** yang mencakup **Firebase Authentication (Google Sign-In)** dan **Cloud Firestore** (dengan *Offline Persistence* + *Delta Sync* + *Real-time Snapshot Listener* + Thumbnail Mikro WebP `< 20 KB`). **Cloud Functions dan FCM sender TIDAK dipakai** (keduanya butuh Blaze/kartu kredit) sehingga sinkronisasi real-time murni berjalan di klien. Karena akun Firebase dibiarkan di paket **Spark (Tanpa Kartu Kredit)**, tidak akan pernah ada tagihan uang meskipun jumlah pengguna membludak.
- **NFR-Reliability:** Reschedule reboot 100%; jika internet mati atau kuota harian gratis Firestore tercapai, aplikasi otomatis berjalan di atas SQLite lokal + Firestore Offline Cache tanpa mengganggu jadwal alarm; rekonsiliasi lintas HP tertunda dan dijalankan ulang via `WorkManager` periodik saat koneksi/kuota kembali; crash-free > 99%.
- **NFR-Privacy & Security:** Enkripsi TLS saat sinkronisasi; **Firestore Security Rules** memverifikasi `request.auth.token.email` terhadap dokumen akses `family_groups/{familyId}/access/{email}` (bukan sekadar field di dokumen grup); operasi invite/revoke/delete hanya untuk `role == 'admin'`; fitur hapus akun tersedia di dalam aplikasi.
- **NFR-Usability:** Full Bahasa Indonesia di seluruh UI/notifikasi/laporan/PDF; target sentuh min 48dp; kontras WCAG AA.
- **NFR-Compliance:** `targetSdk 35`; AAB; Data Safety mendeklarasikan Email & Data Kesehatan (terenkripsi untuk fungsi sinkronisasi keluarga); justifikasi Exact Alarm + Full-Screen Intent.

## 3. Technical Constraints

- Android-only, minSdk 24, targetSdk 35, Flutter + SQLite (`drift` dengan UUID v4 Primary Key) yang disinkronkan dua arah dengan **Cloud Firestore**.
- Arsitektur **Offline-First Hybrid**: SQLite lokal adalah sumber penjadwalan `AlarmManager`, sedangkan **Cloud Firestore** (dengan fitur *Offline Sync* otomatis + *Real-time Snapshot Listener* bawaan SDK Firebase) bertugas menyinkronkan data antar-HP keluarga dan menghentikan alarm secara real-time saat obat sudah diminum (tanpa Cloud Functions/FCM sender).
- Foto penuh disimpan di app-private storage (dan opsional di-backup ke Google Drive `appDataFolder` akun user), sedangkan sinkronisasi antar-HP di dokumen Firestore menggunakan thumbnail mikro WebP `< 20 KB`.

## 4. Assumptions

- Pengguna dapat memakai aplikasi di 1 HP secara offline penuh, atau menghubungkan beberapa HP anggota keluarga melalui akun Google (Gmail).
- Admin memberikan izin notification, exact alarm, dan DND access pada HP yang bertugas membunyikan alarm keras.
- Akun Play Console siap untuk closed testing dan URL privacy policy + halaman penghapusan akun tersedia.
