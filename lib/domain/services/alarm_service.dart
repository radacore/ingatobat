import 'package:flutter/services.dart';

/// Jembatan ke alarm native Android (`AlarmManager` + Foreground Service + TTS).
class AlarmService {
  static const MethodChannel _channel = MethodChannel('com.ingatobat/alarm');

  /// Dipanggil saat user menekan aksi dari notifikasi/full-screen native.
  static void Function(String action, Map<String, dynamic> data)?
      onNativeAction;

  /// Dipanggil saat aplikasi dibuka oleh alarm (full-screen intent).
  static void Function(List<String> doseLogIds)? onAlarmLaunch;

  static Future<void> init() async {
    _channel.setMethodCallHandler((call) async {
      final args = call.arguments is Map
          ? Map<String, dynamic>.from(call.arguments as Map)
          : <String, dynamic>{};
      if (call.method == 'onAlarmAction') {
        onNativeAction?.call(args['action'] as String, args);
      } else if (call.method == 'onAlarmLaunch') {
        final ids = (args['doseLogIds'] as List?)?.cast<String>() ?? const [];
        onAlarmLaunch?.call(ids);
      }
      return null;
    });
  }

  /// Ambil payload alarm awal (saat aplikasi diluncurkan dari alarm).
  static Future<List<String>> getInitialAlarmDoseLogIds() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('getInitialAlarm');
    if (raw == null) return const [];
    return raw.cast<String>();
  }

  // ------------------------------------------------------------- Perizinan

  static Future<bool> hasNotificationPermission() async =>
      await _channel.invokeMethod<bool>('hasNotificationPermission') ?? false;

  static Future<bool> hasExactAlarmPermission() async =>
      await _channel.invokeMethod<bool>('hasExactAlarmPermission') ?? false;

  static Future<bool> isIgnoringBatteryOptimizations() async =>
      await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
      false;

  static Future<bool> hasDndAccess() async =>
      await _channel.invokeMethod<bool>('hasDndAccess') ?? false;

  static Future<void> requestNotificationPermission() =>
      _channel.invokeMethod('requestNotificationPermission');

  static Future<void> openExactAlarmSettings() =>
      _channel.invokeMethod('openExactAlarmSettings');

  static Future<void> openDndSettings() =>
      _channel.invokeMethod('openDndSettings');

  static Future<void> openBatterySettings() =>
      _channel.invokeMethod('openBatterySettings');

  static Future<void> openNotificationSettings() =>
      _channel.invokeMethod('openNotificationSettings');

  // ----------------------------------------------------------------- TTS

  static Future<bool> isTtsAvailable() async =>
      await _channel.invokeMethod<bool>('isTtsAvailable') ?? false;

  static Future<void> testTts(String text) =>
      _channel.invokeMethod('testTts', {'text': text});

  // ------------------------------------------------------------ Penjadwalan

  static Future<void> scheduleAlarm(AlarmRequest request) =>
      _channel.invokeMethod('scheduleAlarm', request.toMap());

  static Future<void> cancelAlarm(String id) =>
      _channel.invokeMethod('cancelAlarm', {'id': id});

  static Future<void> cancelAll() => _channel.invokeMethod('cancelAll');

  /// Pratinjau bunyi alarm di Pengaturan (FR-10).
  static Future<void> previewAlarm({required String toneUri, int volume = 80}) =>
      _channel.invokeMethod('previewAlarm', {'toneUri': toneUri, 'volume': volume});

  static Future<void> stopPreview() => _channel.invokeMethod('stopPreview');

  /// Bunyikan alarm sekarang untuk uji coba.
  static Future<void> startAlarmNow({
    required String title,
    required String body,
    bool ttsEnabled = false,
    String? ttsText,
    String? toneUri,
  }) =>
      _channel.invokeMethod('startAlarmNow', {
        'title': title,
        'body': body,
        'ttsEnabled': ttsEnabled,
        'ttsText': ttsText,
        'toneUri': toneUri,
      });

  static Future<void> stopAlarm() => _channel.invokeMethod('stopAlarm');

  // ------------------------------------------------------------ Notifikasi

  /// Tampilkan notifikasi standar (mode pantau, stok menipis, backup, dll).
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool highPriority = false,
  }) =>
      _channel.invokeMethod('showNotification', {
        'id': id,
        'title': title,
        'body': body,
        'highPriority': highPriority,
      });

  static Future<void> cancelNotification(int id) =>
      _channel.invokeMethod('cancelNotification', {'id': id});

  static Future<void> cancelAllNotifications() =>
      _channel.invokeMethod('cancelAllNotifications');

  /// Perbarui data widget agenda hari ini (FR-14).
  static Future<void> updateAgendaWidget(String itemsJson, String count) =>
      _channel.invokeMethod('updateAgendaWidget', {
        'items': itemsJson,
        'count': count,
      });

  /// Muat ulang aplikasi (setelah restore backup).
  static Future<void> restartApp() => _channel.invokeMethod('restartApp');

  // ---------------------------------------------------- Penyimpanan (SAF)

  /// Pilih folder backup (ACTION_OPEN_DOCUMENT_TREE) → URI persisten.
  static Future<String?> pickBackupFolder() =>
      _channel.invokeMethod<String>('pickBackupFolder');

  /// Tulis file backup ke folder SAF. Mengembalikan nama file atau null.
  static Future<String?> writeBackupToFolder(
    String treeUri,
    String fileName,
    List<int> bytes,
  ) async {
    final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'writeBackupToFolder',
      {'uri': treeUri, 'name': fileName, 'bytes': bytes},
    );
    return res?['name']?.toString();
  }

  /// Daftar file backup pada folder SAF (nama + document uri + waktu).
  static Future<List<Map<String, String>>> listBackups(String treeUri) async {
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'listBackups',
      {'uri': treeUri},
    );
    if (raw == null) return const [];
    return raw
        .map((e) => {
              'name': (e as Map)['name'].toString(),
              'uri': e['uri'].toString(),
            })
        .toList();
  }

  static Future<void> deleteDocument(String docUri) =>
      _channel.invokeMethod('deleteDocument', {'uri': docUri});

  /// Pilih satu file backup untuk restore; mengembalikan byte-nya.
  static Future<({String name, List<int> bytes})?> pickFile() async {
    final res = await _channel
        .invokeMethod<Map<dynamic, dynamic>>('pickFile');
    if (res == null) return null;
    final bytes = (res['bytes'] as List).cast<int>();
    return (name: res['name'].toString(), bytes: bytes);
  }

  /// Ambil daftar nada alarm bawaan perangkat.
  static Future<List<Map<String, String>>> getAlarmTones() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('getAlarmTones');
    if (raw == null) return const [];
    return raw
        .map((e) => {
              'title': (e as Map)['title'].toString(),
              'uri': e['uri'].toString(),
            })
        .toList();
  }
}

/// Parameter satu tembakan alarm.
class AlarmRequest {
  final String id;
  final int triggerAtMs;
  final String title;
  final String body;
  final String? toneUri;
  final bool ttsEnabled;
  final String? ttsText;
  final bool fullAlarm;
  final List<String> doseLogIds;

  const AlarmRequest({
    required this.id,
    required this.triggerAtMs,
    required this.title,
    required this.body,
    this.toneUri,
    this.ttsEnabled = true,
    this.ttsText,
    this.fullAlarm = true,
    this.doseLogIds = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'triggerAtMs': triggerAtMs,
        'title': title,
        'body': body,
        'toneUri': toneUri,
        'ttsEnabled': ttsEnabled,
        'ttsText': ttsText,
        'fullAlarm': fullAlarm,
        'doseLogIds': doseLogIds,
      };
}
