import 'package:flutter_test/flutter_test.dart';
import 'package:ingatobat/domain/services/merge_policy.dart';

void main() {
  group('terminalRank', () {
    test('urutan presedensi terminal taken > skipped > missed', () {
      expect(terminalRank('taken'), greaterThan(terminalRank('skipped')));
      expect(terminalRank('skipped'), greaterThan(terminalRank('missed')));
      expect(terminalRank('missed'), greaterThan(terminalRank('pending')));
      expect(terminalRank('pending'), 0);
      expect(terminalRank(null), 0);
    });

    test('isTerminal hanya benar untuk status final', () {
      expect(isTerminal('taken'), isTrue);
      expect(isTerminal('skipped'), isTrue);
      expect(isTerminal('missed'), isTrue);
      expect(isTerminal('pending'), isFalse);
      expect(isTerminal(null), isFalse);
    });
  });

  group('doseLogIncomingWins (Merge Policy status)', () {
    test('status terminal menang atas non-terminal', () {
      expect(
        doseLogIncomingWins(
          localStatus: 'pending',
          localServerMs: 100,
          incomingStatus: 'taken',
          incomingServerMs: 50,
        ),
        isTrue,
      );
    });

    test('non-terminal tidak menimpa terminal meski lebih baru', () {
      expect(
        doseLogIncomingWins(
          localStatus: 'taken',
          localServerMs: 100,
          incomingStatus: 'pending',
          incomingServerMs: 999,
        ),
        isFalse,
      );
    });

    test('terminal lebih tinggi menang (skipped -> taken)', () {
      expect(
        doseLogIncomingWins(
          localStatus: 'skipped',
          localServerMs: 500,
          incomingStatus: 'taken',
          incomingServerMs: 100,
        ),
        isTrue,
      );
    });

    test('terminal lebih rendah kalah (taken tidak turun ke skipped)', () {
      expect(
        doseLogIncomingWins(
          localStatus: 'taken',
          localServerMs: 100,
          incomingStatus: 'skipped',
          incomingServerMs: 999,
        ),
        isFalse,
      );
    });

    test('rank sama: server_updated_at terbaru menang', () {
      expect(
        doseLogIncomingWins(
          localStatus: 'taken',
          localServerMs: 100,
          incomingStatus: 'taken',
          incomingServerMs: 200,
        ),
        isTrue,
      );
      expect(
        doseLogIncomingWins(
          localStatus: 'taken',
          localServerMs: 200,
          incomingStatus: 'taken',
          incomingServerMs: 100,
        ),
        isFalse,
      );
    });
  });

  group('lwwIncomingWins', () {
    test('dokumen lebih baru menang, sama dianggap menang (idempoten)', () {
      expect(lwwIncomingWins(100, 200), isTrue);
      expect(lwwIncomingWins(200, 100), isFalse);
      expect(lwwIncomingWins(150, 150), isTrue);
    });
  });

  group('field monoton', () {
    test('snooze_count mengambil nilai maksimum', () {
      expect(mergeSnoozeCount(1, 3), 3);
      expect(mergeSnoozeCount(4, 2), 4);
    });

    test('effective_scheduled_at tidak pernah mundur', () {
      expect(mergeEffectiveScheduledAt(1000, 2000), 2000);
      expect(mergeEffectiveScheduledAt(2000, 1000), 2000);
    });

    test('soft delete monoton: deleted_at tidak kembali null', () {
      expect(mergeDeletedAt(null, null), isNull);
      expect(mergeDeletedAt(null, 100), 100);
      expect(mergeDeletedAt(100, null), 100);
      expect(mergeDeletedAt(100, 200), 200);
      expect(mergeDeletedAt(200, 100), 200);
    });
  });
}
