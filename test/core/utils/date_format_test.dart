import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/core/utils/date_format.dart';

void main() {
  group('formatChatTimestamp', () {
    final now = DateTime(2026, 9, 14, 15, 30);
    const frWeekdays = [
      'lun.',
      'mar.',
      'mer.',
      'jeu.',
      'ven.',
      'sam.',
      'dim.',
    ];

    test('affiche l\'heure pour aujourd\'hui', () {
      expect(
        formatChatTimestamp(DateTime(2026, 9, 14, 9, 5), now: now),
        '09:05',
      );
    });

    test('affiche Hier pour la veille (FR)', () {
      expect(
        formatChatTimestamp(
          DateTime(2026, 9, 13, 20, 0),
          now: now,
          yesterdayLabel: 'Hier',
        ),
        'Hier',
      );
    });

    test('affiche Yesterday pour la veille (EN)', () {
      expect(
        formatChatTimestamp(
          DateTime(2026, 9, 13, 20, 0),
          now: now,
          yesterdayLabel: 'Yesterday',
        ),
        'Yesterday',
      );
    });

    test('affiche le jour de la semaine sous 7 jours', () {
      expect(
        formatChatTimestamp(
          DateTime(2026, 9, 10, 12, 0),
          now: now,
          weekdayLabels: frWeekdays,
        ),
        'jeu.',
      );
    });

    test('affiche jj/mm au-delà', () {
      expect(
        formatChatTimestamp(DateTime(2026, 8, 1, 12, 0), now: now),
        '01/08',
      );
    });
  });

  group('formatMessageTime', () {
    test('formate HH:mm', () {
      expect(formatMessageTime(DateTime(2026, 1, 1, 8, 9)), '08:09');
    });
  });
}
