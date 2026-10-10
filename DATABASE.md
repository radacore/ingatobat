# DATABASE.md: IngatObat

## Entity Relationship Diagram

```mermaid
erDiagram
    FAMILY_GROUP ||--o{ FAMILY_MEMBER_ACCESS : invites
    FAMILY_GROUP ||--o{ MEMBER : syncs
    FAMILY_GROUP ||--o{ DEVICE : has
    MEMBER ||--o{ MEDICINE : owns
    MEMBER ||--o{ SCHEDULE : has
    MEMBER ||--o{ DOSE_LOG : logs
    MEMBER ||--o{ CONTROL_VISIT : visits
    MEMBER ||--o{ SIDE_EFFECT : reports
    MEMBER ||--o{ DEVICE_MEMBER_PREF : routes_alarm
    MEDICINE ||--o{ SIDE_EFFECT : causes
    MEDICINE ||--o{ SCHEDULE : scheduled
    MEDICINE ||--o{ DOSE_LOG : taken
    MEDICINE ||--o{ STOCK_LEDGER : tracks
    SCHEDULE ||--o{ DOSE_LOG : triggers
    DOSE_LOG ||--o| STOCK_LEDGER : applies

    FAMILY_GROUP {
        string id PK
        string name
        string owner_email
        timestamp created_at
        timestamp updated_at
        timestamp server_updated_at
    }

    FAMILY_MEMBER_ACCESS {
        string id PK
        string family_id FK
        string email
        string role
        string status
        timestamp joined_at
        timestamp updated_at
        timestamp server_updated_at
    }

    DEVICE {
        string id PK
        string family_id FK
        string email
        string fcm_token
        string platform
        timestamp last_seen_at
    }

    EMAIL_INDEX {
        string email PK
        string family_id
        string status
    }

    DEVICE_MEMBER_PREF {
        string member_id PK_FK
        string alarm_mode
        timestamp updated_at
    }

    MEMBER {
        string id PK
        string family_id FK
        string name
        string avatar_path
        text avatar_thumb_b64
        text notes
        boolean is_archived
        timestamp deleted_at
        timestamp created_at
        timestamp updated_at
        timestamp server_updated_at
    }

    MEDICINE {
        string id PK
        string family_id FK
        string member_id FK
        string name
        string dosage
        real dose_qty
        string unit
        string meal_relation
        string photo_path
        text photo_thumb_b64
        real stock_qty
        real low_stock_threshold
        text notes
        boolean is_archived
        timestamp deleted_at
        timestamp created_at
        timestamp updated_at
        timestamp server_updated_at
    }

    STOCK_LEDGER {
        string id PK
        string family_id FK
        string medicine_id FK
        string dose_log_id FK
        real delta
        real balance_after
        string reason
        timestamp created_at
        timestamp server_updated_at
    }

    SCHEDULE {
        string id PK
        string family_id FK
        string member_id FK
        string medicine_id FK
        string recurrence_type
        text times_json
        int interval_hours
        text days_of_week
        real dose_qty
        string meal_relation
        boolean tts_enabled
        timestamp start_date
        timestamp end_date
        boolean is_active
        timestamp created_at
        timestamp updated_at
        timestamp server_updated_at
    }

    DOSE_LOG {
        string id PK
        string family_id FK
        string schedule_id FK
        string member_id FK
        string medicine_id FK
        timestamp scheduled_at
        timestamp effective_scheduled_at
        int snooze_count
        string status
        boolean stock_applied
        string action_by_email
        timestamp action_at
        text note
        timestamp updated_at
        timestamp server_updated_at
    }

    CONTROL_VISIT {
        string id PK
        string family_id FK
        string member_id FK
        string hospital
        string doctor
        timestamp visit_at
        timestamp reminder_h2_at
        timestamp reminder_h1_at
        string status
        text notes
        timestamp updated_at
        timestamp server_updated_at
    }

    SETTING {
        int id PK
        string setting_key
        text setting_value
    }

    SIDE_EFFECT {
        string id PK
        string family_id FK
        string member_id FK
        string medicine_id FK
        timestamp occurred_at
        string kind
        string custom_kind
        string severity
        text note
        timestamp updated_at
        timestamp server_updated_at
    }
```

