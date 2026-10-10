import '../../core/constants.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/app_repository.dart';
import 'alarm_service.dart';
import 'dose_service.dart';
import 'schedule_engine.dart';

/// Menyusun jadwal alarm native (AlarmManager) dari jadwal minum lokal.
///
/// Aturan grouping (FR-04): semua dosis pada menit yang sama digabung menjadi
/// satu alarm. Hanya anggota ber-mode `full_alarm` yang membunyikan alarm keras;
/// anggota `monitor_only` cukup mendapat notifikasi pantau.
class AlarmCoordinator {
  final AppDatabase db;
  final AppRepository repo;
  final DoseService doseService;

  AlarmCoordinator(this.db, this.repo, this.doseService);

  static const _horizonDays = 3;

  Future<String> _toneUri() async =>
      await db.getSetting(SettingKeys.alarmTone) ?? '';

  Future<bool> _ttsEnabledGlobal() async =>
      (await db.getSetting(SettingKeys.ttsEnabled) ?? '1') == '1';

  /// Susun ulang seluruh alarm untuk `_horizonDays` hari ke depan.
  Future<void> rescheduleAll() async {
    await AlarmService.cancelAll();

    final schedules = await db.getActiveSchedules();
    if (schedules.isEmpty) return;

    final now = DateTime.now();
    await doseService.ensureDoseLogsForRange(now, Dates.endOfDay(now.add(
      const Duration(days: _horizonDays),
    )));

    final modes = await db.watchAlarmModes().first;
    final medicines = <String, Medicine>{};
    final members = <String, Member>{};
    for (final m in await db.select(db.medicines).get()) {
      medicines[m.id] = m;
    }
    for (final m in await db.select(db.members).get()) {
      members[m.id] = m;
    }

    final occurrences = ScheduleEngine.expandRange(
      schedules,
      now,
      Dates.endOfDay(now.add(const Duration(days: _horizonDays))),
    );

    // Kelompokkan per menit.
    final groups = <int, List<DoseOccurrence>>{};
    for (final o in occurrences) {
      if (!o.scheduledAt.isAfter(now)) continue;
      final key = o.scheduledAt.millisecondsSinceEpoch ~/ 60000;
      groups.putIfAbsent(key, () => []).add(o);
    }

    final tone = await _toneUri();
    final ttsGlobal = await _ttsEnabledGlobal();

    for (final entry in groups.entries) {
      final occs = entry.value;
      final atMs = occs.first.scheduledAt.millisecondsSinceEpoch;

      final fullAlarm = occs.any(
        (o) => (modes[o.memberId] ?? 'monitor_only') == 'full_alarm',
      );

      final logIds = <String>[];
      final memberNames = <String>[];
      final parts = <String>[];
      var anyTts = false;

      for (final o in occs) {
        final med = medicines[o.medicineId];
        final member = members[o.memberId];
        if (med == null || member == null) continue;
        final log = await db.findDoseLogByScheduleAndTime(o.scheduleId, atMs);
        if (log == null) continue;
        if (log.status == 'taken' || log.status == 'skipped') continue;
        logIds.add(log.id);

        final schedule = await db.getSchedule(o.scheduleId);
        final qty = schedule?.doseQty ?? med.doseQty;
        final qtyText = qty == qty.roundToDouble()
            ? qty.toInt().toString()
            : qty.toString();
        if (!memberNames.contains(member.name)) memberNames.add(member.name);
        parts.add('${med.name} $qtyText ${med.unit}');
        if (schedule?.ttsEnabled ?? true) anyTts = true;
      }

      if (logIds.isEmpty) continue;

      final title = fullAlarm ? 'Waktunya Minum Obat' : 'Pengingat Minum Obat';
      final body = '${memberNames.join(' & ')}: ${parts.join(', ')}';
      final ttsText = 'Waktunya minum obat. ${parts.join('. ')}';

      await AlarmService.scheduleAlarm(AlarmRequest(
        id: 'dose_$atMs',
        triggerAtMs: atMs,
        title: title,
        body: body,
        toneUri: tone.isEmpty ? null : tone,
        ttsEnabled: fullAlarm && ttsGlobal && anyTts,
        ttsText: ttsText,
        fullAlarm: fullAlarm,
        doseLogIds: logIds,
      ));
    }
  }

  /// Batalkan alarm untuk satu dosis (mis. setelah dikonfirmasi).
  Future<void> cancelForDoseLog(DoseLog log) async {
    await AlarmService.cancelAlarm('dose_${log.scheduledAt}');
  }

  Future<void> cancelAll() => AlarmService.cancelAll();
}
