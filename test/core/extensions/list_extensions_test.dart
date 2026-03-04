import 'package:app_kit/core/extensions/list_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── ListX ──────────────────────────────────────────────────────────────────
  group('ListX', () {
    // groupBy ----------------------------------------------------------------
    group('groupBy()', () {
      test('groups items by key', () {
        final result = ['apple', 'avocado', 'banana', 'blueberry', 'cherry']
            .groupBy((s) => s[0]);
        expect(result['a'], ['apple', 'avocado']);
        expect(result['b'], ['banana', 'blueberry']);
        expect(result['c'], ['cherry']);
      });

      test('groups by computed key', () {
        final result = [1, 2, 3, 4, 5].groupBy((n) => n.isEven);
        expect(result[true], [2, 4]);
        expect(result[false], [1, 3, 5]);
      });

      test('empty list returns empty map', () {
        expect(<int>[].groupBy((n) => n), isEmpty);
      });
    });

    // distinctBy -------------------------------------------------------------
    group('distinctBy()', () {
      test('removes duplicates by key and preserves first occurrence', () {
        final input = [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'},
          {'id': 1, 'name': 'Alice-duplicate'},
          {'id': 3, 'name': 'Carol'},
        ];
        final result = input.distinctBy((m) => m['id']);
        expect(result.length, 3);
        expect(result[0]['name'], 'Alice');
        expect(result[1]['name'], 'Bob');
        expect(result[2]['name'], 'Carol');
      });

      test('all unique — returns copy of all elements', () {
        final result = [1, 2, 3].distinctBy((n) => n);
        expect(result, [1, 2, 3]);
      });

      test('empty list returns empty list', () {
        expect(<int>[].distinctBy((n) => n), isEmpty);
      });
    });

    // chunk ------------------------------------------------------------------
    group('chunk()', () {
      test('even split', () {
        expect([1, 2, 3, 4].chunk(2), [
          [1, 2],
          [3, 4],
        ]);
      });

      test('uneven split — last chunk is smaller', () {
        expect([1, 2, 3, 4, 5].chunk(2), [
          [1, 2],
          [3, 4],
          [5],
        ]);
      });

      test('chunk size larger than list — single chunk', () {
        expect([1, 2, 3].chunk(10), [
          [1, 2, 3],
        ]);
      });

      test('chunk size equal to list length', () {
        expect([1, 2, 3].chunk(3), [
          [1, 2, 3],
        ]);
      });

      test('empty list returns empty list', () {
        expect(<int>[].chunk(2), isEmpty);
      });
    });

    // firstWhereOrNull -------------------------------------------------------
    group('firstWhereOrNull()', () {
      test('returns first matching element', () {
        expect([1, 2, 3, 4].firstWhereOrNull((n) => n.isEven), 2);
      });

      test('returns null when no element matches', () {
        expect([1, 3, 5].firstWhereOrNull((n) => n.isEven), isNull);
      });

      test('returns null for empty list', () {
        expect(<int>[].firstWhereOrNull((n) => n > 0), isNull);
      });
    });

    // lastWhereOrNull --------------------------------------------------------
    group('lastWhereOrNull()', () {
      test('returns last matching element', () {
        expect([1, 2, 3, 4].lastWhereOrNull((n) => n.isEven), 4);
      });

      test('returns null when no element matches', () {
        expect([1, 3, 5].lastWhereOrNull((n) => n.isEven), isNull);
      });

      test('returns null for empty list', () {
        expect(<int>[].lastWhereOrNull((n) => n > 0), isNull);
      });
    });

    // sorted -----------------------------------------------------------------
    group('sorted()', () {
      test('returns elements in sorted order', () {
        expect([3, 1, 4, 1, 5].sorted((a, b) => a.compareTo(b)),
            [1, 1, 3, 4, 5]);
      });

      test('does not mutate the original list', () {
        final original = [3, 1, 2];
        final _ = original.sorted((a, b) => a.compareTo(b));
        expect(original, [3, 1, 2]);
      });

      test('reverse sort', () {
        expect([1, 3, 2].sorted((a, b) => b.compareTo(a)), [3, 2, 1]);
      });
    });

    // sortedBy ---------------------------------------------------------------
    group('sortedBy()', () {
      test('sorts strings ascending by length', () {
        final result =
            ['banana', 'fig', 'apple', 'kiwi'].sortedBy((s) => s.length);
        expect(result, ['fig', 'kiwi', 'apple', 'banana']);
      });

      test('sorts integers ascending', () {
        expect([5, 3, 1, 4, 2].sortedBy((n) => n), [1, 2, 3, 4, 5]);
      });

      test('does not mutate the original list', () {
        final original = ['banana', 'apple'];
        final _ = original.sortedBy((s) => s);
        expect(original, ['banana', 'apple']);
      });
    });

    // sortedByDescending -----------------------------------------------------
    group('sortedByDescending()', () {
      test('sorts integers descending', () {
        expect([3, 1, 4, 2].sortedByDescending((n) => n), [4, 3, 2, 1]);
      });

      test('sorts strings descending alphabetically', () {
        expect(['banana', 'apple', 'cherry'].sortedByDescending((s) => s),
            ['cherry', 'banana', 'apple']);
      });
    });

    // mapIndexed -------------------------------------------------------------
    group('mapIndexed()', () {
      test('provides correct index and value', () {
        final result = ['a', 'b', 'c'].mapIndexed((i, v) => '$i:$v');
        expect(result, ['0:a', '1:b', '2:c']);
      });

      test('empty list returns empty list', () {
        expect(<String>[].mapIndexed((i, v) => v), isEmpty);
      });
    });

    // forEachIndexed ---------------------------------------------------------
    group('forEachIndexed()', () {
      test('is called with correct indices and values', () {
        final indices = <int>[];
        final values = <String>[];
        ['x', 'y', 'z'].forEachIndexed((i, v) {
          indices.add(i);
          values.add(v);
        });
        expect(indices, [0, 1, 2]);
        expect(values, ['x', 'y', 'z']);
      });

      test('is not called for empty list', () {
        var called = false;
        <int>[].forEachIndexed((i, v) => called = true);
        expect(called, isFalse);
      });
    });

    // none -------------------------------------------------------------------
    group('none()', () {
      test('returns true when no elements match', () {
        expect([1, 3, 5].none((n) => n.isEven), isTrue);
      });

      test('returns false when at least one element matches', () {
        expect([1, 2, 3].none((n) => n.isEven), isFalse);
      });

      test('returns true for empty list', () {
        expect(<int>[].none((n) => n > 0), isTrue);
      });
    });

    // count ------------------------------------------------------------------
    group('count()', () {
      test('counts matching elements', () {
        expect([1, 2, 3, 4, 5].count((n) => n.isEven), 2);
      });

      test('returns 0 when none match', () {
        expect([1, 3, 5].count((n) => n.isEven), 0);
      });

      test('returns full length when all match', () {
        expect([2, 4, 6].count((n) => n.isEven), 3);
      });

      test('returns 0 for empty list', () {
        expect(<int>[].count((n) => n > 0), 0);
      });
    });
  });

  // ── NumListX ───────────────────────────────────────────────────────────────
  group('NumListX', () {
    group('sum', () {
      test('sums integer values', () {
        expect([1, 2, 3, 4].sum, 10);
      });

      test('sums double values', () {
        expect([1.5, 2.5, 1.0].sum, closeTo(5.0, 1e-10));
      });

      test('returns 0 for empty list', () {
        expect(<num>[].sum, 0);
      });
    });

    group('average', () {
      test('computes the mean', () {
        expect([2, 4, 6].average, closeTo(4.0, 1e-10));
      });

      test('returns 0.0 for empty list', () {
        expect(<num>[].average, 0.0);
      });

      test('handles non-integer mean', () {
        expect([1, 2].average, closeTo(1.5, 1e-10));
      });
    });

    group('min', () {
      test('returns smallest value', () {
        expect([3, 1, 4, 1, 5].min, 1);
      });

      test('works with doubles', () {
        expect([2.5, 0.5, 1.0].min, 0.5);
      });

      test('throws StateError for empty list', () {
        expect(() => <num>[].min, throwsStateError);
      });
    });

    group('max', () {
      test('returns largest value', () {
        expect([3, 1, 4, 1, 5].max, 5);
      });

      test('works with doubles', () {
        expect([2.5, 0.5, 3.5].max, 3.5);
      });

      test('throws StateError for empty list', () {
        expect(() => <num>[].max, throwsStateError);
      });
    });
  });
}
