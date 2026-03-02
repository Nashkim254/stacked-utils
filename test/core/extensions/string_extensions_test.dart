import 'package:app_kit/app_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringX', () {
    group('titleCase', () {
      test('capitalises each word', () {
        expect('hello world'.titleCase, 'Hello World');
        expect('dart is great'.titleCase, 'Dart Is Great');
      });
      test('handles single word', () => expect('hello'.titleCase, 'Hello'));
      test('lowercases remaining chars', () => expect('hELLO'.titleCase, 'Hello'));
    });

    group('capitalized', () {
      test('uppercases first char only', () {
        expect('hello world'.capitalized, 'Hello world');
      });
      test('empty string returns empty', () => expect(''.capitalized, ''));
    });

    group('truncate()', () {
      test('returns original when within limit', () {
        expect('hello'.truncate(10), 'hello');
        expect('hello'.truncate(5), 'hello');
      });
      test('truncates and appends ellipsis', () {
        expect('hello world'.truncate(5), 'hello…');
      });
      test('supports custom ellipsis', () {
        expect('hello world'.truncate(5, ellipsis: '...'), 'hello...');
      });
    });

    group('initials', () {
      test('two-word name returns two initials', () {
        expect('John Doe'.initials, 'JD');
      });
      test('single word returns one initial', () {
        expect('Alice'.initials, 'A');
      });
      test('multi-word uses first and last', () {
        expect('Bob Jones Smith'.initials, 'BS');
      });
      test('uppercases the result', () {
        expect('john doe'.initials, 'JD');
      });
    });

    group('maskPhone()', () {
      test('masks all but last 4 digits', () {
        expect('08012345678'.maskPhone(), '•••••••5678');
      });
      test('respects custom visible count', () {
        expect('08012345678'.maskPhone(visible: 6), '•••••345678');
      });
      test('returns digits unchanged when length <= visible', () {
        expect('123'.maskPhone(visible: 4), '123');
      });
    });

    group('maskedCard', () {
      test('shows last 4 digits in card format', () {
        expect('4111111111111111'.maskedCard, '•••• •••• •••• 1111');
      });
      test('handles short input (< 4 digits)', () {
        expect('12'.maskedCard, '12');
      });
    });

    group('isValidEmail', () {
      test('valid emails return true', () {
        expect('user@example.com'.isValidEmail, isTrue);
        expect('a@b.io'.isValidEmail, isTrue);
      });
      test('invalid emails return false', () {
        expect('notanemail'.isValidEmail, isFalse);
        expect('missing@tld'.isValidEmail, isFalse);
        expect(''.isValidEmail, isFalse);
      });
    });

    group('isValidPhone', () {
      test('returns true for 10+ digit strings', () {
        expect('0801234567'.isValidPhone, isTrue);
        expect('+1 (800) 555-1234'.isValidPhone, isTrue);
      });
      test('returns false for fewer than 10 digits', () {
        expect('12345'.isValidPhone, isFalse);
      });
    });

    group('isValidUrl', () {
      test('valid URLs return true', () {
        expect('https://example.com'.isValidUrl, isTrue);
        expect('http://sub.domain.co/path'.isValidUrl, isTrue);
      });
      test('invalid URLs return false', () {
        expect('not-a-url'.isValidUrl, isFalse);
        expect('example.com'.isValidUrl, isFalse);
      });
    });

    group('digitsOnly', () {
      test('strips non-digit characters', () {
        expect('+1 (800) 555-1234'.digitsOnly, '18005551234');
        expect('abc'.digitsOnly, '');
      });
    });

    group('nullIfEmpty', () {
      test('returns null for empty string', () => expect(''.nullIfEmpty, isNull));
      test('returns self for non-empty string', () {
        expect('hello'.nullIfEmpty, 'hello');
      });
    });

    group('normalized', () {
      test('trims and collapses whitespace', () {
        expect('  hello   world  '.normalized, 'hello world');
      });
    });
  });

  group('NullableStringX', () {
    test('isNullOrEmpty is true for null', () {
      String? s;
      expect(s.isNullOrEmpty, isTrue);
    });
    test('isNullOrEmpty is true for empty', () {
      expect(''.isNullOrEmpty, isTrue);
    });
    test('isNullOrEmpty is false for non-empty', () {
      expect('hi'.isNullOrEmpty, isFalse);
    });
    test('isNotNullOrEmpty is the inverse', () {
      String? s;
      expect(s.isNotNullOrEmpty, isFalse);
      expect('hi'.isNotNullOrEmpty, isTrue);
    });
    test('orEmpty returns empty string for null', () {
      String? s;
      expect(s.orEmpty, '');
    });
    test('orEmpty returns the string when non-null', () {
      expect('hi'.orEmpty, 'hi');
    });
  });
}