## Kolom Sinkronisasi Wajib (Semua Tabel Ter-sync)

Setiap tabel yang disinkronkan ke Firestore (`family_groups`, `family_member_access`, `members`, `medicines`, `schedules`, `dose_logs`, `stock_ledger`, `control_visits`, `side_effects`) **MUST** memiliki:

- `updated_at` — epoch ms dari jam klien (kunci delta sync & fallback ordering).
- `server_updated_at` — epoch ms dari `serverTimestamp()` Firestore, **nullable** (terisi saat dokumen berhasil ditulis online). Ini arbiter utama resolusi konflik (lihat Merge Policy di ARCHITECTURE.md). Baris yang belum pernah online memakai `updated_at` sebagai fallback.

Tabel lokal murni (`device_member_pref`, `setting`) tidak disinkronkan dan tidak memerlukan `server_updated_at`.

## Table Definitions

### FAMILY_GROUP
Grup keluarga untuk sinkronisasi lintas HP (dibuat otomatis saat Admin *Login with Google*).

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4) | Identitas unik grup keluarga |
| name | TEXT | NOT NULL | Nama keluarga (mis. "Keluarga Ibu Siti") |
| owner_email | TEXT | NOT NULL | Email Google pembuat grup (Admin) |
| created_at | INTEGER | NOT NULL | Epoch ms |
| updated_at | INTEGER | NOT NULL | Epoch ms |
| server_updated_at | INTEGER | NULLABLE | Epoch ms dari server Firestore |

### FAMILY_MEMBER_ACCESS
Daftar email Google anggota keluarga yang diundang (`Invite by Email`). Di Firestore direpresentasikan sebagai subcollection `family_groups/{familyId}/access/{emailLowercased}`.

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4) | Identitas unik akses |
| family_id | TEXT | FK (FAMILY_GROUP.id), NOT NULL | Grup keluarga |
| email | TEXT | NOT NULL, INDEX | Email Google anggota yang diundang (lowercase) |
| role | TEXT | DEFAULT 'member', NOT NULL | `admin` (pemilik) / `member` (keluarga terundang) |
| status | TEXT | DEFAULT 'invited', NOT NULL | `invited` (menunggu login) / `joined` (aktif sinkron) |
| joined_at | INTEGER | NULLABLE | Waktu pertama kali bergabung (epoch ms) |
| updated_at | INTEGER | NOT NULL | Epoch ms |
| server_updated_at | INTEGER | NULLABLE | Epoch ms dari server Firestore |

> **Catatan:** `fcm_token` **dipindahkan** ke tabel `DEVICE` (lihat di bawah) agar satu email dapat memiliki banyak perangkat tanpa saling menimpa token.

### DEVICE
Perangkat yang login ke grup keluarga. Memisahkan token FCM dari email agar mendukung **banyak HP per akun** (HP + tablet, dsb).

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4, dibuat per instalasi) | Identitas perangkat |
| family_id | TEXT | FK (FAMILY_GROUP.id), NOT NULL | Grup keluarga |
| email | TEXT | NOT NULL, INDEX | Email pemilik perangkat |
| fcm_token | TEXT | NULLABLE | Token FCM perangkat. **Tidak dipakai di v1.0** (FCM di luar jalur kritis); disimpan untuk enhancement mendatang. |
| platform | TEXT | DEFAULT 'android' | Platform |
| last_seen_at | INTEGER | NOT NULL | Epoch ms sinkronisasi terakhir |

### EMAIL_INDEX (Koleksi Cloud, untuk Auto-Discover Undangan)
Koleksi cloud-only (`email_index/{emailLowercased}`) agar saat *Login with Google* aplikasi bisa menemukan undangan untuk email tersebut tanpa query lintas-grup yang tidak diizinkan rules.

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| email | TEXT | PK | Email Google (lowercase) |
| family_id | TEXT | NOT NULL | Grup yang mengundang email ini |
| status | TEXT | NOT NULL | `invited` / `joined` |

