# ROADMAP.md: IngatObat

## Strategi Rilis (Phasing)

Rilis dipecah agar keandalan alarm tervalidasi lebih dulu sebelum menambah kompleksitas sinkronisasi keluarga:

- **v1.0 — Offline-First:** FR-01 s/d FR-17 (dipakai penuh tanpa login). Fokus: alarm tembus silent yang andal di banyak OEM.
- **v1.1 — Family Sync:** FR-18 & FR-19 (Login Google, Invite Email, Delta Sync, Per-Device Alarm Routing).

## Phased Delivery Plan

| Phase | Duration | Goals | Key Deliverables |
|:---|:---|:---|:---|
| **Phase 1: Fondasi + Anggota/Obat (UUID) + Aksesibilitas** | 2 minggu | Setup Flutter, SQLite UUID, foto privat + WebP `<20KB`, tema lansia. | Struktur repo (UUID PK), `MEMBER` + `MEDICINE` CRUD (*soft delete* + `dose_qty` fleksibel) + foto privat (`FR-01`, `FR-02`), pengaturan skala font S/M/L/XL, tombol 48/64dp, & kontras tinggi (`FR-13`). |
| **Phase 2: Jadwal + Alarm Tembus Silent + TTS & Eskalasi** | 3 minggu | Alarm exact + full-screen + TTS + eskalasi + reboot. | `SCHEDULE` fleksibel harian/mingguan/interval (`FR-03`), `AlarmManager` + `AlarmForegroundService`, channel `USAGE_ALARM`, *Grouped Full-Screen Intent* (`FR-04`), Native TTS `id-ID` (`FR-11`), rantai eskalasi 5m×6 + batas absolut 90 menit (`FR-12`), `BootReceiver`. |
| **Phase 3: Aksi + Riwayat + Stok + Efek Samping** | 2 minggu | Loop minum, koreksi log, stok fleksibel. | Aksi cepat + *Konfirmasi Semua* (`FR-05`), `DOSE_LOG` + koreksi/undo status (`FR-06`), stok bulat/desimal + `STOCK_LEDGER` (`FR-07`), efek samping (`FR-15`). |
| **Phase 4: Laporan + PDF + Kontrol RS + Widget + Auto-Backup** | 2 minggu | Nilai tambah keluarga, laporan dokter, & widget. | Laporan kepatuhan CSV (`FR-08`) & PDF offline (`FR-16`), `CONTROL_VISIT` H-2/H-1 Hari 08:00 + edge case (`FR-09`), Widget Home (`FR-14`), pengaturan izin, & backup lokal/otomatis mingguan SAF (`FR-10`, `FR-17`). |
| **Phase 5: v1.0 Hardening + Closed Test** | 2 minggu | Buktikan keandalan alarm sebelum menambah sync. | Uji alarm 7 hari di Samsung/Xiaomi/Oppo, perbaikan OEM, **rilis v1.0 ke Closed Testing (12 tester 14 hari)**, kunci kontrak skema v1. |
| **Phase 6: v1.1 Family Sync** | 3–4 minggu | Login Google, Invite Email, Delta Sync, routing per HP. | Firebase Auth (Google Sign-In) + `FAMILY_GROUP`/`access`/`email_index`, Invite/Revoke/Leave (`FR-18`), **Firestore Security Rules + Emulator test**, `FirestoreSyncEngine` + **Merge Policy** + bootstrap 90 hari, **Firestore Realtime Listener** (stop alarm), `WorkManager` reconcile, `DEVICE_MEMBER_PREF` + `DEVICE` (`FR-19`), hapus akun cloud. |
| **Phase 7: Play Store + Poles Multi-OEM** | 2 minggu | Lolos review & stabil di HP target. | AAB `targetSdk 35` (16KB page size), Data Safety, Account Deletion URL, privacy policy, video demo justifikasi izin, verifikasi FGS type, closed testing lanjutan, produksi bertahap. |

**Timeline Disclaimer:** Asumsi 1 developer Flutter full-time. Total estimasi ±16–18 minggu. Uji fisik di minimal 3 merek HP (Samsung, Xiaomi, Oppo). Uji sinkronisasi antar-2 HP keluarga di akhir Phase 6.

---

## MVP Feature List — v1.0 (Offline-First)

### P0: Must Have for v1.0 (FR-01 s/d FR-17)

