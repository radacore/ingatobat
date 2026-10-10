import 'dart:convert';

import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';

/// Satu kejadian dosis hasil ekspansi jadwal.
class DoseOccurrence {
  final String scheduleId;
  final String memberId;
  final String medicineId;
  final DateTime scheduledAt;

  const DoseOccurrence({
    required this.scheduleId,
    required this.memberId,
    required this.medicineId,
    required this.scheduledAt,
  });

  @override
  bool operator ==(Object other) =>
      other is DoseOccurrence &&
      other.scheduleId == scheduleId &&
      other.scheduledAt == scheduledAt;

  @override
  int get hashCode => Object.hash(scheduleId, scheduledAt);
}

/// Mesin ekspansi jadwal (FR-03).
///
/// Aturan interval: *day-clamped* — mulai dari `anchor_time`, dosis dibangkitkan
/// tiap `interval_hours` selama masih di hari kalender yang sama, lalu hari
/// berikutnya rantai diulang dari `anchor_time`.
class ScheduleEngine {
  static List<String> timesOf(Schedule s) {
    try {
      final list = jsonDecode(s.timesJson) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  static List<int> daysOfWeekOf(Schedule s) {
    if (s.daysOfWeek == null) return const [];
    try {
      final list = jsonDecode(s.daysOfWeek!) as List<dynamic>;
      return list.map((e) => int.parse(e.toString())).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Waktu-waktu dosis pada satu hari kalender tertentu.
  static List<DateTime> occurrencesOnDay(Schedule s, DateTime day) {
    final start = DateTime.fromMillisecondsSinceEpoch(s.startDate);
    final dayStart = Dates.startOfDay(day);

    // Belum mulai atau sudah berakhir.
    if (dayStart.isBefore(Dates.startOfDay(start))) return const [];
    if (s.endDate != null) {
      final end = DateTime.fromMillisecondsSinceEpoch(s.endDate!);
      if (dayStart.isAfter(Dates.endOfDay(end))) return const [];
    }

    final times = timesOf(s);
    if (times.isEmpty) return const [];

    switch (s.recurrenceType) {
      case 'weekly':
        final days = daysOfWeekOf(s);
        if (!days.contains(day.weekday)) return const [];
        return times.map((t) => Dates.atTime(day, t)).toList();

      case 'interval':
        final interval = s.intervalHours ?? 24;
        if (interval <= 0) return const [];
        final anchor = Dates.atTime(day, times.first);
        final result = <DateTime>[];
        var cursor = anchor;
        // Selama masih di hari yang sama.
        while (cursor.day == dayStart.day &&
            cursor.month == dayStart.month &&
            cursor.year == dayStart.year) {
          result.add(cursor);
          cursor = cursor.add(Duration(hours: interval));
        }
        return result;

      case 'daily':
      default:
        return times.map((t) => Dates.atTime(day, t)).toList();
    }
  }

  /// Ekspansi semua jadwal dalam rentang [from, to] (inklusif hari).
  static List<DoseOccurrence> expandRange(
    List<Schedule> schedules,
    DateTime from,
    DateTime to,
  ) {
    final result = <DoseOccurrence>[];
    for (final s in schedules) {
      if (!s.isActive) continue;
      var day = Dates.startOfDay(from);
      final last = Dates.startOfDay(to);
      while (!day.isAfter(last)) {
        for (final dt in occurrencesOnDay(s, day)) {
          result.add(DoseOccurrence(
            scheduleId: s.id,
            memberId: s.memberId,
            medicineId: s.medicineId,
            scheduledAt: dt,
          ));
        }
        day = day.add(const Duration(days: 1));
      }
    }
    result.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result;
  }

  /// Kejadian berikutnya setelah [after] (dalam N hari ke depan).
  static DoseOccurrence? nextAfter(
    List<Schedule> schedules,
    DateTime after, {
    int horizonDays = 30,
  }) {
    final occurrences = expandRange(
      schedules,
      Dates.startOfDay(after),
      Dates.startOfDay(after).add(Duration(days: horizonDays)),
    );
    for (final o in occurrences) {
      if (o.scheduledAt.isAfter(after)) return o;
    }
    return null;
  }

  /// Kejadian berikutnya untuk satu jadwal (dipakai untuk reschedule native).
  static DateTime? nextForSchedule(Schedule s, DateTime after) {
    for (var i = 0; i <= 60; i++) {
      final day = Dates.startOfDay(after).add(Duration(days: i));
      for (final dt in occurrencesOnDay(s, day)) {
        if (dt.isAfter(after)) return dt;
      }
    }
    return null;
  }

  /// Semua kejadian untuk satu jadwal dalam rentang.
  static List<DateTime> allForSchedule(
      Schedule s, DateTime from, DateTime to) {
    final result = <DateTime>[];
    var day = Dates.startOfDay(from);
    final last = Dates.startOfDay(to);
    while (!day.isAfter(last)) {
      result.addAll(occurrencesOnDay(s, day));
      day = day.add(const Duration(days: 1));
    }
    return result;
  }
}
