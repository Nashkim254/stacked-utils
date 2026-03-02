import 'package:app_kit/app_kit.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debouncer', () {
    test('executes action after delay', () {
      fakeAsync((async) {
        int count = 0;
        final d = Debouncer(delay: const Duration(milliseconds: 300));
        d(() => count++);
        expect(count, 0);
        async.elapse(const Duration(milliseconds: 300));
        expect(count, 1);
        d.dispose();
      });
    });

    test('only the last call fires when called rapidly', () {
      fakeAsync((async) {
        int count = 0;
        final d = Debouncer(delay: const Duration(milliseconds: 300));
        d(() => count++);
        d(() => count++);
        d(() => count++);
        async.elapse(const Duration(milliseconds: 300));
        expect(count, 1);
        d.dispose();
      });
    });

    test('isPending is true while timer is active, false after firing', () {
      fakeAsync((async) {
        final d = Debouncer(delay: const Duration(milliseconds: 300));
        expect(d.isPending, isFalse);
        d(() {});
        expect(d.isPending, isTrue);
        async.elapse(const Duration(milliseconds: 300));
        expect(d.isPending, isFalse);
        d.dispose();
      });
    });

    test('cancel() prevents the action from running', () {
      fakeAsync((async) {
        int count = 0;
        final d = Debouncer(delay: const Duration(milliseconds: 300));
        d(() => count++);
        d.cancel();
        async.elapse(const Duration(milliseconds: 300));
        expect(count, 0);
        d.dispose();
      });
    });

    test('dispose() cancels pending action', () {
      fakeAsync((async) {
        int count = 0;
        final d = Debouncer(delay: const Duration(milliseconds: 300));
        d(() => count++);
        d.dispose();
        async.elapse(const Duration(milliseconds: 300));
        expect(count, 0);
      });
    });
  });

  group('Throttler', () {
    test('executes action immediately on first call', () {
      fakeAsync((async) {
        int count = 0;
        final t = Throttler(interval: const Duration(milliseconds: 500));
        t(() => count++);
        expect(count, 1);
        t.dispose();
      });
    });

    test('blocks calls within the interval', () {
      fakeAsync((async) {
        int count = 0;
        final t = Throttler(interval: const Duration(milliseconds: 500));
        t(() => count++); // fires
        t(() => count++); // blocked
        t(() => count++); // blocked
        expect(count, 1);
        t.dispose();
      });
    });

    test('allows another call after interval elapses', () {
      fakeAsync((async) {
        int count = 0;
        final t = Throttler(interval: const Duration(milliseconds: 500));
        t(() => count++);
        async.elapse(const Duration(milliseconds: 500));
        t(() => count++);
        expect(count, 2);
        t.dispose();
      });
    });
  });
}
