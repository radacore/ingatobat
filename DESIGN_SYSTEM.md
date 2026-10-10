# DESIGN_SYSTEM.md: IngatObat

## Brand & Visual Identity

IngatObat adalah aplikasi kesehatan keluarga yang menenangkan dan tepercaya. Visual memakai Material 3 dengan warna menenangkan (biru-teal), sudut membulat besar, tombol besar untuk orang tua, dan foto obat yang jelas di kartu jadwal dan layar alarm. Seluruh aplikasi full Bahasa Indonesia (tidak ada teks English di UI user).

## User Experience Goals

1. **Tidak terlewat minum** — Admin dapat membuat jadwal baru < 3 menit dengan tingkat penyelesaian 95%.
2. **Alarm jelas bagi lansia** — Nama anggota + nama obat + dosis + foto terbaca dalam 3 detik di full-screen, target tap aksi 100%.
3. **Aman offline** — Semua fungsi inti tanpa internet, target sentuh min 48dp, tanpa scroll horizontal di 360dp.

## Color Palette

Warna brand tetap sesuai PRD (biru-teal). Netral dipertajam ke arah *slate* agar
kartu terasa lebih bersih, dan warna peringatan dibagi dua: satu nada teks yang
aman kontras (`warning`) dan satu nada isian (`warningFill`) untuk ikon/latar.

### Primary Colors
| Color | Hex | Token | Usage |
|:---|:---|:---|:---|
| Primary Blue | `#1565C0` | `AppColors.primary` | Tombol utama, hero Hari Ini, aksen |
| Primary Dark | `#0D47A1` | `AppColors.primaryDark` | Gradien hero, footer alarm |
| Accent Teal | `#00897B` | `AppColors.accent` | Sudah Minum, highlight, meta positif |

### Secondary Colors
| Color | Hex | Token | Usage |
|:---|:---|:---|:---|
| Light Blue | `#E3F2FD` | `AppColors.secondaryLight` | Latar kartu lembut, `primaryContainer` |
| Warning (teks) | `#B45309` | `AppColors.warning` | Tunda, stok menipis — aman kontras di teks |
| Warning Fill | `#F59E0B` | `AppColors.warningFill` | Ikon/latar peringatan, badge |
| Success Green | `#2E7D32` | `AppColors.success` | Konfirmasi minum |

### Neutral & Semantic (refined slate neutrals)
| Token | Hex | Usage |
|:---|:---|:---|
| `textDark` | `#1A2027` | Teks utama (judul, isi) |
| `textMedium` | `#5A6472` | Meta, timestamp, subtitle |
| `textHint` | `#94A0AF` | Hint input, chevron, placeholder |
| `border` | `#E2E6EB` | Border input, outline |
| `divider` | `#EDF0F3` | Divider, hairline app bar |
| `surface` | `#FFFFFF` | Kartu, app bar, sheet |
| `surfaceMuted` | `#F5F7FA` | Latar isian input, chip |
| `canvas` | `#EEF2F6` | Latar halaman (scaffold) |
| `error` | `#D32F2F` | Lewati/missed, aksi destruktif |

```dart
// lib/core/theme/app_palette.dart — sumber tunggal warna mentah.
class AppColors {
  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const accent = Color(0xFF00897B);
  static const secondaryLight = Color(0xFFE3F2FD);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFB45309);   // nada teks
  static const warningFill = Color(0xFFF59E0B); // nada isian
  static const error = Color(0xFFD32F2F);
  // ...netral slate: textDark/textMedium/textHint/border/divider/surface/…
}
```

### Semantic Layer: `AppPalette` (ThemeExtension)

Widget **tidak** memakai `AppColors.*` langsung untuk teks/latar. Semua lewat
`context.palette` (ThemeExtension) agar mode kontras tinggi benar-benar berlaku:

```dart
final p = context.palette;
Text('Stok menipis', style: TextStyle(color: p.warning));
```

