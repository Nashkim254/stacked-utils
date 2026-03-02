import 'package:app_kit/app_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeX', () {
    // ── timeAgo ─────────────────────────────────────────────────────────

    group('timeAgo', () {
      DateTime ago(Duration d) => DateTime.now().subtract(d);

      test('< 60 seconds → "just now"', () {
        expect(ago(const Duration(seconds: 30)).timeAgo, 'just now');
      });

      test('< 60 minutes → "Xm ago"', () {
        expect(ago(const Duration(minutes: 5)).timeAgo, '5m ago');
        expect(ago(const Duration(minutes: 59)).timeAgo, '59m ago');
      });

      test('< 24 hours → "Xh ago"', () {
        expect(ago(const Duration(hours: 3)).timeAgo, '3h ago');
      });

      test('exactly 1 day → "yesterday"', () {
        expect(ago(const Duration(days: 1, seconds: 60)).timeAgo, 'yesterday');
      });

      test('< 7 days → "Xd ago"', () {
        expect(ago(const Duration(days: 3)).timeAgo, '3d ago');
      });

      test('< 30 days → "Xw ago"', () {
        expect(ago(const Duration(days: 14)).timeAgo, '2w ago');
      });

      test('< 365 days → "Xmo ago"', () {
        expect(ago(const Duration(days: 60)).timeAgo, '2mo ago');
      });

      test('>= 365 days → "Xy ago"', () {
        expect(ago(const Duration(days: 366)).timeAgo, '1y ago');
        expect(ago(const Duration(days: 730)).timeAgo, '2y ago');
      });
    });

    // ── formatting ───────────────────────────────────────────────────────

    group('formatting', () {
      final d = DateTime(2024, 1, 14, 9, 30);

      test('toReadableDate → "14 Jan 2024"', () {
        expect(d.toReadableDate, '14 Jan 2024');
      });

      test('toReadableDateAlt → "Jan 14, 2024"', () {
        expect(d.toReadableDateAlt, 'Jan 14, 2024');
      });

      test('toIso8601Date → "2024-01-14"', () {
        expect(d.toIso8601Date, '2024-01-14');
      });

      test('to24HourTime → "09:30"', () {
        expect(d.to24HourTime, '09:30');
      });

      test('format() with custom pattern', () {
        expect(d.format('yyyy/MM/dd'), '2024/01/14');
      });
    });

    // ── boolean checks ───────────────────────────────────────────────────

    group('isToday', () {
      test('today returns true', () {
        expect(DateTime.now().isToday, isTrue);
      });
      test('yesterday returns false', () {
        expect(DateTime.now().subtract(const Duration(days: 1)).isToday, isFalse);
      });
    });

    group('isYesterday', () {
      test('yesterday returns true', () {
        expect(DateTime.now().subtract(const Duration(days: 1)).isYesterday, isTrue);
      });
      test('today returns false', () {
        expect(DateTime.now().isYesterday, isFalse);
      });
    });

    group('isTomorrow', () {
      test('tomorrow returns true', () {
        expect(DateTime.now().add(const Duration(days: 1)).isTomorrow, isTrue);
      });
      test('today returns false', () {
        expect(DateTime.now().isTomorrow, isFalse);
      });
    });

    group('isThisYear', () {
      test('current year returns true', () {
        expect(DateTime.now().isThisYear, isTrue);
      });
      test('last year returns false', () {
        expect(
          DateTime(DateTime.now().year - 1).isThisYear,
          isFalse,
        );
      });
    });

    group('isPast / isFuture', () {
      test('past date is isPast', () {
        expect(DateTime(2000).isPast, isTrue);
        expect(DateTime(2000).isFuture, isFalse);
      });
      test('future date is isFuture', () {
        expect(DateTime(2099).isFuture, isTrue);
        expect(DateTime(2099).isPast, isFalse);
      });
    });

    // ── boundaries ───────────────────────────────────────────────────────

    group('startOfDay / endOfDay', () {
      final d = DateTime(2024, 6, 15, 12, 30);

      test('startOfDay is midnight', () {
        final s = d.startOfDay;
        expect(s.hour, 0);
        expect(s.minute, 0);
        expect(s.second, 0);
        expect(s.day, 15);
      });

      test('endOfDay is 23:59:59.999', () {
        final e = d.endOfDay;
        expect(e.hour, 23);
        expect(e.minute, 59);
        expect(e.second, 59);
      });
    });

    group('startOfMonth / endOfMonth', () {
      final d = DateTime(2024, 3, 15);

      test('startOfMonth is first day', () {
        expect(d.startOfMonth.day, 1);
        expect(d.startOfMonth.month, 3);
      });

      test('endOfMonth is last day of month', () {
        expect(d.endOfMonth.month, 3);
        expect(d.endOfMonth.day, 31); // March has 31 days
      });
    });

    // ── arithmetic ───────────────────────────────────────────────────────

    group('addDays / subtractDays', () {
      final d = DateTime(2024, 1, 15);

      test('addDays adds correct number of days', () {
        expect(d.addDays(5).day, 20);
      });

      test('subtractDays subtracts correct number of days', () {
        expect(d.subtractDays(5).day, 10);
      });
    });
  });

  group('NullableDateTimeX', () {
    test('timeAgoOr returns fallback for null', () {
      DateTime? d;
      expect(d.timeAgoOr('N/A'), 'N/A');
    });

    test('timeAgoOr returns timeAgo for non-null', () {
      final d = DateTime.now().subtract(const Duration(seconds: 10));
      expect(d.timeAgoOr('N/A'), 'just now');
    });

    test('formatOr returns fallback for null', () {
      DateTime? d;
      expect(d.formatOr('dd/MM/yyyy'), '—');
    });

    test('formatOr returns formatted string for non-null', () {
      final d = DateTime(2024, 1, 14);
      expect(d.formatOr('yyyy-MM-dd'), '2024-01-14');
    });
  });
}
