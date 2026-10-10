import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Namespace tetap untuk UUID v5 deterministik.
///
/// WAJIB berupa UUID yang valid (version nibble 1-5, variant 8/9/a/b) karena
/// `uuid` 4.x memvalidasi namespace sebelum men-generate. Memakai namespace
/// DNS standar (RFC 4122) agar stabil dan tidak pernah ditolak.
const _doseNamespace = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

class Ids {
  static String uuid() => _uuid.v4();

  /// ID deterministik untuk DOSE_LOG: `uuid5(scheduleId + scheduledAt)`
  /// agar tidak pernah dobel antar-perangkat.
  static String doseLog(String scheduleId, int scheduledAt) =>
      _uuid.v5(_doseNamespace, '$scheduleId|$scheduledAt');

  static String stockLedger(String medicineId, int createdAt, String reason) =>
      _uuid.v5(_doseNamespace, 'stock|$medicineId|$createdAt|$reason');
}