| Field | Light | Kontras tinggi (`AppPalette.hc`) |
|:---|:---|:---|
| `primary` / `accent` | biru `#1565C0` / teal `#00897B` | kuning `#FFEB3B` |
| `onPrimary` | putih | hitam |
| `textPrimary` / `textSecondary` | slate gelap / medium | putih / `#E6E6E6` |
| `surface` / `canvas` | putih / `#EEF2F6` | hitam |
| `border` / `divider` | slate muda | kuning |
| `highContrast` | `false` | `true` (dipakai untuk latar transparan + border) |

Aturan migrasi: ganti `AppColors.textDark` → `p.textPrimary`,
`AppColors.textMedium` → `p.textSecondary`, `AppColors.warning` → `p.warning`.
`AppColors.error` pada tombol destruktif → `p.error` + `foregroundColor: p.onPrimary`.

## Typography

| Usage | Font | Size/Weight |
|:---|:---|:---|
| Judul alarm | Roboto Bold | 24sp / 700 (XL: 30sp) |
| Nama obat | Roboto Medium | 20sp / 500 (XL: 26sp) |
| Body | Roboto Regular | 16sp / 400 (skala S/M/L/XL: 14/16/20/24sp) |
| Meta | Roboto Regular | 14sp / 400 |
| Tombol | Roboto Medium | 18sp / 500, all-caps false |

Skala Material 3 dengan pengali aksesibilitas: S 0.875x, M 1.0x, L 1.25x, XL 1.5x. Berlaku global termasuk alarm dan widget.

## Aksesibilitas Fleksibel (FR-13)

| Opsi | Nilai | Keterangan |
|:---|:---|:---|
| Skala font | S/M/L/XL | Default M; XL untuk lansia |
| Ukuran tombol | Standar 48dp / Besar 64dp | Berlaku tombol alarm dan utama |
| Tema kontras | Normal / Kontras tinggi | Tinggi: bg hitam, teks putih/kuning, tombol outline 3dp |

- Pratinjau langsung di Pengaturan sebelum simpan.
- Widget mengikuti font L ke bawah agar muat; XL dipadatkan jadi 3 item.

## UI Components & Spacing

Skala spasi & radius terpusat di `lib/core/theme/app_theme.dart`. Widget memakai
konstanta ini, bukan angka ajaib.

```dart
class AppSpacing {            // unit dasar 4dp
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;     // padding kartu/list default
  static const lg = 20.0;     // padding form
  static const xl = 24.0;
  static const xxl = 32.0;    // bawah list agar tak tertutup FAB
  static const screen = 16.0; // padding tepi layar
}

class AppRadius {
  static const sm = 10.0;     // chip, badge
  static const md = 14.0;     // input, tombol
  static const lg = 18.0;     // kartu
  static const xl = 24.0;     // sheet, dialog
  static const pill = 999.0;  // status chip
}
```

| Component | Padding | Radius | Min Height |
|:---|:---|:---|:---|
| Tombol utama | `AppSpacing.md` × 24dp | `AppRadius.md` (14) | 56dp |
| Tombol aksi alarm | 16dp | 16dp | 64dp |
| Input | 16dp | `AppRadius.md` (14) | 56dp |
| Kartu | `AppSpacing.md` (16) | `AppRadius.lg` (18) | — |
| Bottom sheet | `AppSpacing.lg` (20) | `AppRadius.xl` atas | — |
| Full-screen alarm | 24dp | 24dp top | — |

### App Bar

App bar sekunder memakai gaya **permukaan putih** (bukan biru solid): judul gelap
(`textPrimary`), tanpa elevasi, dengan *hairline* `divider` di bawah
(`scrolledUnderElevation: 0`). Pengecualian: **Hari Ini** memakai hero gradien
`primary → primaryDark` sebagai `SliverAppBar` dengan teks `onPrimary`.

### Ikon

Ikon dalam kartu memakai widget bersama `SoftIcon` (kotak ikon berlatar lembut,
`color.withValues(alpha: 0.12)`, radius `AppRadius.md`). Di mode kontras tinggi,
latar dibuat transparan dan diganti border warna penuh agar tetap terbaca.

### Bottom Navigation

4 tab: Hari Ini, Obat, Riwayat, Keluarga. Label selalu tampil (bukan hanya saat
aktif) agar lansia tidak bergantung pada ikon saja.

### Splash & Launch Screen

Dua lapis, disambung mulus tanpa lompatan warna:

