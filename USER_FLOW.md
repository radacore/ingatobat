# USER_FLOW.md: IngatObat

## Overview

Dokumen ini memuat alur utama **IngatObat** untuk peran Admin Pengelola yang mengelola jadwal serumah. Flow 1–12 fokus pada mode **Offline Lokal (satu HP, tanpa login)**, sedangkan **Flow 13–16** mencakup mode **Sinkronisasi Keluarga (Login with Google, multi-HP)**.

---

## Flow 1: Admin – Tambah Anggota Rumah

### Trigger
Admin ingin menambah profil adik/ibu ke aplikasi.

### Pre-conditions
- Aplikasi terinstal dan terbuka.
- Belum ada atau sudah ada anggota lain.

### Post-conditions
- Profil tersimpan di MEMBER dan muncul di Beranda.

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka tab Anggota, tap Tambah | Form nama + foto + catatan tampil | — |
| 2 | Admin | Isi nama wajib, pilih foto opsional | Preview foto terkompresi tampil | Jika nama kosong, tombol Simpan nonaktif |
| 3 | Admin | Tap Simpan | Validasi → insert `MEMBER` → toast sukses | Jika storage penuh, error `storage_full` |
| 4 | Admin | Kembali ke daftar | Anggota baru tampil dengan `today_count` 0 | Jika hapus anggota lama: lakukan *soft delete* (`is_archived=1`) & nonaktifkan jadwal agar histori laporan tetap utuh |

---

## Flow 2: Admin – Tambah Obat + Foto + Takaran Fleksibel (FR-02)

### Trigger
Admin menambah obat untuk Ibu beserta takaran minum (`dose_qty`) dan foto kemasan (FR-02).

### Pre-conditions
- Profil Ibu sudah ada.

### Post-conditions
- Obat tersimpan di `MEDICINE` dengan `dose_qty` fleksibel (bulat/desimal), foto privat, dan stok awal.

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka Obat, tap Tambah, pilih Ibu | Form obat tampil | Jika belum ada anggota, minta buat dulu |
| 2 | Admin | Isi nama, kekuatan dosis (`5mg`), takaran sekali minum (`dose_qty`, mis. `1` tablet, `0.5` tablet, atau `5` ml), satuan, aturan makan | Validasi inline jalan | Jika dosis/takaran kosong atau `<= 0`, error validasi |
| 3 | Admin | Ambil foto via kamera/galeri | Kompresi max 1280px, simpan privat, preview tampil | Jika batal, foto opsional dilewati |
| 4 | Admin | Isi stok awal (`stock_qty`) + ambang (`low_stock_threshold`), tap Simpan | Insert `MEDICINE` → toast sukses | Jika stok negatif, tolak |

---

## Flow 3: Admin – Buat Jadwal Fleksibel
### Trigger
Admin membuat jadwal Amlodipine tiap jam 08:00 dan 20:00.

### Pre-conditions
- Obat sudah ada dan aktif.

### Post-conditions
- `SCHEDULE` tersimpan (termasuk opsi `tts_enabled`) dan exact alarm terjadwal (FR-03, FR-04, FR-11).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka detail obat, tap Tambah Jadwal | Pilihan harian/mingguan/interval (`anchor_time`) + toggle TTS tampil | — |
| 2 | Admin | Pilih harian + jam 08:00, 20:00 + tanggal mulai | Preview ringkasan tampil | Jika jam duplikat, gabungkan otomatis |
| 3 | Admin | Tap Simpan | Validasi → insert → `scheduleExact` per jam | Jika izin exact alarm mati, tampil panduan + status pending |
| 4 | System | Kembalikan hasil | Tampil `alarms_scheduled=2` | Jika gagal, jadwal tetap tersimpan nonaktif sementara |

---

## Flow 4: Admin – Terima Alarm Tembus Silent (Tunggal / Gabungan) + Aksi Cepat

### Trigger
Jam 08:00 tiba walau HP silent/DND (bisa 1 obat atau beberapa obat/anggota serentak).

### Pre-conditions
- Jadwal aktif, izin exact + DND diberikan.

