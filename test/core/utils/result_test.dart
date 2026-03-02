import 'package:app_kit/app_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    // ── Constructors & flags ───────────────────────────────────────────────

    group('constructors', () {
      test('Result.success sets isSuccess=true and data', () {
        final r = Result.success(42);
        expect(r.isSuccess, isTrue);
        expect(r.isFailure, isFalse);
        expect(r.data, 42);
        expect(r.error, isNull);
      });

      test('Result.failure sets isFailure=true and error', () {
        const r = Result<int>.failure('oops');
        expect(r.isFailure, isTrue);
        expect(r.isSuccess, isFalse);
        expect(r.error, 'oops');
        expect(r.data, isNull);
      });

      test('Result.success with null data is still a success', () {
        const r = Result<String?>.success(null);
        expect(r.isSuccess, isTrue);
      });
    });

    // ── when ──────────────────────────────────────────────────────────────

    group('when()', () {
      test('calls onSuccess branch for a success result', () {
        final r = Result.success('hello');
        final out = r.when(onSuccess: (d) => 'ok:$d', onFailure: (_) => 'fail');
        expect(out, 'ok:hello');
      });

      test('calls onFailure branch for a failure result', () {
        const r = Result<String>.failure('bad');
        final out = r.when(onSuccess: (_) => 'ok', onFailure: (e) => 'fail:$e');
        expect(out, 'fail:bad');
      });
    });

    // ── map ───────────────────────────────────────────────────────────────

    group('map()', () {
      test('transforms data on success', () {
        final r = Result.success(5);
        final mapped = r.map((d) => d! * 2);
        expect(mapped.isSuccess, isTrue);
        expect(mapped.data, 10);
      });

      test('propagates failure without calling transform', () {
        const r = Result<int>.failure('err');
        bool called = false;
        final mapped = r.map((d) {
          called = true;
          return 99;
        });
        expect(called, isFalse);
        expect(mapped.isFailure, isTrue);
        expect(mapped.error, 'err');
      });
    });

    // ── mapError ──────────────────────────────────────────────────────────

    group('mapError()', () {
      test('transforms the error message on failure', () {
        const r = Result<int>.failure('raw error');
        final mapped = r.mapError((e) => e.toUpperCase());
        expect(mapped.error, 'RAW ERROR');
      });

      test('passes through success unchanged', () {
        final r = Result.success(7);
        final mapped = r.mapError((e) => 'should not run');
        expect(mapped.isSuccess, isTrue);
        expect(mapped.data, 7);
      });
    });

    // ── getOrNull / getOrElse / getOrThrow ────────────────────────────────

    group('getOrNull()', () {
      test('returns data on success', () {
        expect(Result.success(3).getOrNull(), 3);
      });

      test('returns null on failure', () {
        expect(const Result<int>.failure('err').getOrNull(), isNull);
      });
    });

    group('getOrElse()', () {
      test('returns data on success', () {
        expect(Result.success(3).getOrElse(0), 3);
      });

      test('returns fallback on failure', () {
        expect(const Result<int>.failure('err').getOrElse(99), 99);
      });

      test('returns fallback when data is null', () {
        expect(const Result<int?>.success(null).getOrElse(0), 0);
      });
    });

    group('getOrThrow()', () {
      test('returns data on success', () {
        expect(Result.success('hi').getOrThrow(), 'hi');
      });

      test('throws StateError on failure', () {
        expect(
          () => const Result<String>.failure('bad').getOrThrow(),
          throwsA(isA<StateError>()),
        );
      });

      test('error message is included in StateError', () {
        expect(
          () => const Result<String>.failure('network error').getOrThrow(),
          throwsA(predicate<StateError>((e) => e.message == 'network error')),
        );
      });
    });

    // ── fold ──────────────────────────────────────────────────────────────

    group('fold()', () {
      test('is an alias for when() — success path', () {
        final r = Result.success(1);
        expect(r.fold((d) => 'yes', (e) => 'no'), 'yes');
      });

      test('is an alias for when() — failure path', () {
        const r = Result<int>.failure('x');
        expect(r.fold((d) => 'yes', (e) => 'no:$e'), 'no:x');
      });
    });

    // ── andThen ───────────────────────────────────────────────────────────

    group('andThen()', () {
      test('chains next operation on success', () async {
        final r = Result.success(5);
        final result = await r.andThen((d) async => Result.success(d! * 2));
        expect(result.data, 10);
      });

      test('skips next operation on failure', () async {
        const r = Result<int>.failure('err');
        bool called = false;
        final result = await r.andThen((d) async {
          called = true;
          return Result.success(99);
        });
        expect(called, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.error, 'err');
      });

      test('propagates nested failure', () async {
        final r = Result.success(1);
        final result = await r.andThen(
          (_) async => const Result<int>.failure('downstream error'),
        );
        expect(result.isFailure, isTrue);
        expect(result.error, 'downstream error');
      });
    });

    // ── toString ──────────────────────────────────────────────────────────

    group('toString()', () {
      test('success format', () {
        expect(Result.success(42).toString(), 'Result.success(42)');
      });

      test('failure format', () {
        expect(
          const Result<int>.failure('oops').toString(),
          'Result.failure(oops)',
        );
      });
    });
  });
}
