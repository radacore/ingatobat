import 'package:flutter/material.dart';

/// Kunci pengaturan yang disimpan di tabel SETTING.
class SettingKeys {
  static const alarmTone = 'alarm_tone';
  static const alarmVolumePreview = 'alarm_volume_preview';
  static const snoozeDefault = 'snooze_default'; // menit
  static const ttsEnabled = 'tts_enabled';
  static const fontScale = 'font_scale'; // s/m/l/xl
  static const largeButtons = 'large_buttons';
  static const highContrast = 'high_contrast';
  static const lastSyncAt = 'last_sync_at';
  static const currentUserEmail = 'current_user_email';
  static const currentFamilyId = 'current_family_id';
  static const onboardingDone = 'onboarding_done';
  static const ttsAvailable = 'tts_available';
  static const autoBackupUri = 'auto_backup_uri';
  static const autoBackupLastAt = 'auto_backup_last_at';
  static const familyName = 'family_name';
  static const currentUserRole = 'current_user_role';
  static const deviceId = 'device_id';
}

/// Aturan bisnis alarm sesuai FR-05 & FR-12.
class AlarmRules {
  /// Maksimal snooze per dosis.
  static const maxSnooze = 5;

  /// Pilihan menit snooze.
  static const snoozeOptions = [5, 10, 15];

  /// Interval eskalasi (menit).
  static const escalationIntervalMinutes = 5;

  /// Maks eskalasi per segmen (6x = 30 menit).
  static const maxEscalation = 6;

  /// Batas absolut sejak `scheduled_at` asli (menit).
  static const absoluteLimitMinutes = 90;

  /// Toleransi sebelum ditandai missed (menit) sejak effective_scheduled_at.
  static const missedAfterMinutes = 30;
}

/// Kategori & satuan obat.
class MedicineCatalog {
  static const units = ['tablet', 'kapsul', 'ml', 'tetes', 'bungkus', 'sachet'];
  static const mealRelations = {
    'none': 'Tanpa relasi makan',
    'before': 'Sebelum makan',
    'after': 'Sesudah makan',
  };

  static String mealRelationLabel(String key) => mealRelations[key] ?? key;
}

/// Jenis & tingkat efek samping (FR-15).
class SideEffectCatalog {
  static const kinds = {
    'mual': 'Mual',
    'pusing': 'Pusing',
    'gatal': 'Gatal',
    'kustom': 'Lainnya',
  };
  static const severities = {
    'ringan': 'Ringan',
    'sedang': 'Sedang',
    'berat': 'Berat',
  };
}

/// Alasan melewati obat (BS-02).
class SkipReasons {
  static const reasons = [
    'Obat habis',
    'Sedang puasa',
    'Efek samping',
    'Instruksi dokter',
    'Lainnya',
  ];
}

class AppInfo {
  static const appName = 'IngatObat';
  static const version = '1.1.0';
}

/// Ikon status dosis.
IconData doseStatusIcon(String status) {
  switch (status) {
    case 'taken':
      return Icons.check_circle;
    case 'skipped':
      return Icons.remove_circle;
    case 'missed':
      return Icons.error;
    case 'snoozed':
      return Icons.snooze;
    default:
      return Icons.schedule;
  }
}

String doseStatusLabel(String status) {
  switch (status) {
    case 'taken':
      return 'Sudah minum';
    case 'skipped':
      return 'Dilewati';
    case 'missed':
      return 'Terlewat';
    case 'snoozed':
      return 'Ditunda';
    case 'pending':
      return 'Menunggu';
    default:
      return status;
  }
}
