import 'package:app_kit/app_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumX', () {
    group('toCurrency()', () {
      test('formats with symbol and 2 decimal places', () {
        expect(1200.50.toCurrency(symbol: '₦'), '₦1,200.50');
      });
      test('formats without symbol', () {
        expect(1000.0.toCurrency(), '1,000.00');
      });
      test('respects custom decimal places', () {
        expect(1000.0.toCurrency(symbol: '\$', decimalPlaces: 0), '\$1,000');
      });
      test('handles zero', () {
        expect(0.0.toCurrency(symbol: '\$'), '\$0.00');
      });
    });

    group('compact', () {
      test('< 1000 returns plain number', () {
        expect(999.compact, '999');
        expect(1.compact, '1');
      });
      test('thousands use "k" suffix', () {
        expect(1200.compact, '1.2k');
        expect(5000.compact, '5.0k');
      });
      test('millions use "M" suffix', () {
        expect(3400000.compact, '3.4M');
      });
      test('billions use "B" suffix', () {
        expect(2100000000.compact, '2.1B');
      });
      test('negative numbers keep sign', () {
        expect((-1500).compact, '-1.5k');
      });
    });

    group('toPercent()', () {
      test('multiplies by 100 by default', () {
        expect(0.756.toPercent(), '75.6%');
      });
      test('does not multiply when multiply=false', () {
        expect(75.6.toPercent(multiply: false), '75.6%');
      });
      test('respects decimal places', () {
        expect(0.756.toPercent(decimalPlaces: 0), '75.6%');
      });
    });

    group('Duration shorthands', () {
      test('.seconds creates Duration in seconds', () {
        expect(5.seconds, const Duration(seconds: 5));
      });
      test('.milliseconds creates Duration in milliseconds', () {
        expect(300.milliseconds, const Duration(milliseconds: 300));
      });
      test('.minutes creates Duration in minutes', () {
        expect(2.minutes, const Duration(minutes: 2));
      });
    });

    group('checks', () {
      test('isPositive', () {
        expect(5.isPositive, isTrue);
        expect((-1).isPositive, isFalse);
        expect(0.isPositive, isFalse);
      });
      test('isNegative', () {
        expect((-3).isNegative, isTrue);
        expect(1.isNegative, isFalse);
        expect(0.isNegative, isFalse);
      });
      test('isZero', () {
        expect(0.isZero, isTrue);
        expect(1.isZero, isFalse);
      });
    });

    group('clampMin / clampMax', () {
      test('clampMin returns self when above min', () {
        expect(10.clampMin(5), 10);
      });
      test('clampMin returns min when below', () {
        expect(3.clampMin(5), 5);
      });
      test('clampMax returns self when below max', () {
        expect(4.clampMax(10), 4);
      });
      test('clampMax returns max when above', () {
        expect(15.clampMax(10), 10);
      });
    });
  });

  group('IntX', () {
    group('padded()', () {
      test('pads single digit to width 2 by default', () {
        expect(5.padded(), '05');
        expect(9.padded(), '09');
      });
      test('does not pad when already at width', () {
        expect(12.padded(), '12');
      });
      test('custom width', () {
        expect(5.padded(3), '005');
      });
    });

    group('toFileSize', () {
      test('bytes', () {
        expect(512.toFileSize, '512 B');
        expect(1023.toFileSize, '1023 B');
      });
      test('kilobytes', () {
        expect(1024.toFileSize, '1.0 KB');
        expect(2048.toFileSize, '2.0 KB');
      });
      test('megabytes', () {
        expect(1048576.toFileSize, '1.0 MB');
        expect((1.5 * 1024 * 1024).toInt().toFileSize, '1.5 MB');
      });
      test('gigabytes', () {
        expect((1024 * 1024 * 1024).toFileSize, '1.0 GB');
      });
    });
  });
}