### Post-conditions
- `DOSE_LOG` tertulis sesuai aksi, stok berkurang sebesar `dose_qty` (FR-04, FR-05, FR-06, FR-12).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | System | `AlarmManager` fire → `AlarmForegroundService` | Tulis `pending` log, tampilkan Full-Screen Intent (otomatis menjadi *Grouped Alarm* bila >1 jadwal di jam 08:00) + suara `USAGE_ALARM` + Native TTS berurutan. Tiap kartu grup dikelola sebagai log independen; eskalasi berlanjut hanya selama masih ada kartu non-terminal | Jika DND mati izinnya, fallback high-priority |
| 2 | Admin | Lihat kartu obat (nama anggota + obat + dosis + takaran + foto) | Foto besar terbaca < 3 detik; tersedia tombol per obat & tombol "Konfirmasi Semua" | — |
| 3 | Admin | Tap Sudah Minum (atau Konfirmasi Semua) | Update `taken` + set `stock_applied = true` (guard `false → true`) + kurangi `stock_qty` sebesar `dose_qty` **tepat 1x** + tulis baris `STOCK_LEDGER` + batalkan eskalasi → toast | Jika tap ganda, debounce 1 detik; jika 2 HP konfirmasi bersamaan, hanya transisi pertama memotong stok |
| 4 | Admin | (Alt) Tap Tunda 5/10/15 mnt | `snooze_count++`, update `effective_scheduled_at = now + mnt`, reset rantai eskalasi 30 menit ke jadwal baru | Maks 5x snooze per dosis **dan** tidak boleh melampaui 90 menit sejak `scheduled_at` asli |
| 5 | Admin | (Alt) Tap Lewati + alasan | Status `skipped` + alasan tersimpan + batalkan eskalasi | Stok tidak berkurang |
| 6 | System | Tanpa aksi selama 6x eskalasi (30 menit sejak `effective_scheduled_at`) | Tandai `missed` otomatis dan hentikan alarm | **Batas absolut:** dosis dipaksa `missed` setelah 90 menit sejak `scheduled_at` asli walau masih tersisa kuota snooze |

---

## Flow 5: Admin – Lihat Riwayat & Koreksi / Undo Status

### Trigger
Admin cek siapa yang sudah/terlewat minum minggu ini, atau ingin mengoreksi status obat yang lupa dicatat / salah pencet.

### Pre-conditions
- Ada log terjadwal.

### Post-conditions
- Riwayat terfilter tampil dan status log beserta stok dapat dikoreksi secara akurat (FR-06).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka Riwayat, pilih anggota + rentang | Query paginasi 50 tampil | Jika kosong, empty state + CTA tambah jadwal |
| 2 | Admin | Filter status `missed` | Daftar `missed` + waktu terjadwal tampil | — |
| 3 | Admin | Tap satu entri → pilih "Ubah Status" (mis. dari `missed` ke `taken` atau sebaliknya) | Transaksi update status `DOSE_LOG` + sesuaikan `stock_qty` (`-dose_qty` bila jadi `taken`, `+dose_qty` bila batal `taken`) | Catat alasan koreksi di kolom `note` |

---

## Flow 6: Admin – Kelola Stok Fleksibel + Beli Ulang

### Trigger
Stok Amlodipine (tablet) atau Sirup Paracetamol (ml) menipis setelah banyak konfirmasi minum.

### Pre-conditions
- Obat punya `stock_qty`, `dose_qty`, dan `low_stock_threshold`.

### Post-conditions
- Daftar beli ulang + pengingat 09:00 muncul (FR-07).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | System | `stock_qty <= low_stock_threshold` setelah `taken` | Masuk daftar beli ulang + badge | — |
| 2 | Admin | Buka Beli Ulang | Daftar obat menipis per anggota tampil (mendukung angka bulat & desimal) | — |
| 3 | Admin | Tap Restock + isi `qty` | Stok bertambah + cap tanggal | Jika `qty <= 0`, tolak |

---

## Flow 7: Admin – Lihat Laporan Kepatuhan

### Trigger
Admin ingin tahu kepatuhan Ibu bulan ini.

### Pre-conditions
- Ada log dalam rentang.

### Post-conditions
- Rekap + persentase tampil, bisa bagikan CSV (FR-08).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka Laporan, pilih Ibu + bulan ini | Hitung terjadwal/taken/missed/skipped + pct | Jika data < 7 hari, tampil peringatan sampel kecil |
| 2 | Admin | Tap Bagikan | Generate CSV lokal via share sheet | Tanpa internet tetap bisa |

---

## Flow 8: Admin – Tambah Kontrol RS (Pengingat H-2 & H-1 Hari)

### Trigger
Admin mencatat kontrol Ibu ke RSUD minggu depan.