1. **System splash (native)** — saat proses Android masih boot. Gradien biru brand
   (`launch_blue → launch_blue_dark`) + logo jam alarm vektor (`launch_mark.xml`).
   Di Android 12+ (`values-v31`) memakai `windowSplashScreen*` dengan ikon
   *animated vector* (`launch_mark_avd.xml`, durasi 1000 ms): logo membesar
   (0.85→1, overshoot) + lonceng bergoyang. Catatan: layar ini **tidak** bisa
   memutar SVG/SMIL — batasan OS; animasi SVG hanya jalan di dalam engine Flutter
   atau peramban.
2. **Splash Flutter** — adegan animasi penuh (loop 4 dtk) digambar via
   `CustomPaint` di `splash_screen.dart`: jam alarm bernapas + lonceng bergetar +
   gelombang bunyi + kapsul & tablet mengambang + badge "sudah minum" pop-in
   dengan centang *draw-on*. Storyboard sumber ada di
   `assets/animations/splash_care.svg` (SMIL). Splash ditahan **min. 3,5 dtk**
   agar animasi sempat dimainkan; menghormati *reduced motion*
   (`WidgetsBinding.instance.disableAnimations`) dengan membekukan pose.

Breakpoints: compact 360dp (mayoritas), medium 600dp (tablet), expanded 840dp. Prioritas layar: Hari Ini, Alarm full-screen, Tambah Obat, Riwayat, Laporan, Kontrol RS.

## Screen Priorities & Daftar Lengkap Layar (Total: 18 Screen + 5 Bottom Sheet; 17 aktif di v1.0 — PIN di v1.2)

### A. Layar Pembuka, Onboarding & Keamanan (4 Screen, 3 aktif di v1.0)
1. **`01_SplashScreen`** — Inisialisasi SQLite (`drift`), cek status login Firebase & sinkronisasi keluarga, dan arahkan ke Onboarding atau Beranda (`< 1.5 detik`). (Cek kunci PIN ditambahkan saat fitur PIN masuk di v1.2.)
2. **`02_OnboardingPermissionScreen`** — Pilihan mode awal (*Langsung Pakai Offline* vs *Login dengan Google*) + wizard aktivasi 3 izin wajib (*Notifikasi*, *Exact Alarm*, *DND Access*) + tes bunyi alarm.
3. **`03_FamilyJoinSetupScreen`** — Muncul otomatis saat anggota keluarga yang diundang *Login with Google* (`FR-18`, `FR-19`); memilih profil anggota mana yang membunyikan **Alarm Keras (`full_alarm`)** di HP ini vs **Mode Pantau (`monitor_only`)**.
4. **`04_PinLockScreen` (P1, di luar scope v1.0)** — Layar kunci PIN 6 digit / biometrik saat aplikasi dibuka. Tidak dibangun pada rilis awal.

### B. Layar Utama — Bottom Navigation 4 Tab (4 Screen)
5. **`05_TodayHomeScreen` (Tab 1: Hari Ini)** — Agenda gabungan serumah hari ini, indikator sinkronisasi keluarga, filter chip anggota, kartu jadwal obat + foto + aksi cepat, dan banner peringatan stok/kontrol RS.
6. **`06_MedicineListScreen` (Tab 2: Obat & Stok)** — Sub-tab *Semua Obat Aktif* per anggota dan sub-tab *Perlu Beli Ulang (Stok Menipis)* beserta tombol isi ulang cepat.
7. **`07_HistoryAndReportScreen` (Tab 3: Riwayat & Laporan)** — Sub-tab *Log Riwayat Minum* (dengan info `action_by_email` & koreksi status) dan sub-tab *Laporan Kepatuhan* (grafik %, ekspor CSV, & cetak **Laporan PDF Dokter** `FR-16`).
8. **`08_FamilyAndMoreScreen` (Tab 4: Keluarga & Lainnya)** — Status akun Google & Cloud Firestore, daftar email keluarga terundang (`+ Undang Email` + cabut akses), pengaturan *Bunyi Alarm di HP Ini*, serta menu menuju Anggota, Kontrol RS, Pengaturan, dan Backup.

