import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/theme/app_theme.dart';
import 'domain/services/alarm_service.dart';
import 'domain/services/realtime_alarm_watcher.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/alarm_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/widgets/dose_card.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class IngatObatApp extends ConsumerStatefulWidget {
  const IngatObatApp({super.key});

  @override
  ConsumerState<IngatObatApp> createState() => _IngatObatAppState();
}

class _IngatObatAppState extends ConsumerState<IngatObatApp> {
  RealtimeAlarmWatcher? _remoteWatcher;

  @override
  void initState() {
    super.initState();
    AlarmService.onAlarmLaunch = _openAlarm;
    AlarmService.onNativeAction = _handleNativeAction;
    _checkInitialAlarm();
  }

  @override
  void dispose() {
    _remoteWatcher?.stop();
    super.dispose();
  }

  /// Aksi cepat dari notifikasi native (Sudah Minum / Tunda / Lewati).
  Future<void> _handleNativeAction(
    String action,
    Map<String, dynamic> data,
  ) async {
    final ids =
        (data['doseLogIds'] as List?)?.cast<String>() ?? const <String>[];
    if (ids.isEmpty) return;
    final logs = await ref.read(databaseProvider).getDoseLogsByIds(ids);
    final actions = DoseActions(ref);
    for (final log in logs) {
      if (action == 'taken') {
        await actions.taken(log);
      } else if (action == 'snooze') {
        await actions.snooze(log, AlarmRules.snoozeOptions.first);
      } else if (action == 'skip') {
        await actions.skip(log, 'Dari notifikasi');
      }
    }
    await AlarmService.stopAlarm();
  }

  Future<void> _checkInitialAlarm() async {
    final ids = await AlarmService.getInitialAlarmDoseLogIds();
    if (ids.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));
      _openAlarm(ids);
    }
  }

  void _openAlarm(List<String> doseLogIds) {
    if (doseLogIds.isEmpty) return;
    _watchRemoteConfirm(doseLogIds);
    navigatorKey.currentState
        ?.push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => AlarmScreen(doseLogIds: doseLogIds),
          ),
        )
        .then((_) => _remoteWatcher?.stop());
  }

  /// FR-18/NFR: hentikan alarm bila anggota lain mengonfirmasi obat real-time.
  Future<void> _watchRemoteConfirm(List<String> doseLogIds) async {
    final watcher = RealtimeAlarmWatcher(ref.read(databaseProvider));
    _remoteWatcher = watcher;
    await watcher.watch(doseLogIds, onRemoteTerminal: () {
      AlarmService.stopAlarm();
      navigatorKey.currentState?.maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.build(
        largeButtons: settings.largeButtons,
        highContrast: settings.highContrast,
      ),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // Gabungkan skala sistem dengan pilihan ukuran huruf aplikasi (FR-13).
        final systemScale = mq.textScaler.scale(1.0);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(
              systemScale * settings.fontScale.multiplier,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