### Pre-conditions
- Profil Ibu ada.

### Post-conditions
- `CONTROL_VISIT` + 2 exact alarm (**H-2 Hari pukul 08:00** dan **H-1 Hari pukul 08:00**) terjadwal (FR-09).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka Kontrol, tap Tambah | Form RS + dokter + tanggal & jam kontrol tampil | — |
| 2 | Admin | Isi RSUD + tanggal + catatan | Auto-hitung jadwal pengingat **H-2 Hari (08:00)** dan **H-1 Hari (08:00)** tampil | Jika tanggal lampau, tolak |
| 3 | Admin | Tap Simpan | Insert + jadwalkan 2 exact alarm (H-2 Hari & H-1 Hari) | — |
| 4 | Admin | Tandai Selesai setelah kontrol | Alarm sisa dibatalkan | — |

---

## Flow 9: Admin – Atur Izin + Nada + Tes Alarm

### Trigger
Alarm tidak bunyi di HP baru Xiaomi.

### Pre-conditions
- Aplikasi terbuka.

### Post-conditions
- Izin lengkap dan tes suara terdengar (FR-10, FR-04).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka Pengaturan → Status Izin | Daftar notification/exact/DND/baterai + status tampil | — |
| 2 | Admin | Tap Minta Izin satu per satu | Deep link ke Settings sistem + panduan OEM | Jika ditolak, banner merah persisten |
| 3 | Admin | Pilih nada + tap Tes | Putar 5 detik via alarm stream | Jika silent tetap tak bunyi, sarankan cek DND access |
| 4 | Admin | Aktifkan panduan baterai | Tampilkan langkah Samsung/Xiaomi/Oppo | — |

---

## Flow 10: Admin – Backup dan Restore Lokal

### Trigger
Admin ganti HP dan ingin pindahkan data.

### Pre-conditions
- Ada data lokal.

### Post-conditions
- File zip backup valid dan bisa direstore (FR-10).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka Pengaturan → Backup | Estimasi ukuran + jadwal otomatis tampil | — |
| 2 | Admin | Tap Export + pilih folder via picker | Zip db + foto tersimpan | Jika ruang kurang, error |
| 3 | Admin | Aktifkan backup otomatis mingguan + pilih folder | WorkManager terjadwal Minggu 02:00, retensi 4 file | Jika folder dicabut, notifikasi perbaiki |
| 4 | Admin | Di HP baru tap Import + pilih file | Validasi versi skema → timpa + reschedule semua alarm | Jika versi tak cocok, tolak dengan pesan update dulu |

---

## Flow 11: Admin – Atur TTS, Eskalasi, dan Aksesibilitas

### Trigger
Admin ingin alarm bersuara menyebut nama dan tampilan lebih besar.

### Pre-conditions
- Ada jadwal aktif.

### Post-conditions
- FR-11 TTS, FR-12 eskalasi, FR-13 font/tombol/kontras tersimpan dan berlaku global.

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka Pengaturan → Suara | Toggle TTS + pilih bahasa id-ID + tombol Tes | Jika paket TTS hilang, fallback nada + info |
| 2 | Admin | Atur eskalasi (ulang 5 mnt, 6x, volume menanjak) | Preview pola tampil | Jika dimatikan, alarm bunyi sekali |
| 3 | Admin | Atur font S/M/L/XL + tombol standar/besar + kontras | Pratinjau langsung di semua layar termasuk alarm | Widget menyesuaikan (XL jadi 3 item) |
| 4 | Admin | Simpan | Berlaku instan tanpa restart | — |

---

## Flow 12: Admin – Efek Samping, PDF, dan Widget

### Trigger
Ibu mual setelah minum obat; admin ingin laporan PDF untuk dokter dan agenda di home screen.

### Pre-conditions
- Obat dan log kepatuhan ada.

### Post-conditions
- FR-15 efek samping, FR-16 PDF, FR-14 widget terpenuhi.

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka detail obat → Tambah Efek Samping | Form kind/severity/tanggal tampil | — |
| 2 | Admin | Isi mual + sedang + catatan, simpan | Masuk SIDE_EFFECT, tampil di riwayat obat | — |
| 3 | Admin | Buka Laporan → Export PDF | Generate offline (< 5 detik) berisi kepatuhan + efek samping + kontrol | Jika data kosong, PDF tetap dibuat dengan keterangan |
| 4 | Admin | Bagikan via share sheet | File PDF terkirim ke WA/drive | Tanpa internet tetap tersimpan lokal |
| 5 | Admin | Tambah widget IngatObat ke home | 5 agenda terdekat tampil, tap buka Hari Ini | Refresh 30 menit + tiap perubahan data |