### C. Layar Detail, Form CRUD & Pengaturan (8 Screen)
9. **`09_MemberFormScreen`** — Daftar & form tambah/edit/arsip profil anggota rumah (`FR-01`).
10. **`10_MedicineDetailScreen`** — Detail obat lengkap: foto penuh, sisa stok, daftar jadwal obat tersebut, dan riwayat **Efek Samping** (`FR-15`).
11. **`11_MedicineFormScreen`** — Form tambah/edit obat, kamera/galeri (kompresi lokal + WebP `< 20KB`), kekuatan dosis, takaran fleksibel `dose_qty` (`1` tablet / `0.5` tablet / `5` ml), dan stok awal (`FR-02`, `FR-07`).
12. **`12_ScheduleFormScreen`** — Form jadwal harian/mingguan/interval jam (`anchor_time`) + toggle suara TTS Bahasa Indonesia per jadwal (`FR-03`, `FR-11`).
13. **`13_SideEffectFormScreen`** — Form catat keluhan efek samping obat (jenis, keparahan ringan/sedang/berat, waktu, catatan) (`FR-15`).
14. **`14_ControlVisitScreen` (Daftar & Form)** — Daftar kontrol RS mendatang + form tambah kontrol RS dengan auto-jadwal alarm **H-2 Hari (08:00)** & **H-1 Hari (08:00)** (`FR-09`).
15. **`15_SettingsAccessibilityScreen`** — Pengaturan nada alarm, uji suara TTS, pola eskalasi, **Aksesibilitas Lansia** (skala font S/M/L/XL, tombol 48/64dp, tema kontras tinggi dengan *live preview* `FR-13`), serta tombol **Hapus Akun & Data Cloud**.
16. **`16_PermissionAndBackupScreen`** — Indikator kesehatan izin + panduan baterai OEM (Xiaomi/Samsung/Oppo) + Backup/Restore ZIP manual & jadwal **Auto-Backup Mingguan SAF** (`FR-10`, `FR-17`).

### D. Layar Sistem Khusus & Widget (2 Screen)
17. **`17_FullScreenAlarmScreen` (Tunggal & *Grouped Alarm*)** — Tampil di atas *Lock Screen* menembus mode Silent/DND (`FR-04`, `FR-05`, `FR-12`). Menampilkan kartu besar dengan foto obat, indikator TTS aktif, tombol **SUDAH MINUM**, **TUNDA 10 MENIT**, **LEWATI**, serta **KONFIRMASI SEMUA** bila ada >1 obat di jam yang sama.
18. **`18_HomeAgendaWidget` (Android AppWidget)** — Widget di *Home Screen* HP yang menampilkan 5 agenda minum obat terdekat hari ini (`FR-14`).

### E. Komponen Bottom Sheet / Modal (5 Pop-up Ringan)
- **BS-01:** *Restock Cepat* (input tambah stok obat).
- **BS-02:** *Pilih Alasan Lewati Obat* (habis / puasa / efek samping / instruksi dokter).
- **BS-03:** *Ubah / Koreksi Status Riwayat* (`missed`/`skipped` ↔ `taken` dengan penyesuaian stok otomatis).
- **BS-04:** *Undang Email Keluarga* (input email Gmail anggota keluarga).
- **BS-05:** *Filter & Rentang Tanggal Laporan/PDF*.

## Interaction & Motion

- Fade 200ms antar tab; slide-up 250ms untuk bottom sheet; full-screen alarm tanpa animasi masuk agar cepat.
- Tombol alarm bergetar ringan (haptic) saat ditekan; toast konfirmasi 2 detik.
- Hormati `prefers-reduced-motion` / animator off di aksesibilitas Android: nonaktifkan animasi non-esensial.

## Accessibility

- Kontras teks di atas 4.5:1; tombol putih di atas biru 8+:1.
- Semua input berlabel; error terbaca screen reader (TalkBack).
- Fokus jelas di TV/keyboard; modal menjebak fokus dengan tombol tutup.
- Foto obat selalu ada alt (nama obat); jangan sampaikan status hanya warna (tambah ikon + teks).
- Checklist: lolos Axe/TalkBack smoke test, target 48dp, navigasi keyboard penuh.
