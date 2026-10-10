import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/app_repository.dart';
import 'alarm_coordinator.dart';
import 'auto_backup_service.dart';
import 'dose_service.dart';
import 'widget_service.dart';

const reconcileTaskName = 'ingatobat.reconcile';
const reconcileTaskUnique = 'ingatobat.reconcile.periodic';

/// Callback dispatcher background (WorkManager) — rekonsiliasi periodik ≥15 menit
/// (NFR-Reliability): tandai dosis terlewat, susun ulang alarm, dan auto-backup.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();

    final db = AppDatabase();
    try {
      final doseService = DoseService(db);
      final repo = AppRepository(db);
      final coordinator = AlarmCoordinator(db, repo, doseService);

      await doseService.reconcileMissed();

      final now = DateTime.now();
      await doseService.ensureDoseLogsForRange(
        now,
        now.add(const Duration(days: 3)),
      );
      await coordinator.rescheduleAll();
      await AutoBackupService(db).maybeRunWeekly();
      await WidgetService.refresh(db);
    } catch (_) {
      // jangan hentikan task karena error tunggal
    } finally {
      await db.close();
    }
    return true;
  });
}

/// Daftarkan tugas periodik (dipanggil dari main).
Future<void> registerReconcileTask() async {
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    reconcileTaskUnique,
    reconcileTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.notRequired),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}