| Feature | Reference | Status | Notes |
|:---|:---|:---|:---|
| Profil anggota (UUID) | FR-01 | Core | CRUD + *soft delete* (`is_archived`) + hitung hari ini. |
| Obat + foto + thumbnail `<20KB` | FR-02 | Core | `dose_qty` (bulat/desimal) + foto privat + WebP mikro. |
| Jadwal fleksibel | FR-03 | Core | Harian/mingguan/interval (`anchor_time`, aturan *day-clamped*). |
| Alarm tembus silent & *Grouped Alarm* | FR-04 | Core | Exact + FSI gabungan + `bypassDnd` + aturan aksi per kartu. |
| Aksi cepat | FR-05 | Core | Sudah (satuan/semua) / Tunda (maks 5x, batas 90 menit) / Lewati. |
| Riwayat & koreksi status | FR-06 | Core | Filter + missed otomatis (+30m pasca trigger aktif) + *undo*/ubah status. |
| Stok fleksibel + beli ulang | FR-07 | Core | Decrement `dose_qty` (`REAL`) + `STOCK_LEDGER` + ambang stok menipis. |
| Laporan kepatuhan | FR-08 | Core | Bar + CSV lokal (sumber data PDF). |
| Kontrol RS | FR-09 | Core | Pengingat H-2 Hari (08:00) & H-1 Hari (08:00) + skip reminder lampau. |
| Pengaturan + izin + backup | FR-10 | Core | Status izin + tes alarm + export/import ZIP. PIN **di luar scope v1.0**. |
| Pengumuman suara TTS | FR-11 | Core | Native TTS `id-ID` offline per jadwal + fallback nada. |
| Eskalasi alarm | FR-12 | Core | Rantai exact alarm 5 menit × 6 (volume 60%→100%) + batas absolut 90 menit. |
| Aksesibilitas fleksibel | FR-13 | Core | Skala font S/M/L/XL, tombol 48/64dp, kontras tinggi global. |
| Widget home | FR-14 | Core | Agenda 5 terdekat + refresh 30 menit. |
| Efek samping | FR-15 | Core | Log `kind`/`custom_kind`/`severity` per obat per anggota. |
| Laporan PDF | FR-16 | Core | PDF offline (kepatuhan + efek samping + kontrol RS) + share. |
| Backup otomatis | FR-17 | Core | Mingguan via SAF (`takePersistableUriPermission`) + retensi 4. |

## MVP Feature List — v1.1 (Family Sync)

### P0: Must Have for v1.1 (FR-18, FR-19)

| Feature | Reference | Status | Notes |
|:---|:---|:---|:---|
| Login Google & Invite Email Keluarga | FR-18 | Core | Auto-sync jadwal & log lintas HP (**Zero-Bill / Rp 0**, tanpa FCM/Cloud Functions). |
| Firestore Security Rules + Emulator | FR-18 | Core | Verifikasi `access/{email}` per `family_id`; invite/revoke khusus admin. |
| Merge Policy + bootstrap 90 hari | FR-18 | Core | `server_updated_at` arbiter; `stock_applied` guard; hemat kuota Spark. |
| Realtime Listener (stop alarm) + WorkManager | FR-18 | Core | Stop alarm saat online; reconcile ≥15 menit saat app tidak aktif. |
| Revoke access / Leave family / Hapus akun cloud | FR-18 | Core | Play compliance + kontrol privasi. |
| Pengaturan Bunyi Alarm per HP | FR-19 | Core | `full_alarm` (di rumah) vs `monitor_only` (di kantor); default `monitor_only` untuk anggota baru. |

## P1: Should Have Within 1 Month Post-Launch

| Feature | Reference | Status | Notes |
|:---|:---|:---|:---|
| PIN / Biometrik aplikasi | FR-10 (Opsional) | Enhancement | Kunci pembuka aplikasi (backup tetap tanpa enkripsi). |
| Panduan interaktif OEM lanjutan | NFR | Enhancement | Deteksi merek otomatis + deep-link Autostart Xiaomi/Oppo/Vivo. |
| Pengingat tambahan jam H-2 kunjungan RS | FR-09 (Enhancement) | Enhancement | Opsi pengingat tambahan 2 jam sebelum jam poli RS pada hari-H. |
| FCM sebagai enhancement opsional | FR-18 | Enhancement | Hanya bila tersedia relay server (di luar Zero-Bill) untuk notifikasi pantau real-time saat app mati. |

## P2: Nice to Have for Future Releases