### DEVICE_MEMBER_PREF (Lokal per HP)
Tabel lokal (tidak disinkronkan ke cloud) untuk mengatur profil anggota mana yang membunyikan **Alarm Keras** di HP tersebut vs **Hanya Notifikasi Pantau** (`FR-19`).

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| member_id | TEXT | PK, FK (MEMBER.id) | Profil anggota keluarga |
| alarm_mode | TEXT | DEFAULT 'monitor_only', NOT NULL | `full_alarm` (bunyi keras tembus silent + FSI) atau `monitor_only` (hanya notifikasi pantau). Default `monitor_only` untuk anggota baru (lihat FR-19). |
| updated_at | INTEGER | NOT NULL | Epoch ms |

### MEMBER
Menyimpan profil anggota rumah (menggunakan UUID v4 agar bebas bentrok saat dibuat offline di beberapa HP).

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4) | Identitas unik lintas perangkat |
| family_id | TEXT | NULLABLE | Null jika mode offline lokal; terisi saat terhubung keluarga |
| name | TEXT | NOT NULL | Nama anggota (mis. Ibu, Adik) |
| avatar_path | TEXT | NULLABLE | Path foto privat lokal |
| avatar_thumb_b64 | TEXT | NULLABLE | Thumbnail mikro WebP `< 20 KB` (Base64) untuk sinkronisasi gratis |
| notes | TEXT | NULLABLE | Alergi/catatan |
| is_archived | INTEGER | DEFAULT 0, NOT NULL | 0 aktif, 1 diarsipkan (*soft delete*) |
| deleted_at | INTEGER | NULLABLE | Waktu *soft delete* (epoch ms) |
| created_at | INTEGER | NOT NULL | Epoch ms |
| updated_at | INTEGER | NOT NULL | Epoch ms (kunci *Delta Sync*) |
| server_updated_at | INTEGER | NULLABLE | Epoch ms dari server Firestore |

### MEDICINE
Obat milik satu anggota, termasuk foto lokal, thumbnail sinkronisasi mikro (`< 20 KB`), takaran sekali minum (`dose_qty`), dan stok fleksibel.

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4) | Identitas unik lintas perangkat |
| family_id | TEXT | NULLABLE | ID grup keluarga |
| member_id | TEXT | FK (MEMBER.id) ON DELETE RESTRICT, NOT NULL | Pemilik obat |
| name | TEXT | NOT NULL | Nama obat |
| dosage | TEXT | NOT NULL | Kekuatan sediaan (mis. 500mg, 5mg/5ml) |
| dose_qty | REAL | DEFAULT 1.0, NOT NULL | Takaran per sekali minum (mis. `1` tablet, `0.5` tablet, `5` ml) |
| unit | TEXT | NOT NULL | tablet/kapsul/ml/tetes/bungkus |
| meal_relation | TEXT | DEFAULT 'none' | none/before/after |
| photo_path | TEXT | NULLABLE | Path foto resolusi penuh di storage privat lokal |
| photo_thumb_b64 | TEXT | NULLABLE | Thumbnail mikro WebP `< 20 KB` (Base64) agar semua HP keluarga melihat foto obat tanpa biaya Cloud Storage |
| stock_qty | REAL | DEFAULT 0.0, NOT NULL | Sisa stok (mendukung bulat & desimal). Dijaga konsisten dengan `STOCK_LEDGER`. |
| low_stock_threshold | REAL | DEFAULT 3.0, NOT NULL | Ambang beli ulang |
| notes | TEXT | NULLABLE | Aturan pakai tambahan |
| is_archived | INTEGER | DEFAULT 0, NOT NULL | 0 aktif, 1 diarsipkan (*soft delete*) |
| deleted_at | INTEGER | NULLABLE | Waktu *soft delete* (epoch ms) |
| created_at | INTEGER | NOT NULL | Epoch ms |
| updated_at | INTEGER | NOT NULL | Epoch ms (kunci *Delta Sync*) |
| server_updated_at | INTEGER | NULLABLE | Epoch ms dari server Firestore |

