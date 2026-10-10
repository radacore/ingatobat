/// Aturan **Merge Policy** lintas-perangkat (FR-18) — lihat `API.md` &
/// `ARCHITECTURE.md`.
///
/// Fungsi-fungsi di sini murni (tanpa I/O) agar dapat diuji tanpa Firebase,
/// dan dipakai oleh [FirestoreSyncEngine] saat menggabungkan dokumen server.
library;

/// Presedensi status terminal: `taken` > `skipped` > `missed`.
const Map<String, int> _terminalRank = {
  'taken': 3,
  'skipped': 2,
  'missed': 1,
};

/// Peringkat terminal sebuah status (`0` = non-terminal / belum final).
int terminalRank(String? status) => _terminalRank[status] ?? 0;

/// `true` bila [status] bersifat terminal (sudah final).
bool isTerminal(String? status) => terminalRank(status) > 0;

/// Last-Write-Wins berbasis `server_updated_at` (fallback `updated_at`).
bool lwwIncomingWins(int localServerMs, int incomingServerMs) =>
    incomingServerMs >= localServerMs;

/// Presedensi status `dose_log`:
/// 1. status terminal menang atas non-terminal;
/// 2. di antara dua status terminal, peringkat lebih tinggi menang;
/// 3. bila peringkat sama, `server_updated_at` terbaru menang.
bool doseLogIncomingWins({
  required String? localStatus,
  required int localServerMs,
  required String? incomingStatus,
  required int incomingServerMs,
}) {
  final localRank = terminalRank(localStatus);
  final incomingRank = terminalRank(incomingStatus);
  if (incomingRank > localRank) return true;
  if (incomingRank < localRank) return false;
  return lwwIncomingWins(localServerMs, incomingServerMs);
}

/// `snooze_count` bertambah monoton lintas perangkat (ambil nilai maksimum).
int mergeSnoozeCount(int local, int incoming) =>
    local > incoming ? local : incoming;

/// `effective_scheduled_at` mengambil nilai terbaru (monoton, tidak mundur).
int mergeEffectiveScheduledAt(int local, int incoming) =>
    incoming > local ? incoming : local;

/// Soft-delete monoton: sekali `deleted_at` terisi, tidak boleh kembali `null`.
int? mergeDeletedAt(int? local, int? incoming) {
  if (incoming == null) return local;
  if (local == null) return incoming;
  return incoming > local ? incoming : local;
}
