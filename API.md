# API.md: IngatObat

Aplikasi menggunakan arsitektur **Hybrid Offline-First dengan Backend Firebase (Google Sign-In + Cloud Firestore pada Spark Plan Gratis)**. Dokumen ini memuat Local Data API (repository/DAO Dart di atas SQLite `drift`), Cloud Family Sync API (Firebase Auth + Cloud Firestore Offline Sync + Real-time Snapshot Listener), dan integrasi platform Android.

> **Catatan tentang "Path":** nilai seperti `local://...` dan `sync://...` **bukan endpoint jaringan/REST**. Itu adalah **identifier internal** untuk memetakan method repository ke FR, memudahkan penelusuran & pengujian. Semua operasi berjalan in-process (Dart) di atas SQLite lokal dan SDK Firebase.

## Authentication & Authorization

Mendukung **Mode Offline Lokal (Tanpa Login)** dan **Mode Sinkronisasi Keluarga (Login with Google)**.

**Auth Level:**
- **Local (Offline):** Semua akses CRUD lokal tanpa perlu akun/internet.
- **Google Sign-In (`firebase_auth` + `google_sign_in`):** Digunakan saat pengguna ingin membuat grup keluarga (`family_groups`), mengundang email keluarga (`Invite by Email`), atau bergabung ke grup keluarga yang telah mengundang emailnya.
- **Firestore Security Rules:** Di sisi Cloud Firestore, hanya pengguna yang alamat email Google-nya (`request.auth.token.email`) terdaftar di subcollection `family_groups/{familyId}/access/{emailLowercased}` yang berhak membaca/menulis dokumen keluarga tersebut. Operasi invite/revoke/ubah role hanya untuk `role == 'admin'`.
- **Kunci Aplikasi (PIN/biometrik):** **di luar scope v1.0** (P1 post-launch). Tidak diimplementasikan pada rilis awal.

## Standard Response & Error Formats

**Success (Result object):**
```json
{
  "success": true,
  "data": { "id": "b6e8a0c2-...", "name": "Ibu" },
  "message": "Anggota ditambahkan & disinkronkan"
}
```

**Error:**
```json
{
  "success": false,
  "error": "validation_error",
  "message": "Nama anggota wajib diisi",
  "errors": { "name": ["required"] }
}
```

**Status internal:** ok, validation_error, not_found, permission_denied, storage_full, alarm_unscheduled, offline_queued (tersimpan lokal & akan otomatis sinkron saat internet aktif).

## Local Data & Family Sync API

Setiap method di bawah memetakan FR-01 s/d FR-19 ke operasi SQLite lokal (`drift`) sekaligus antrean *Delta Sync*.

### Kolaborasi & Sinkronisasi Keluarga (FR-18, FR-19)

#### Login with Google & Auto-Discover Family Invite
- **Method:** `FamilySyncRepository.signInWithGoogle()`
- **Path:** `sync://auth/google`
- **Description:** Login dengan akun Google Android. Sistem mengecek `email_index/{email}` untuk menemukan undangan (`status = 'invited'`). Jika sudah diundang, perangkat otomatis bergabung (`status = 'joined'`), melakukan **bootstrap sync** (data referensi penuh + `DOSE_LOG` **90 hari terakhir**), mendaftarkan perangkat ke tabel `DEVICE`, dan menjadwalkan `AlarmManager`. Jika belum ada undangan, sistem membuat `FAMILY_GROUP` baru, menulis `email_index`, dan mengunggah data lokal HP ini.
- **Auth Level:** Google OAuth
- **Response Body:**
```json
{
  "success": true,
  "data": {
    "family_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "role": "member",
    "auto_joined_from_invite": true,
    "members_synced": 2,
    "schedules_synced": 5
  }
}
```

#### Invite Family Member by Email
- **Method:** `FamilySyncRepository.inviteByEmail(email)`
- **Path:** `sync://family/invite`
- **Description:** Admin menambahkan alamat email Google anggota keluarga ke subcollection `family_groups/{familyId}/access/{email}` **dan** ke `email_index/{email}`. Saat pemilik email tersebut menginstal aplikasi dan *Login with Google*, data langsung tersinkronisasi otomatis.
- **Auth Level:** Google OAuth — **hanya `role == 'admin'`** (ditegakkan Firestore Security Rules).
- **Request Body:** `{ "email": "ibu.siti@gmail.com", "role": "member" }`
- **Response Body:** `{ "success": true, "data": { "invite_id": "9c858901-...", "status": "invited" } }`