### STOCK_LEDGER
Ledger audit setiap perubahan stok obat (`FR-07`). `stock_qty` pada `MEDICINE` adalah nilai turunan yang harus selalu sama dengan saldo ledger.

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4) | Identitas baris ledger |
| family_id | TEXT | NULLABLE | ID grup keluarga |
| medicine_id | TEXT | FK (MEDICINE.id) ON DELETE RESTRICT, NOT NULL | Obat terkait |
| dose_log_id | TEXT | FK (DOSE_LOG.id) ON DELETE SET NULL, NULLABLE | Diisi bila perubahan berasal dari konfirmasi minum/koreksi status |
| delta | REAL | NOT NULL | Perubahan stok (negatif saat diminum, positif saat restock) |
| balance_after | REAL | NOT NULL | Saldo stok setelah perubahan (untuk rekonsiliasi) |
| reason | TEXT | NOT NULL | `taken` / `restock` / `correction` / `adjustment` |
| created_at | INTEGER | NOT NULL | Epoch ms |
| server_updated_at | INTEGER | NULLABLE | Epoch ms dari server Firestore |

### SCHEDULE
Jadwal fleksibel per obat.

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4) | Identitas unik lintas perangkat |
| family_id | TEXT | NULLABLE | ID grup keluarga |
| member_id | TEXT | FK (MEMBER.id), NOT NULL | Denormalisasi untuk query cepat |
| medicine_id | TEXT | FK (MEDICINE.id) ON DELETE RESTRICT, NOT NULL | Obat terjadwal |
| recurrence_type | TEXT | NOT NULL | daily/weekly/interval |
| times_json | TEXT | NOT NULL | JSON `["08:00","20:00"]` untuk daily/weekly, atau jam awal (`anchor_time`) `["06:00"]` untuk interval |
| interval_hours | INTEGER | NULLABLE | Mis. `8` untuk tiap 8 jam (wajib bila `recurrence_type='interval'`) |
| days_of_week | TEXT | NULLABLE | JSON `[1,3,5]` Senin=1 s/d Minggu=7 |
| dose_qty | REAL | NULLABLE | Override takaran minum khusus jadwal ini (null = pakai `MEDICINE.dose_qty`) |
| meal_relation | TEXT | NULLABLE | Override aturan makan per jadwal |
| tts_enabled | INTEGER | DEFAULT 1, NOT NULL | 1 aktifkan suara TTS, 0 hanya nada alarm (FR-11) |
| start_date | INTEGER | NOT NULL | Epoch **ms** (tengah malam lokal hari mulai) |
| end_date | INTEGER | NULLABLE | Epoch ms; Null = tanpa akhir |
| is_active | INTEGER | DEFAULT 1, NOT NULL | 1 aktif, 0 nonaktif |
| created_at | INTEGER | NOT NULL | Epoch ms |
| updated_at | INTEGER | NOT NULL | Epoch ms (kunci *Delta Sync*) |
| server_updated_at | INTEGER | NULLABLE | Epoch ms dari server Firestore |

> **Catatan interval:** ekspansi dosis memakai aturan *day-clamped* (lihat REQUIREMENTS.md FR-03) — dosis hanya dijadwalkan pada hari kalender `anchor_time` yang sama, lalu diulang dari `anchor_time` hari berikutnya.

### DOSE_LOG
Tiap kejadian minum terjadwal dan aktual, dilengkapi *Unique Constraint* `(schedule_id, scheduled_at)` agar tidak pernah terjadi pengurangan stok ganda antar-HP.

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4) | Identitas unik deterministik `uuid5(schedule_id + scheduled_at)` |
| family_id | TEXT | NULLABLE | ID grup keluarga |
| schedule_id | TEXT | FK (SCHEDULE.id) ON DELETE SET NULL, NULLABLE | Pemicu jadwal |
| member_id | TEXT | FK (MEMBER.id) ON DELETE RESTRICT, NOT NULL | Anggota |
| medicine_id | TEXT | FK (MEDICINE.id) ON DELETE RESTRICT, NOT NULL | Obat |
| scheduled_at | INTEGER | NOT NULL | Waktu terjadwal asli (epoch ms) |
| effective_scheduled_at | INTEGER | NOT NULL | Waktu trigger aktif terakhir (dasar hitung +30 mnt `missed`) |
| snooze_count | INTEGER | DEFAULT 0, NOT NULL | Jumlah tunda (maks 5x per dosis) |
| status | TEXT | NOT NULL | pending/taken/snoozed/skipped/missed |
| stock_applied | INTEGER | DEFAULT 0, NOT NULL | 1 = `dose_qty` sudah dipotong dari stok (guard anti double-decrement) |
| action_by_email | TEXT | NULLABLE | Email anggota keluarga yang menekan tombol aksi (mis. `ibu@gmail.com`) |
| action_at | INTEGER | NULLABLE | Waktu aksi user |
| note | TEXT | NULLABLE | Alasan lewati/tunda/koreksi |
| updated_at | INTEGER | NOT NULL | Epoch ms (kunci *Delta Sync*) |
| server_updated_at | INTEGER | NULLABLE | Epoch ms dari server Firestore |