---

## Flow 13: Kolaborasi Keluarga – Login with Google, Invite Email & Sinkronisasi Otomatis (FR-18, FR-19)

### Trigger
Anak (Admin di kantor) ingin mengatur jadwal obat Ibu dan mengundang email Google Ibu (`ibu@gmail.com`) agar HP Ibu di rumah otomatis berbunyi saat jam minum obat, sementara HP Anak di kantor menerima notifikasi pantau saat Ibu sudah minum.

### Pre-conditions
- Aplikasi terinstal di HP Anak (dan kemudian diinstal di HP Ibu).
- Aplikasi tetap bisa dipakai offline tanpa login sebelum langkah ini dilakukan.

### Post-conditions
- Grup keluarga (`FAMILY_GROUP`) terbentuk, data di HP Ibu otomatis sinkron begitu Ibu *Login with Google*, dan masing-masing HP memiliki preferensi bunyi alarm (`full_alarm` di HP Ibu vs `monitor_only` di HP Anak).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin (HP Anak) | Buka menu Keluarga & Sinkronisasi → tap "Login dengan Google" | Buat `FAMILY_GROUP` baru + unggah data anggota, obat (beserta thumbnail WebP `< 20 KB`), dan jadwal ke Cloud | Jika internet mati, tampilkan info coba lagi (alarm lokal tetap jalan) |
| 2 | Admin (HP Anak) | Ketik email Google Ibu (`ibu@gmail.com`) → tap "Undang Keluarga" | Simpan ke `access/{email}` (`status = 'invited'`) + `email_index/{email}` | Jika format email salah, tampilkan pesan validasi |
| 3 | Admin (HP Anak) | Di bagian "Bunyi Alarm di HP Ini", ubah profil Ibu menjadi **Mode Pantau (`monitor_only`)** | Simpan ke `DEVICE_MEMBER_PREF` lokal HP Anak (HP Anak tidak akan bunyi weker keras saat di kantor) | — |
| 4 | Ibu (HP Ibu) | Install IngatObat → tap "Login dengan Google" memakai `ibu@gmail.com` | `email_index` mendeteksi undangan aktif → otomatis gabung (`status = 'joined'`) → **bootstrap sync** (data referensi penuh + `DOSE_LOG` 90 hari terakhir) ke SQLite lokal HP Ibu | — |
| 5 | Ibu (HP Ibu) | Pilih profil "Ibu" untuk **Mode Alarm Keras (`full_alarm`)** di HP Ibu | `AlarmManager` lokal di HP Ibu otomatis menjadwalkan semua exact alarm obat Ibu | Jika izin Exact Alarm/DND di HP Ibu belum aktif, arahkan ke panduan izin |
| 6 | Ibu (HP Ibu) | Saat jam 08:00 alarm berbunyi di HP Ibu, Ibu tap **"Sudah Minum"** | Stok berkurang 1x (`stock_applied` guard), `DOSE_LOG` ditulis ke cloud; **Firestore Real-time Listener** di HP lain yang sedang berbunyi langsung menghentikan alarm; HP Anak (mode `monitor_only`) menerima notifikasi pantau *"Ibu sudah minum Amlodipine 5mg pukul 08:01"* saat app aktif / pada siklus WorkManager berikutnya | Jika HP Ibu tidak ada sinyal saat tap, tetap tersimpan di SQLite lokal dan otomatis sinkron saat sinyal kembali |

---

## Flow 14: Admin – Cabut Akses Anggota (Revoke) & Anggota Keluar Grup (Leave) (FR-18)

### Trigger
Anak (Admin) ingin mencabut akses email anggota yang tidak lagi memantau (mis. mantan pengasuh), atau seorang anggota ingin keluar dari grup keluarga.

### Pre-conditions
- Grup keluarga (`FAMILY_GROUP`) sudah terbentuk dan pengguna sudah *Login with Google*.