#### Revoke Family Member Access
- **Method:** `FamilySyncRepository.revokeAccess(email)`
- **Path:** `sync://family/revoke`
- **Description:** Admin mencabut akses email anggota (`access/{email}` dihapus + `email_index/{email}` dihapus). Perangkat anggota tersebut kehilangan akses baca/tulis pada sinkronisasi berikutnya; data lokal di HP-nya tidak dihapus kecuali diminta.
- **Auth Level:** Google OAuth — hanya `role == 'admin'`.

#### Leave Family Group
- **Method:** `FamilySyncRepository.leaveFamily()`
- **Path:** `sync://family/leave`
- **Description:** Anggota keluar dari grup keluarga. Menghapus dokumen akses miliknya sendiri (`access/{email}` + `email_index/{email}`) dan berhenti sinkron; data lokal tetap tersimpan sehingga aplikasi kembali ke Mode Offline Lokal.
- **Auth Level:** Google OAuth (anggota sendiri).

#### Delta Sync (Cloud Firestore Offline Sync & Real-time Listener)
- **Method:** `FirestoreSyncEngine.syncDelta(lastSyncAt)`
- **Path:** `sync://family/delta`
- **Description:** Memanfaatkan *Offline Persistence* bawaan **Cloud Firestore** + query perubahan `server_updated_at > last_sync_at` (fallback `updated_at`; termasuk `photo_thumb_b64` WebP `< 20 KB`), serta *Real-time Snapshot Listener* pada `dose_logs/{id}` yang sedang berbunyi untuk langsung mematikan alarm di HP anggota keluarga lain saat obat diminum. Rekonsiliasi saat aplikasi tidak aktif dijalankan oleh `WorkManager` periodik (≥15 menit). Konflik diresolve mengikuti **Merge Policy** (lihat ARCHITECTURE.md).
- **Auth Level:** Google Sign-In (`firebase_auth`)

#### Set Per-Device Alarm Routing (FR-19)
- **Method:** `DevicePrefRepository.setMemberAlarmMode(memberId, alarmMode)`
- **Path:** `local://device-prefs/alarm-mode`
- **Description:** Mengatur di HP ini apakah jadwal milik `memberId` akan membunyikan **Alarm Keras (`full_alarm`)** atau **Hanya Notifikasi Pantau (`monitor_only`, misal di HP Anak saat di kantor)**.
- **Auth Level:** Local
- **Request Body:** `{ "member_id": "b6e8a0c2-...", "alarm_mode": "monitor_only" }`

#### Delete Account & Cloud Data (Play Store Requirement)
- **Method:** `FamilySyncRepository.deleteAccountAndCloudData()`
- **Path:** `sync://auth/delete-account`
- **Description:** Menghapus akun pengguna dan akses/grup keluarga di cloud secara permanen tanpa menghapus data lokal di HP (kecuali diminta user).
- **Auth Level:** Google OAuth

### Anggota (FR-01)

#### Create Member
- **Method:** `MemberRepository.create()`
- **Path:** `local://members/create`
- **Description:** Menambah profil anggota rumah (UUID v4).
- **Auth Level:** Local + Auto-Sync
- **Request Body:**
```json
{ "name": "Ibu", "avatar_path": "/data/.../ibu.jpg", "avatar_thumb_b64": "UklGR...", "notes": "Alergi penicillin" }
```
- **Response Body:**
```json
{ "success": true, "data": { "id": "b6e8a0c2-...", "name": "Ibu" } }
```
- **Status Codes:** ok, validation_error, storage_full

#### List Members With Today Count
- **Method:** `MemberRepository.listWithTodayCount(date)`
- **Path:** `local://members/list`
- **Description:** Daftar anggota + jumlah jadwal aktif hari ini + mode alarm di HP ini (`full_alarm` / `monitor_only`).
- **Auth Level:** Local
- **Response Body:**
```json
{ "success": true, "data": [{ "id": "b6e8a0c2-...", "name": "Ibu", "today_count": 3, "device_alarm_mode": "full_alarm" }] }
```

#### Archive (Soft Delete) Member
- **Method:** `MemberRepository.archive(memberId)`
- **Path:** `local://members/archive`
- **Description:** Mengarsipkan profil anggota (`is_archived = 1`), menonaktifkan semua jadwal aktif miliknya, dan membatalkan alarm di semua HP keluarga tanpa menghapus histori `DOSE_LOG` maupun `SIDE_EFFECT`.
- **Auth Level:** Local + Auto-Sync
- **Response Body:** `{ "success": true, "data": { "id": "b6e8a0c2-...", "schedules_deactivated": 3 } }`

### Obat (FR-02, FR-07)