### CONTROL_VISIT
Jadwal kontrol RS dengan pengingat H-2 Hari (08:00) dan H-1 Hari (08:00).

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4) | Identitas unik lintas perangkat |
| family_id | TEXT | NULLABLE | ID grup keluarga |
| member_id | TEXT | FK (MEMBER.id) ON DELETE RESTRICT, NOT NULL | Pasien |
| hospital | TEXT | NOT NULL | Nama RS/Klinik |
| doctor | TEXT | NULLABLE | Nama dokter |
| visit_at | INTEGER | NOT NULL | Waktu tanggal & jam kontrol (epoch ms) |
| reminder_h2_at | INTEGER | NULLABLE | Pengingat H-2 Hari pukul 08:00 (epoch ms); null bila sudah terlewat saat dibuat |
| reminder_h1_at | INTEGER | NULLABLE | Pengingat H-1 Hari pukul 08:00 (epoch ms); null bila sudah terlewat saat dibuat |
| status | TEXT | DEFAULT 'upcoming' | upcoming/done/cancelled |
| notes | TEXT | NULLABLE | Bawa kartu/berkas/puasa |
| updated_at | INTEGER | NOT NULL | Epoch ms (kunci *Delta Sync*) |
| server_updated_at | INTEGER | NULLABLE | Epoch ms dari server Firestore |

### SETTING
Pengaturan key-value global & status sinkronisasi lokal (`last_sync_at`, `current_user_email`, `current_family_id`).

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | INTEGER | PK, AUTOINCREMENT | Identitas unik lokal |
| setting_key | TEXT | UK, NOT NULL | Mis. `alarm_tone`, `snooze_default`, `tts_enabled`, `font_scale`, `last_sync_at`, `current_family_id` |
| setting_value | TEXT | NOT NULL | JSON/string value |

### SIDE_EFFECT
Catatan efek samping per obat per anggota (FR-15).

| Column | Type | Constraints | Description |
|:---|:---|:---|:---|
| id | TEXT | PK (UUID v4) | Identitas unik lintas perangkat |
| family_id | TEXT | NULLABLE | ID grup keluarga |
| member_id | TEXT | FK (MEMBER.id) ON DELETE RESTRICT, NOT NULL | Anggota |
| medicine_id | TEXT | FK (MEDICINE.id) ON DELETE RESTRICT, NOT NULL | Obat terkait |
| occurred_at | INTEGER | NOT NULL | Waktu kejadian epoch ms |
| kind | TEXT | NOT NULL | mual/pusing/gatal/kustom |
| custom_kind | TEXT | NULLABLE | Nama efek samping bila `kind = 'kustom'` |
| severity | TEXT | NOT NULL | ringan/sedang/berat |
| note | TEXT | NULLABLE | Catatan tambahan |
| updated_at | INTEGER | NOT NULL | Epoch ms (kunci *Delta Sync*) |
| server_updated_at | INTEGER | NULLABLE | Epoch ms dari server Firestore |

## Schema (drift untuk SQLite & Mirror Dokumen Cloud Firestore)

