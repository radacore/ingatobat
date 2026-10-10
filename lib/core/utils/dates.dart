import 'package:intl/intl.dart';

/// Helper tanggal & waktu (Bahasa Indonesia).
class Dates {
  static const _hari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  static int startOfDayMs(DateTime d) => startOfDay(d).millisecondsSinceEpoch;

  static int endOfDayMs(DateTime d) => endOfDay(d).millisecondsSinceEpoch;

  /// Gabungkan tanggal + jam "HH:mm".
  static DateTime atTime(DateTime day, String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(day.year, day.month, day.day, h, m);
  }

  static String hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String time(DateTime d) => DateFormat('HH:mm').format(d);

  static String dateShort(DateTime d) =>
      '${d.day} ${_bulan[d.month - 1].substring(0, 3)} ${d.year}';

  static String dateFull(DateTime d) =>
      '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  static String dateTimeFull(DateTime d) =>
      '${dateFull(d)} • ${time(d)}';

  static String dayName(DateTime d) => _hari[d.weekday - 1];

  static String monthName(int month) => _bulan[month - 1];

  static String dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = startOfDay(now);
    final target = startOfDay(d);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    if (diff == -1) return 'Kemarin';
    return '${dayName(d)}, ${dateShort(d)}';
  }

  /// Label rentang H-n untuk kontrol RS.
  static String daysUntil(DateTime visit) {
    final now = startOfDay(DateTime.now());
    final target = startOfDay(visit);
    final diff = target.difference(now).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    if (diff > 1) return '$diff hari lagi';
    return '${-diff} hari lalu';
  }

  /// Awal minggu (Senin) pukul 00:00.
  static DateTime startOfWeek(DateTime d) {
    final s = startOfDay(d);
    return s.subtract(Duration(days: s.weekday - 1));
  }

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static String relativeFromNow(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}