#### Create Medicine
- **Method:** `MedicineRepository.create()`
- **Path:** `local://medicines/create`
- **Description:** Menambah obat per anggota dengan kekuatan dosis, takaran per minum fleksibel (`dose_qty` bulat/desimal), foto privat lokal, thumbnail mikro WebP (`< 20 KB`) untuk sinkronisasi gratis, dan stok awal.
- **Auth Level:** Local + Auto-Sync
- **Request Body:**
```json
{
  "member_id": "b6e8a0c2-...", "name": "Amlodipine", "dosage": "5mg",
  "dose_qty": 1.0, "unit": "tablet", "meal_relation": "after",
  "photo_path": "/data/.../amlod.jpg", "photo_thumb_b64": "UklGR...",
  "stock_qty": 30.0, "low_stock_threshold": 5.0
}
```
- **Response Body:** `{ "success": true, "data": { "id": "d290f1ee-..." } }`
- **Status Codes:** ok, validation_error, not_found (member)

#### Restock Medicine
- **Method:** `MedicineRepository.restock(medicineId, qty)`
- **Path:** `local://medicines/restock`
- **Description:** Menambah stok (`REAL`, bulat/desimal), menulis baris `STOCK_LEDGER` (`reason = 'restock'`, `delta = +qty`, `balance_after`), dan menyinkronkan ke keluarga.
- **Auth Level:** Local + Auto-Sync
- **Request Body:** `{ "medicine_id": "d290f1ee-...", "qty": 30.0 }`
- **Response Body:** `{ "success": true, "data": { "stock_left": 60.0 } }`

### Jadwal (FR-03, FR-04, FR-11)

#### Create Schedule
- **Method:** `ScheduleRepository.create()`
- **Path:** `local://schedules/create`
- **Description:** Membuat jadwal fleksibel (dengan opsi `tts_enabled` dan override `dose_qty`), menjadwalkan exact alarm lokal (jika `alarm_mode == 'full_alarm'`), dan menyinkronkan ke HP keluarga lain via Firestore Delta Sync + Realtime Listener.
- **Auth Level:** Local + Auto-Sync
- **Request Body:**
```json
{
  "member_id": "b6e8a0c2-...", "medicine_id": "d290f1ee-...",
  "recurrence_type": "daily",
  "times_json": "[\"08:00\",\"20:00\"]",
  "interval_hours": null, "days_of_week": null,
  "dose_qty": null, "tts_enabled": true,
  "start_date": 1767225600000, "end_date": null, "is_active": true
}
```
- **Response Body:** `{ "success": true, "data": { "id": "a112c300-...", "alarms_scheduled": 2 } }`
- **Status Codes:** ok, validation_error, permission_denied (exact alarm)

### Dosis / Aksi (FR-04, FR-05, FR-06)

#### Confirm Taken (Single or Batch/Grouped — Idempotent Across Devices)
- **Method:** `DoseRepository.confirmTaken(logIds)`
- **Path:** `local://doses/taken`
- **Description:** Menandai sudah minum (`action_by_email` tercatat), mengurangi stok sebesar `dose_qty` tepat 1 kali (guard `stock_applied: false → true` + *Unique Constraint* `(schedule_id, scheduled_at)` + ID `UUIDv5(schedule_id + scheduled_at)`), menulis baris `STOCK_LEDGER`, menghentikan rantai eskalasi lokal, dan menulis `dose_logs/{id}` ke Firestore sehingga **Firestore Real-time Listener** di HP anggota keluarga lain (yang sedang berbunyi) otomatis menghentikan alarm.
- **Auth Level:** Local + Auto-Sync
- **Request Body:** `{ "log_ids": ["e550a111-..."] }`
- **Response Body:** `{ "success": true, "data": [{ "log_id": "e550a111-...", "stock_left": 29.0 }] }`

#### Snooze Dose
- **Method:** `DoseRepository.snooze(logId, minutes)`
- **Path:** `local://doses/snooze`
- **Description:** Tunda 5/10/15 menit (maksimal 5x per dosis via `snooze_count`), memperbarui `effective_scheduled_at = now + minutes`, mereset rantai eskalasi 30 menit ke waktu baru, dan menjadwalkan satu tembakan exact alarm.
- **Auth Level:** Local + Auto-Sync
- **Request Body:** `{ "log_id": "e550a111-...", "minutes": 10 }`

#### Skip Dose
- **Method:** `DoseRepository.skip(logId, note)`
- **Path:** `local://doses/skip`
- **Description:** Lewati dengan alasan opsional dan hentikan rantai eskalasi di semua HP keluarga tanpa mengurangi stok.
- **Auth Level:** Local + Auto-Sync

