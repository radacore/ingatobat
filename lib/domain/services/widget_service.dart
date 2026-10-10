import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';
import 'alarm_service.dart';

/// Widget agenda hari ini (FR-14). Data dikirim ke AppWidgetProvider native.
class WidgetService {
  static Future<void> refresh(AppDatabase db) async {
    final now = DateTime.now();
    final logs = await (db.select(db.doseLogs)
          ..where((t) =>
              t.scheduledAt.isBiggerOrEqualValue(Dates.startOfDayMs(now)) &
              t.scheduledAt.isSmallerThanValue(Dates.endOfDayMs(now)))
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledAt)]))
        .get();

    final medicines = {for (final m in await db.select(db.medicines).get()) m.id: m};
    final members = {for (final m in await db.select(db.members).get()) m.id: m};

    final pending = logs
        .where((l) => l.status == 'pending' || l.status == 'snoozed')
        .take(5)
        .map((l) => {
              'time': Dates.time(DateTime.fromMillisecondsSinceEpoch(l.scheduledAt)),
              'member': members[l.memberId]?.name ?? '',
              'medicine': medicines[l.medicineId]?.name ?? '',
            })
        .toList();

    await AlarmService.updateAgendaWidget(
      jsonEncode(pending),
      '${pending.length}',
    );
  }
}
