import 'package:app_kit/app_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    // ── required ──────────────────────────────────────────────────────────

    group('required()', () {
      test('returns null for non-empty string', () {
        expect(Validators.required('hello'), isNull);
      });

      test('returns error for null input', () {
        expect(Validators.required(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.required(''), isNotNull);
      });

      test('returns error for whitespace-only string', () {
        expect(Validators.required('   '), isNotNull);
      });

      test('accepts custom error message', () {
        expect(
          Validators.required(null, message: 'Custom error'),
          'Custom error',
        );
      });
    });

    // ── email ─────────────────────────────────────────────────────────────

    group('email()', () {
      test('returns null for valid email', () {
        expect(Validators.email('user@example.com'), isNull);
        expect(Validators.email('user.name+tag@domain.co'), isNull);
        expect(Validators.email('a@b.io'), isNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('missing@tld'), isNotNull);
        expect(Validators.email('@nodomain.com'), isNotNull);
        expect(Validators.email(''), isNotNull);
        expect(Validators.email(null), isNotNull);
      });
    });

    // ── phone ─────────────────────────────────────────────────────────────

    group('phone()', () {
      test('returns null for 10+ digit phone', () {
        expect(Validators.phone('0801234567'), isNull);
        expect(Validators.phone('08012345678'), isNull);
        expect(Validators.phone('+1 (800) 555-1234'), isNull);
      });

      test('returns error for fewer than 10 digits', () {
        expect(Validators.phone('123456789'), isNotNull); // 9 digits
        expect(Validators.phone(''), isNotNull);
        expect(Validators.phone(null), isNotNull);
      });
    });

    // ── minLength ─────────────────────────────────────────────────────────

    group('minLength()', () {
      test('returns null at or above minimum', () {
        expect(Validators.minLength('abcd', 4), isNull);
        expect(Validators.minLength('abcde', 4), isNull);
      });

      test('returns error below minimum', () {
        expect(Validators.minLength('abc', 4), isNotNull);
        expect(Validators.minLength('', 1), isNotNull);
        expect(Validators.minLength(null, 1), isNotNull);
      });

      test('error message contains minimum value', () {
        final msg = Validators.minLength('ab', 5);
        expect(msg, contains('5'));
      });
    });

    // ── maxLength ─────────────────────────────────────────────────────────

    group('maxLength()', () {
      test('returns null at or below maximum', () {
        expect(Validators.maxLength('hello', 5), isNull);
        expect(Validators.maxLength('hi', 5), isNull);
        expect(Validators.maxLength(null, 5), isNull);
      });

      test('returns error above maximum', () {
        expect(Validators.maxLength('toolongstring', 5), isNotNull);
      });
    });

    // ── password ──────────────────────────────────────────────────────────

    group('password()', () {
      test('returns null for 8+ char password', () {
        expect(Validators.password('password'), isNull);
        expect(Validators.password('longerpassword'), isNull);
      });

      test('returns error for fewer than 8 characters', () {
        expect(Validators.password('short'), isNotNull);
        expect(Validators.password(''), isNotNull);
        expect(Validators.password(null), isNotNull);
      });
    });

    // ── confirmPassword ───────────────────────────────────────────────────

    group('confirmPassword()', () {
      test('returns null when passwords match', () {
        expect(Validators.confirmPassword('secret', 'secret'), isNull);
      });

      test('returns error when passwords do not match', () {
        expect(Validators.confirmPassword('secret', 'different'), isNotNull);
        expect(Validators.confirmPassword('secret', null), isNotNull);
        expect(Validators.confirmPassword(null, 'secret'), isNotNull);
      });
    });

    // ── numeric ───────────────────────────────────────────────────────────

    group('numeric()', () {
      test('returns null for valid numeric strings', () {
        expect(Validators.numeric('42'), isNull);
        expect(Validators.numeric('3.14'), isNull);
        expect(Validators.numeric('-7'), isNull);
      });

      test('returns error for non-numeric input', () {
        expect(Validators.numeric('abc'), isNotNull);
        expect(Validators.numeric('12a'), isNotNull);
        expect(Validators.numeric(null), isNotNull);
      });
    });

    // ── url ───────────────────────────────────────────────────────────────

    group('url()', () {
      test('returns null for valid URLs', () {
        expect(Validators.url('https://example.com'), isNull);
        expect(Validators.url('http://sub.domain.co/path?q=1'), isNull);
      });

      test('returns error for invalid URLs', () {
        expect(Validators.url('not-a-url'), isNotNull);
        expect(Validators.url('example.com'), isNotNull); // no scheme
        expect(Validators.url(''), isNotNull);
        expect(Validators.url(null), isNotNull);
      });
    });

    // ── compose ───────────────────────────────────────────────────────────

    group('compose()', () {
      test('returns null when all validators pass', () {
        final validator = Validators.compose([
          Validators.required,
          (v) => Validators.minLength(v, 3),
          (v) => Validators.maxLength(v, 10),
        ]);
        expect(validator('hello'), isNull);
      });

      test('returns the first error when a validator fails', () {
        final validator = Validators.compose([
          Validators.required,
          (v) => Validators.minLength(v, 8),
        ]);
        final result = validator('hi');
        expect(result, isNotNull);
        // Should be the minLength error (required passed)
        expect(result, contains('8'));
      });

      test('returns required error when input is empty', () {
        final validator = Validators.compose([
          Validators.required,
          (v) => Validators.minLength(v, 4),
        ]);
        expect(validator(''), 'This field is required');
      });

      test('returns null for empty list of validators', () {
        final validator = Validators.compose([]);
        expect(validator('anything'), isNull);
      });
    });
  });
}
