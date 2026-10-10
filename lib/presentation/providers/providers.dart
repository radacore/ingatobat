import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/app_repository.dart';
import '../../domain/services/alarm_coordinator.dart';
import '../../domain/services/auto_backup_service.dart';
import '../../domain/services/backup_service.dart';
import '../../domain/services/dose_service.dart';
import '../../domain/services/family_sync.dart';
import '../../domain/services/firestore_family_sync.dart';
import '../../domain/services/report_service.dart';

// --------------------------------------------------------------------- Core

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider = Provider<AppRepository>(
  (ref) => AppRepository(ref.watch(databaseProvider)),
);

final doseServiceProvider = Provider<DoseService>(
  (ref) => DoseService(ref.watch(databaseProvider)),
);

final alarmCoordinatorProvider = Provider<AlarmCoordinator>(
  (ref) => AlarmCoordinator(
    ref.watch(databaseProvider),
    ref.watch(repositoryProvider),
    ref.watch(doseServiceProvider),
  ),
);

// ---------------------------------------------------------------- Pengaturan

class AppSettings {
  final FontScale fontScale;
  final bool largeButtons;
  final bool highContrast;
  final bool ttsEnabled;
  final String alarmTone;
  final String alarmToneTitle;
  final int snoozeDefault;
  final int alarmVolumePreview;
  final bool onboardingDone;
  final bool ttsAvailable;

  const AppSettings({
    this.fontScale = FontScale.m,
    this.largeButtons = false,
    this.highContrast = false,
    this.ttsEnabled = true,
    this.alarmTone = '',
    this.alarmToneTitle = 'Nada bawaan sistem',
    this.snoozeDefault = 10,
    this.alarmVolumePreview = 80,
    this.onboardingDone = false,
    this.ttsAvailable = true,
  });

  AppSettings copyWith({
    FontScale? fontScale,
    bool? largeButtons,
    bool? highContrast,
    bool? ttsEnabled,
    String? alarmTone,
    String? alarmToneTitle,
    int? snoozeDefault,
    int? alarmVolumePreview,
    bool? onboardingDone,
    bool? ttsAvailable,
  }) =>
      AppSettings(
        fontScale: fontScale ?? this.fontScale,
        largeButtons: largeButtons ?? this.largeButtons,
        highContrast: highContrast ?? this.highContrast,
        ttsEnabled: ttsEnabled ?? this.ttsEnabled,
        alarmTone: alarmTone ?? this.alarmTone,
        alarmToneTitle: alarmToneTitle ?? this.alarmToneTitle,
        snoozeDefault: snoozeDefault ?? this.snoozeDefault,
        alarmVolumePreview: alarmVolumePreview ?? this.alarmVolumePreview,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        ttsAvailable: ttsAvailable ?? this.ttsAvailable,
      );
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> _load() async {
    final db = _db;
    final scale = await db.getSetting(SettingKeys.fontScale) ?? 'm';
    state = AppSettings(
      fontScale: FontScale.values.firstWhere(
        (e) => e.name == scale,
        orElse: () => FontScale.m,
      ),
      largeButtons: (await db.getSetting(SettingKeys.largeButtons) ?? '0') == '1',
      highContrast:
          (await db.getSetting(SettingKeys.highContrast) ?? '0') == '1',
      ttsEnabled: (await db.getSetting(SettingKeys.ttsEnabled) ?? '1') == '1',
      alarmTone: await db.getSetting(SettingKeys.alarmTone) ?? '',
      alarmToneTitle:
          await db.getSetting('${SettingKeys.alarmTone}_title') ?? 'Nada bawaan sistem',
      snoozeDefault:
          int.tryParse(await db.getSetting(SettingKeys.snoozeDefault) ?? '10') ??
              10,
      alarmVolumePreview:
          int.tryParse(await db.getSetting(SettingKeys.alarmVolumePreview) ?? '80') ??
              80,
      onboardingDone:
          (await db.getSetting(SettingKeys.onboardingDone) ?? '0') == '1',
      ttsAvailable: (await db.getSetting(SettingKeys.ttsAvailable) ?? '1') == '1',
    );
  }

  Future<void> setFontScale(FontScale v) async {
    await _db.setSetting(SettingKeys.fontScale, v.name);
    state = state.copyWith(fontScale: v);
  }

  Future<void> setLargeButtons(bool v) async {
    await _db.setSetting(SettingKeys.largeButtons, v ? '1' : '0');
    state = state.copyWith(largeButtons: v);
  }

  Future<void> setHighContrast(bool v) async {
    await _db.setSetting(SettingKeys.highContrast, v ? '1' : '0');
    state = state.copyWith(highContrast: v);
  }