```dart
// drift tables (UUID Primary Keys untuk sinkronisasi multi-device)
class FamilyGroups extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get name => text()();
  TextColumn get ownerEmail => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class FamilyMemberAccesses extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get familyId => text().references(FamilyGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get email => text()();
  TextColumn get role => text().withDefault(const Constant('member'))();
  TextColumn get status => text().withDefault(const Constant('invited'))();
  IntColumn get joinedAt => integer().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class Devices extends Table {
  TextColumn get id => text()(); // UUID v4 per instalasi
  TextColumn get familyId => text().references(FamilyGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get email => text()();
  TextColumn get fcmToken => text().nullable()(); // tidak dipakai di v1.0
  TextColumn get platform => text().withDefault(const Constant('android'))();
  IntColumn get lastSeenAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class DeviceMemberPrefs extends Table {
  TextColumn get memberId => text().references(Members, #id, onDelete: KeyAction.cascade)();
  TextColumn get alarmMode => text().withDefault(const Constant('monitor_only'))(); // full_alarm / monitor_only
  IntColumn get updatedAt => integer()();
  @override
  Set<Column> get primaryKey => {memberId};
}

class Members extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get familyId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get avatarThumbB64 => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class Medicines extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text().references(Members, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  RealColumn get doseQty => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text()();
  TextColumn get mealRelation => text().withDefault(const Constant('none'))();
  TextColumn get photoPath => text().nullable()();
  TextColumn get photoThumbB64 => text().nullable()(); // <20KB WebP Base64
  RealColumn get stockQty => real().withDefault(const Constant(0.0))();
  RealColumn get lowStockThreshold => real().withDefault(const Constant(3.0))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class StockLedgers extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get familyId => text().nullable()();
  TextColumn get medicineId => text().references(Medicines, #id, onDelete: KeyAction.restrict)();
  TextColumn get doseLogId => text().nullable()();
  RealColumn get delta => real()();
  RealColumn get balanceAfter => real()();
  TextColumn get reason => text()(); // taken/restock/correction/adjustment
  IntColumn get createdAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class Schedules extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text().references(Members, #id, onDelete: KeyAction.restrict)();
  TextColumn get medicineId => text().references(Medicines, #id, onDelete: KeyAction.restrict)();
  TextColumn get recurrenceType => text()(); // daily/weekly/interval
  TextColumn get timesJson => text()();
  IntColumn get intervalHours => integer().nullable()();
  TextColumn get daysOfWeek => text().nullable()();
  RealColumn get doseQty => real().nullable()();
  TextColumn get mealRelation => text().nullable()();
  BoolColumn get ttsEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get startDate => integer()();
  IntColumn get endDate => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class DoseLogs extends Table {
  TextColumn get id => text()(); // UUID v5 deterministik dari (scheduleId, scheduledAt)
  TextColumn get familyId => text().nullable()();
  TextColumn get scheduleId => text().nullable().references(Schedules, #id, onDelete: KeyAction.setNull)();
  TextColumn get memberId => text().references(Members, #id, onDelete: KeyAction.restrict)();
  TextColumn get medicineId => text().references(Medicines, #id, onDelete: KeyAction.restrict)();
  IntColumn get scheduledAt => integer()();
  IntColumn get effectiveScheduledAt => integer()();
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()(); // pending/taken/snoozed/skipped/missed
  BoolColumn get stockApplied => boolean().withDefault(const Constant(false))();
  TextColumn get actionByEmail => text().nullable()();
  IntColumn get actionAt => integer().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [{scheduleId, scheduledAt}];
}

class ControlVisits extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text().references(Members, #id, onDelete: KeyAction.restrict)();
  TextColumn get hospital => text()();
  TextColumn get doctor => text().nullable()();
  IntColumn get visitAt => integer()();
  IntColumn get reminderH2At => integer().nullable()();
  IntColumn get reminderH1At => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('upcoming'))();
  TextColumn get notes => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class SideEffects extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text().references(Members, #id, onDelete: KeyAction.restrict)();
  TextColumn get medicineId => text().references(Medicines, #id, onDelete: KeyAction.restrict)();
  IntColumn get occurredAt => integer()();
  TextColumn get kind => text()(); // mual/pusing/gatal/kustom
  TextColumn get customKind => text().nullable()();
  TextColumn get severity => text()(); // ringan/sedang/berat
  TextColumn get note => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get serverUpdatedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}
```