### Post-conditions
- Akses email dicabut/dilepas; sinkronisasi berhenti; data lokal di HP anggota tetap utuh (kembali ke Mode Offline Lokal).

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Buka Keluarga & Sinkronisasi → pilih email anggota → tap "Cabut Akses" | Hapus `access/{email}` + `email_index/{email}` (hanya `role == 'admin'` yang diizinkan Rules) | Jika bukan admin, tombol tidak tampil & Rules menolak |
| 2 | Anggota (HP-nya) | Sinkronisasi berikutnya berjalan | Perangkat gagal membaca/menulis (Rules menolak); aplikasi beralih ke Mode Offline Lokal dan menampilkan info "Akses keluarga dicabut" | Data lokal tetap tersimpan, tidak dihapus otomatis |
| 3 | Anggota | (Alt) Tap "Keluar dari Keluarga" | Hapus `access/{email}` + `email_index/{email}` miliknya sendiri → berhenti sinkron, kembali Mode Offline Lokal | Konfirmasi dialog sebelum keluar |

---

## Flow 15: Admin – Hapus Akun & Data Cloud (FR-18)

### Trigger
Pengguna ingin menghapus akun Google dan seluruh data cloud (kewajiban Google Play).

### Pre-conditions
- Pengguna sudah *Login with Google*.

### Post-conditions
- Dokumen akses & `email_index` pengguna terhapus; bila pemilik grup, seluruh dokumen grup terhapus.

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Admin | Pengaturan → "Hapus Akun & Data Cloud" | Tampilkan dialog konfirmasi ganda (ketik "HAPUS" untuk konfirmasi) | Batal kapan saja |
| 2 | Admin | Konfirmasi | Hapus `access/{email}` + `email_index/{email}`; bila `owner_email == user`, hapus seluruh dokumen `family_groups/{familyId}` | Jika offline, antrekan operasi sampai online |
| 3 | System | Selesai | Data lokal di HP tetap ada (aplikasi kembali Mode Offline Lokal) kecuali user memilih hapus data lokal juga | Tampilkan status akhir yang jelas |

---

## Flow 16: Keluarga – Rekonsiliasi Latar & Notifikasi Pantau Tertunda (FR-18, FR-19)

### Trigger
HP anggota dalam mode `monitor_only` (mis. HP Anak di kantor) dan aplikasinya sedang tidak dibuka saat Ibu minum obat.

### Pre-conditions
- Grup keluarga aktif; HP Anak dalam mode `monitor_only`.

### Post-conditions
- Status minum tersinkron dan notifikasi pantau muncul saat app aktif / siklus WorkManager berikutnya.

### Flow Table

| No | Actor | Action/Step | System Response | Alternative/Error Path |
|:---|:---|:---|:---|:---|
| 1 | Ibu | Tap "Sudah Minum" di HP Ibu | `dose_logs/{id}` ditulis ke cloud | — |
| 2 | System (HP Anak) | `WorkManagerSyncWorker` periodik (≥15 menit) atau saat app dibuka | Tarik delta Firestore → update SQLite → tampilkan notifikasi pantau *"Ibu sudah minum ..."* (mode `monitor_only`) | Jika kuota/koneksi habis, coba lagi pada siklus berikutnya |
| 3 | System (HP Anak) | Bila alarm HP Anak sedang berbunyi (jarang pada mode pantau) | Firestore Real-time Listener menghentikan alarm seketika saat online | Bila offline, alarm berhenti via batas eskalasi/aksi lokal |

---

## Summary of Key User Flows

- **Mode Hybrid Fleksibel:** Bisa dipakai langsung tanpa login (100% Offline Lokal) atau *Login with Google* + *Invite Email Keluarga* untuk sinkronisasi otomatis lintas HP (`FR-18`).
- **Kontrol Bunyi Cerdas per HP:** HP di rumah diset *Mode Alarm Keras*, sedangkan HP anak di kantor diset *Mode Pantau* (`FR-19`).
- **Loop harian tahan banting:** Alarm tembus silent + *Grouped Alarm* + TTS + eskalasi → aksi cepat → sinkronisasi real-time via **Firestore Snapshot Listener** (saat alarm aktif) + rekonsiliasi `WorkManager` + riwayat & stok fleksibel (ledger).
- **Kontrol & privasi keluarga:** invite/revoke akses, keluar grup, dan hapus akun cloud semuanya tersedia dengan penegakan role `admin` via Security Rules (Flow 14–15).
- Semua flow memetakan `FR-01` sampai `FR-19` secara lengkap dengan jaminan biaya server **Rp 0 (Zero-Bill Architecture)**.