  Future<void> setTtsEnabled(bool v) async {
    await _db.setSetting(SettingKeys.ttsEnabled, v ? '1' : '0');
    state = state.copyWith(ttsEnabled: v);
  }

  Future<void> setTtsAvailable(bool v) async {
    await _db.setSetting(SettingKeys.ttsAvailable, v ? '1' : '0');
    state = state.copyWith(ttsAvailable: v);
  }

  Future<void> setAlarmTone(String uri, String title) async {
    await _db.setSetting(SettingKeys.alarmTone, uri);
    await _db.setSetting('${SettingKeys.alarmTone}_title', title);
    state = state.copyWith(alarmTone: uri, alarmToneTitle: title);
  }

  Future<void> setSnoozeDefault(int minutes) async {
    await _db.setSetting(SettingKeys.snoozeDefault, minutes.toString());
    state = state.copyWith(snoozeDefault: minutes);
  }

  Future<void> setAlarmVolumePreview(int volume) async {
    await _db.setSetting(SettingKeys.alarmVolumePreview, volume.toString());
    state = state.copyWith(alarmVolumePreview: volume);
  }

  Future<void> setOnboardingDone(bool v) async {
    await _db.setSetting(SettingKeys.onboardingDone, v ? '1' : '0');
    state = state.copyWith(onboardingDone: v);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

// ------------------------------------------------------------------ Anggota

final membersProvider = StreamProvider<List<Member>>(
  (ref) => ref.watch(databaseProvider).watchActiveMembers(),
);

final memberProvider = FutureProvider.family<Member?, String>(
  (ref, id) => ref.watch(databaseProvider).getMember(id),
);

final memberScheduleCountProvider = StreamProvider.family<int, String>((ref, id) {
  return ref.watch(databaseProvider).watchSchedulesOfMember(id).map((s) => s.length);
});

// --------------------------------------------------------------------- Obat

final medicinesProvider = StreamProvider.family<List<Medicine>, String>(
  (ref, memberId) =>
      ref.watch(databaseProvider).watchMedicinesOfMember(memberId),
);

final medicineProvider = FutureProvider.family<Medicine?, String>(
  (ref, id) => ref.watch(databaseProvider).getMedicine(id),
);

final lowStockProvider = StreamProvider<List<Medicine>>(
  (ref) => ref.watch(databaseProvider).watchLowStockMedicines(),
);

final reportServiceProvider = Provider<ReportService>(
  (ref) => ReportService(ref.watch(databaseProvider)),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);

final autoBackupServiceProvider = Provider<AutoBackupService>(
  (ref) => AutoBackupService(ref.watch(databaseProvider)),
);

final familySyncProvider = Provider<FamilySyncService>(
  (ref) => FirestoreFamilySyncService(ref.watch(databaseProvider)),
);

// ------------------------------------------------------------------- Jadwal

final memberSchedulesProvider = StreamProvider.family<List<Schedule>, String>(
  (ref, memberId) =>
      ref.watch(databaseProvider).watchSchedulesOfMember(memberId),
);

// ------------------------------------------------------------------- Dosis

final todayDoseLogsProvider = StreamProvider<List<DoseLog>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(databaseProvider)
      .watchDoseLogsBetween(Dates.startOfDayMs(now), Dates.endOfDayMs(now));
});

final doseLogProvider = FutureProvider.family<DoseLog?, String>(
  (ref, id) => ref.watch(databaseProvider).getDoseLog(id),
);

class HistoryFilter {
  final String? memberId;
  final String? medicineId;
  final String? status;
  final int? fromMs;
  final int? toMs;

  const HistoryFilter({this.memberId, this.medicineId, this.status, this.fromMs, this.toMs});

  HistoryFilter copyWith({
    String? memberId,
    String? medicineId,
    String? status,
    int? fromMs,
    int? toMs,
    bool clearMember = false,
    bool clearMedicine = false,
    bool clearStatus = false,
  }) =>
      HistoryFilter(
        memberId: clearMember ? null : (memberId ?? this.memberId),
        medicineId: clearMedicine ? null : (medicineId ?? this.medicineId),
        status: clearStatus ? null : (status ?? this.status),
        fromMs: fromMs ?? this.fromMs,
        toMs: toMs ?? this.toMs,
      );
}

final historyFilterProvider = NotifierProvider<HistoryFilterNotifier, HistoryFilter>(
  HistoryFilterNotifier.new,
);

class HistoryFilterNotifier extends Notifier<HistoryFilter> {
  @override
  HistoryFilter build() => const HistoryFilter();