## Database Indexing Strategy

| Table | Column(s) | Type | Purpose |
|:---|:---|:---|:---|
| dose_log | schedule_id, scheduled_at | Unique Composite | Mencegah duplikasi log & mencegah stok berkurang 2x antar-HP |
| dose_log | member_id, scheduled_at | Composite | Riwayat per anggota per tanggal |
| dose_log | status, effective_scheduled_at | Composite | Hitung missed/taken & eskalasi cepat |
| stock_ledger | medicine_id, created_at | Composite | Audit & rekonsiliasi stok |
| family_member_access | email, status | Composite | Auto-discover undangan keluarga saat *Login with Google* |
| device | email | Composite | Ambil token perangkat per akun (multi-HP) |
| all_synced_tables | family_id, server_updated_at | Composite | Query *Delta Sync* (`server_updated_at > last_sync_at`) super ringan |
| schedule | member_id, is_active | Composite | Agenda hari ini per anggota |
| medicine | member_id, is_archived | Composite | Obat aktif per anggota |

## Data Integrity & Constraints

- **Idempotent Multi-Device Sync (guard ganda):** `DOSE_LOG.id` dibentuk deterministik (`UUIDv5(schedule_id + scheduled_at)`) disertai *Unique Constraint* `(schedule_id, scheduled_at)` **dan** flag `stock_applied`. Decrement `stock_qty` hanya terjadi saat transaksi atomik mengubah `stock_applied: false → true`. Jika HP Ibu dan HP Adik menekan "Sudah Minum" bersamaan, hanya transisi pertama yang memotong stok dan menulis satu baris `STOCK_LEDGER`.
- **Soft Delete & Referential Integrity:** Menghapus `MEMBER` atau `MEDICINE` melakukan *Soft Delete* (`is_archived = 1`, `deleted_at = epoch_ms`), menonaktifkan semua `SCHEDULE` terkait (`is_active = 0`), dan menyinkronkan pembatalan alarm ke seluruh HP keluarga tanpa menghapus baris `DOSE_LOG`. Tabel data operasional (`members`, `medicines`, `schedules`, `dose_logs`, `stock_ledger`, `control_visits`, `side_effects`) memakai `ON DELETE RESTRICT`/`SET NULL` karena aplikasi memakai *soft delete* — **tidak ada `ON DELETE CASCADE`** pada tabel-tabel ini (mencegah data medis ikut terhapus permanen). `CASCADE` hanya dipakai untuk tabel turunan `FAMILY_GROUP` (`family_member_access`, `device`) yang memang harus hilang saat grup keluarga dihapus (Hapus Akun Cloud).
- **Soft delete monoton:** `is_archived = 1` tidak dapat dibatalkan oleh update dari HP lain (lihat Merge Policy di ARCHITECTURE.md).
- **Zero-Storage-Bill Thumbnails:** Foto obat resolusi penuh disimpan di penyimpanan lokal privat (dan opsional Google Drive `appDataFolder` milik user), sementara `photo_thumb_b64` menyimpan WebP mikro `< 20 KB` langsung di kolom teks agar langsung tampil di semua HP keluarga tanpa biaya Cloud Storage.

## Migration & Seeding

- Migrasi via drift MigrationStrategy dari v1 ke vN tanpa hapus data; backup otomatis sebelum migrasi mayor.
- Seeding awal: SETTING default (alarm_tone=system_alarm, snooze_default=10, dnd_guide_shown=false).

## Performance Considerations

- Query agenda hari ini memakai index member + is_active; paginasi riwayat 50 per halaman.
- Foto terkompresi; thumbnail 256px untuk list.
- VACUUM terjadwal setelah hapus massal.

## Security & Compliance

- DB di app-private directory, tanpa backup cloud otomatis.
- Foto tidak di shared storage; tidak perlu izin media.
- File backup zip berisi DB + foto sebelum dibagikan.
- Akses cloud dibatasi **Firestore Security Rules** per `family_id` dengan verifikasi `request.auth.token.email` terhadap subcollection `access/{email}` (lihat ARCHITECTURE.md).