#### Correct / Undo Dose Status
- **Method:** `DoseRepository.updateStatus(logId, newStatus, note)`
- **Path:** `local://doses/update-status`
- **Description:** Mengoreksi status log di halaman Riwayat (`missed`/`skipped` ↔ `taken`), menyesuaikan `stock_qty` secara atomik (`-dose_qty` atau `+dose_qty`), dan menyinkronkannya ke seluruh HP keluarga.
- **Auth Level:** Local + Auto-Sync
- **Request Body:** `{ "log_id": "e550a111-...", "new_status": "taken", "note": "Sudah diminum tepat waktu, lupa tekan tombol" }`

#### Query History
- **Method:** `DoseRepository.history(memberId, from, to, status)`
- **Path:** `local://doses/history`
- **Description:** Riwayat dengan filter dan paginasi 50/halaman (menampilkan siapa yang menekan tombol di `action_by_email`).
- **Auth Level:** Local

### Laporan (FR-08)

#### Compliance Report
- **Method:** `ReportRepository.compliance(memberId, from, to)`
- **Path:** `local://reports/compliance`
- **Description:** Rekap taken/missed/skipped/snoozed + persentase.
- **Auth Level:** Local
- **Response Body:**
```json
{
  "success": true,
  "data": { "scheduled": 60, "taken": 54, "missed": 4, "skipped": 2, "on_time_pct": 90 }
}
```

### Kontrol RS (FR-09)

#### Create Control Visit
- **Method:** `ControlRepository.create()`
- **Path:** `local://controls/create`
- **Description:** Jadwal kontrol RS + otomatis menjadwalkan 2 exact alarm pengingat pada **H-2 Hari (pukul 08:00)** dan **H-1 Hari (pukul 08:00)** sebelum tanggal kunjungan serta menyinkronkan ke keluarga.
- **Auth Level:** Local + Auto-Sync
- **Request Body:**
```json
{
  "member_id": "b6e8a0c2-...", "hospital": "RSUD Kota", "doctor": "dr. Andi",
  "visit_at": 1770000000000,
  "reminder_h2_at": 1769817600000,
  "reminder_h1_at": 1769904000000,
  "notes": "Bawa kartu BPJS & hasil lab"
}
```

### Pengaturan, TTS, Eskalasi, Widget, Efek Samping, PDF, Auto-Backup (FR-10 s/d FR-17)

- **`SettingRepository.get/set(key, value)` (`local://settings`):** Pengaturan nada, snooze default, aksesibilitas (`FR-13`), preferensi sinkronisasi.
- **`BackupService.exportZip() / importZip(file)` (`local://backup`):** Ekspor/impor ZIP (DB + foto) lokal & jadwal otomatis mingguan SAF (`takePersistableUriPermission`, `FR-17`).
- **`TtsService.speakAlarm(items)` (`local://tts/speak`):** Android Native `TextToSpeech` (`id-ID` offline) di dalam `AlarmForegroundService` (`FR-11`).
- **`EscalationScheduler.scheduleNext(logId, step) / cancel(logId)` (`local://escalation`):** Rantai `AlarmManager.setExactAndAllowWhileIdle` tiap 5 menit maks 6x (`FR-12`).
- **`WidgetService.refreshToday()` (`local://widget/refresh`):** Refresh 5 agenda terdekat ke home widget (`FR-14`).
- **`SideEffectRepository.create/list()` (`local://side-effects`):** Catat & sinkronkan efek samping obat (`FR-15`).
- **`PdfService.compliancePdf()` (`local://reports/pdf`):** Buat laporan PDF offline (`FR-16`).

## Android Platform Integration