  void setMember(String? id) => state = state.copyWith(memberId: id, clearMember: id == null);
  void setMedicine(String? id) => state = state.copyWith(medicineId: id, clearMedicine: id == null);
  void setStatus(String? s) => state = state.copyWith(status: s, clearStatus: s == null);
  void setRange(int? from, int? to) => state = HistoryFilter(
        memberId: state.memberId,
        medicineId: state.medicineId,
        status: state.status,
        fromMs: from,
        toMs: to,
      );
}

final historyProvider = StreamProvider<List<DoseLog>>((ref) {
  final f = ref.watch(historyFilterProvider);
  return ref.watch(databaseProvider).watchHistory(
        memberId: f.memberId,
        medicineId: f.medicineId,
        status: f.status,
        fromMs: f.fromMs,
        toMs: f.toMs,
      );
});

// -------------------------------------------------------------- Kontrol RS

final memberControlVisitsProvider =
    StreamProvider.family<List<ControlVisit>, String>(
  (ref, memberId) =>
      ref.watch(databaseProvider).watchControlVisitsOfMember(memberId),
);

final allControlVisitsProvider = StreamProvider<List<ControlVisit>>(
  (ref) => ref.watch(databaseProvider).select(
        ref.watch(databaseProvider).controlVisits,
      ).watch(),
);

// ------------------------------------------------------------- Efek samping

final medicineSideEffectsProvider =
    StreamProvider.family<List<SideEffect>, String>(
  (ref, medicineId) =>
      ref.watch(databaseProvider).watchSideEffectsOfMedicine(medicineId),
);

final memberSideEffectsProvider = StreamProvider.family<List<SideEffect>, String>(
  (ref, memberId) =>
      ref.watch(databaseProvider).watchSideEffectsOfMember(memberId),
);

// ------------------------------------------------------------- Preferensi HP

final alarmModesProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(databaseProvider).watchAlarmModes(),
);

final ledgerProvider = StreamProvider.family<List<StockLedger>, String>(
  (ref, medicineId) =>
      ref.watch(databaseProvider).watchLedgerOfMedicine(medicineId),
);

/// Semua obat aktif lintas anggota (untuk tab Obat & Stok).
final allMedicinesProvider = StreamProvider<List<Medicine>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.medicines)
        ..where((t) => t.isArchived.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.name)]))
      .watch();
});

/// Semua obat termasuk arsip (untuk laporan).
final allMedicinesIncludingArchivedProvider = StreamProvider<List<Medicine>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.medicines)
        ..orderBy([(t) => OrderingTerm(expression: t.name)]))
      .watch();
});

final allMembersIncludingArchivedProvider = StreamProvider<List<Member>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.members)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
      .watch();
});

// ------------------------------------------------------------------ Sesi

class FamilySession {
  final String? email;
  final String? familyId;
  final String? familyName;
  final String? role;

  const FamilySession({this.email, this.familyId, this.familyName, this.role});

  bool get isLoggedIn =>
      email != null &&
      email!.isNotEmpty &&
      familyId != null &&
      familyId!.isNotEmpty;
}

final familySessionProvider =
    NotifierProvider<FamilySessionNotifier, FamilySession>(
  FamilySessionNotifier.new,
);

class FamilySessionNotifier extends Notifier<FamilySession> {
  @override
  FamilySession build() {
    _load();
    return const FamilySession();
  }

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> _load() async {
    state = FamilySession(
      email: await _db.getSetting(SettingKeys.currentUserEmail),
      familyId: await _db.getSetting(SettingKeys.currentFamilyId),
      familyName: await _db.getSetting(SettingKeys.familyName),
      role: await _db.getSetting(SettingKeys.currentUserRole),
    );
  }

  Future<void> save({
    required String email,
    required String familyId,
    required String familyName,
    required String role,
  }) async {
    await _db.setSetting(SettingKeys.currentUserEmail, email);
    await _db.setSetting(SettingKeys.currentFamilyId, familyId);
    await _db.setSetting(SettingKeys.familyName, familyName);
    await _db.setSetting(SettingKeys.currentUserRole, role);
    state = FamilySession(
      email: email,
      familyId: familyId,
      familyName: familyName,
      role: role,
    );
  }

  Future<void> clear() async {
    await _db.setSetting(SettingKeys.currentUserEmail, '');
    await _db.setSetting(SettingKeys.currentFamilyId, '');
    await _db.setSetting(SettingKeys.familyName, '');
    await _db.setSetting(SettingKeys.currentUserRole, '');
    state = const FamilySession();
  }
}

/// Jumlah agenda hari ini yang belum dikonfirmasi.
final pendingTodayCountProvider = Provider<int>((ref) {
  final logs = ref.watch(todayDoseLogsProvider).value ?? const [];
  return logs.where((l) => l.status == 'pending' || l.status == 'snoozed').length;
});
