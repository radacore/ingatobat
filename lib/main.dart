import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'domain/services/alarm_service.dart';
import 'domain/services/background_worker.dart';
import 'domain/services/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sinkronisasi keluarga (FR-18) aktif bila Firebase dikonfigurasi;
  // jika tidak, aplikasi tetap berjalan penuh secara offline.
  await FirebaseBootstrap.ensureInitialized();

  await AlarmService.init();

  if (Platform.isAndroid) {
    try {
      await registerReconcileTask();
    } catch (_) {
      // WorkManager tidak tersedia (mis. saat debug di desktop) — abaikan.
    }
  }

  runApp(const ProviderScope(child: IngatObatApp()));
}