### Alarm Scheduling & Cross-Device Stop (Tanpa FCM)
- **Channel:** `MethodChannel alarmScheduler`
- **Native Alarm:** `AlarmManager.setExactAndAllowWhileIdle(RTC_WAKEUP)` + `BroadcastReceiver` (`AlarmReceiver` → `AlarmForegroundService`) + reschedule saat `BOOT_COMPLETED`, `TIME_SET`, `MY_PACKAGE_REPLACED`.
- **Firestore Real-time Listener (jalur kritis, Zero-Bill):** selama `AlarmForegroundService` berbunyi, ia memasang listener pada `family_groups/{familyId}/dose_logs/{logId}` untuk dosis terkait. Saat snapshot berubah menjadi `taken`/`skipped` (dari HP keluarga mana pun), service langsung menghentikan suara & membatalkan `EscalationScheduler` untuk dosis tersebut, lalu memperbarui SQLite lokal. Bila HP ini dalam mode `monitor_only`, tampilkan notifikasi info "Ibu sudah minum ...".
- **WorkManager Reconcile (pengganti push saat app tidak aktif):** `WorkManagerSyncWorker` periodik (≥15 menit) menarik delta Firestore, memperbarui SQLite, me-reschedule `AlarmManager`, dan menampilkan notifikasi pantau tertunda untuk mode `monitor_only`.
- **Catatan FCM:** **tidak digunakan pada v1.0**. Pengiriman FCM memerlukan kredensial server (tidak boleh ada di APK) dan relay Cloud Functions membutuhkan Blaze/kartu kredit sehingga melanggar Zero-Bill. Dicatat sebagai enhancement opsional pada rilis mendatang bila tersedia relay server.
- **Permission:** `SCHEDULE_EXACT_ALARM` (Android 12+, tanpa `USE_EXACT_ALARM`), `INTERNET` (untuk Google Login & Delta Sync), `POST_NOTIFICATIONS`, `USE_FULL_SCREEN_INTENT`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, dan `ACCESS_NOTIFICATION_POLICY`.

### Notification Channel Tembus Silent
- **Channel ID:** `ingatobat_alarm`
- **Config:** importance max, sound alarm stream (`AudioAttributes.USAGE_ALARM`), `bypassDnd=true`, `fullScreenIntent`, vibration, aksi: Sudah Minum / Tunda 10 / Lewati.
- **Permission:** `POST_NOTIFICATIONS` (Android 13+), `USE_FULL_SCREEN_INTENT` (Android 14+, deklarasi Play), `ACCESS_NOTIFICATION_POLICY` untuk DND access.

### Battery & OEM
- Panduan manual ke Settings baterai (tanpa `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` langsung agar patuh kebijakan Play, kecuali justifikasi diterima).
- Uji Samsung, Xiaomi (Autostart), Oppo/Vivo (Background manager).

## Permissions & Security

| Permission | Level | Keterangan |
|:---|:---|:---|
| POST_NOTIFICATIONS | dangerous | Wajib Android 13+, minta saat onboarding. |
| SCHEDULE_EXACT_ALARM | special | Wajib; arahkan ke Settings bila ditolak. |
| USE_FULL_SCREEN_INTENT | special | Deklarasi Play + justifikasi pengingat obat. |
| RECEIVE_BOOT_COMPLETED | normal | Reschedule reboot. |
| VIBRATE | normal | Getar alarm. |
| TTS engine | normal | Suara sistem offline, tanpa data keluar. |
| PDF share | normal | File PDF lokal via share sheet. |
| ACCESS_NOTIFICATION_POLICY | special | DND access untuk bypassDnd. |

## Firestore Security Rules & Merge Policy

**Rules (ringkas, diterapkan di `firestore.rules`):**
- `isMember(familyId)` = `exists(/databases/$(database)/documents/family_groups/$(familyId)/access/$(request.auth.token.email.lower()))`.
- Read & write data operasional keluarga (`members`, `medicines`, `schedules`, `dose_logs`, `stock_ledger`, `control_visits`, `side_effects`): hanya `isMember(familyId)`.
- Write `access/*`, `family_groups/*`: hanya `isAdmin(familyId)` (anggota tidak boleh menaikkan role sendiri).
- `email_index/{email}`: read hanya oleh pemilik email (`request.auth.token.email.lower() == email`); write hanya admin grup terkait.
- Hapus akun: user boleh menghapus `access/{email}` & `email_index/{email}` miliknya; pemilik (`owner_email`) boleh menghapus dokumen grup.

**Merge Policy (ringkas):** resolusi konflik memakai `server_updated_at` (fallback `updated_at`); soft delete monoton; status `dose_log` memakai presedensi terminal (`taken` > `skipped` > `missed`, `snooze_count` = max, `effective_scheduled_at` = terbaru non-terminal); decrement stok dijaga flag `stock_applied`. Detail lengkap di ARCHITECTURE.md.

## Error Handling & Rate Limiting

- Validasi di Dart + SQLite constraint; error validasi tampil inline Bahasa Indonesia.
- Debounce aksi notifikasi 1 detik agar tidak dobel log.
- Snooze dibatasi 5x per dosis untuk hindari loop.

## File & Foto

| Tipe | Max | Format | Path |
|:---|:---|:---|:---|
| Foto obat/Avatar | 5MB input, simpan ~300KB | JPG | app-private `/medicines/`, `/members/` |
| Backup zip | 100MB | ZIP tanpa enkripsi | Storage Access Framework picker |