- Tema gelap otomatis mengikuti sistem (di luar mode kontras tinggi).
- Multi-bahasa daerah (Jawa/Sunda) untuk antarmuka dan rekaman suara kustom.

## Milestones

- M1 (minggu 2): CRUD anggota/obat (*soft delete* + `dose_qty`) & aksesibilitas font/kontras jalan offline.
- M2 (minggu 5): Alarm tembus silent + *Grouped Alarm* + TTS + eskalasi 5m×6 + reboot jalan di 3 HP.
- M3 (minggu 7): Loop minum, koreksi status riwayat, stok fleksibel + ledger, dan catatan efek samping stabil.
- M4 (minggu 9): Laporan CSV/PDF, Kontrol RS (H-2/H-1 Hari), Widget Home, dan Auto-Backup SAF selesai.
- M5 (minggu 11): v1.0 masuk Closed Testing.
- M6 (minggu 15): Family Sync (FR-18/19) + Security Rules teruji.
- M7 (minggu 17): Produksi 20% → 100%.

## Dependencies

- Eksternal: akun Play Console, URL privacy policy, 12 tester, project Firebase (Spark).
- Internal: HP fisik multi-OEM, kabel USB debugging, kunci upload.

## Risks & Mitigation

- Alarm dibunuh OEM → panduan + uji + `AlarmForegroundService` + fallback high-priority.
- Penolakan izin Play → gunakan `SCHEDULE_EXACT_ALARM` (bukan `USE_EXACT_ALARM`) + video demo + justifikasi.
- FGS `mediaPlayback` ditolak → siapkan fallback `specialUse` (`FR-19`/medication reminder) sejak Phase 2.
- Data hilang update → migrasi + backup pra-migrasi.
- Jadwal jebol karena MVP terlalu gemuk → mitigasi utama adalah pemecahan v1.0/v1.1 di atas.

## Technical Milestones per Phase

- P1: drift v1 (dengan *soft delete* & `REAL` stock) + repo tested + tema aksesibilitas.
- P2: exact alarm + FSI gabungan + native TTS service + escalation chain (batas 90 menit) + boot receiver tested.
- P3: transaksi `confirmTaken` (guard `stock_applied`), `updateStatus`, dan `STOCK_LEDGER` tested.
- P4: laporan query < 500ms, generate PDF < 5 detik, widget home & auto-backup SAF tested.
- P5: Vitals crash-free > 99% selama closed test 14 hari (v1.0).
- P6: Firestore Rules Emulator lulus (member/admin/deny), merge policy teruji dengan simulasi 2 HP offline. ✅ **Implementasi kode selesai** (`firestore.rules`, `FirestoreSyncEngine` + Merge Policy terekstraksi di `merge_policy.dart`, `FirestoreFamilySyncService`, bootstrap 90 hari, listener realtime + `RealtimeAlarmWatcher`, `DEVICE`). Merge Policy sudah **teruji unit** (`test/merge_policy_test.dart`). Uji emulator menyusul saat project Firebase tersedia.

## Success Criteria & Go-Live Checklist

- [ ] Alarm fire rate > 98% selama 7 hari uji (termasuk *Grouped Alarm* & TTS).
- [ ] Closed test 14 hari tanpa crash mayor.
- [ ] Data Safety + privacy policy terisi.
- [ ] Security Rules lulus emulator (deny by default). *(`firestore.rules` + `firebase.json` siap; jalankan `firebase emulators:start --only firestore`)*
- [ ] Screenshot + icon + feature graphic siap.
- [ ] Rollout 20% 3 hari tanpa lonjakan crash.

## Post-Launch Roadmap

- **v1.1:** Family Sync (FR-18/19) + Security Rules.
- **v1.2:** Kunci aplikasi PIN/Biometrik + panduan deep-link OEM diperluas + grafik tren kepatuhan tahunan.
- **v1.3:** Tema gelap otomatis + rekaman suara keluarga kustom untuk alarm (mis. suara anak mengingatkan Ibu).
- **v1.4:** Dukungan Bahasa Daerah (Jawa/Sunda) + ekspor riwayat lengkap ke `.xlsx` + (opsional) FCM bila relay server tersedia.

## Resource Allocation

- 1 Flutter dev (100%), 1 QA keluarga (part-time untuk uji alarm nyata serumah).

## Communication & Governance

- Demo mingguan ke keluarga (user nyata); kanal bug via grup chat; definisi selesai = alarm terbukti bunyi di HP target.
