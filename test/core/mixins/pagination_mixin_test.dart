import 'package:app_kit/app_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked/stacked.dart';

class _VM extends BaseViewModel with PaginationMixin {}

void main() {
  group('PaginationMixin', () {
    late _VM vm;

    setUp(() => vm = _VM());
    tearDown(() => vm.dispose());

    // ── initial state ────────────────────────────────────────────────────

    test('initial state', () {
      expect(vm.currentPage, 1);
      expect(vm.hasMore, isTrue);
      expect(vm.isLoadingMore, isFalse);
      expect(vm.pageSize, 20);
    });

    // ── resetPagination ──────────────────────────────────────────────────

    test('resetPagination restores defaults', () async {
      // Move state away from defaults via loadFirstPage
      await vm.loadFirstPage(
        fetcher: (_) async => List.generate(20, (i) => i),
        onSuccess: (_) {},
      );
      await vm.loadNextPage(
        fetcher: (_) async => List.generate(20, (i) => i),
        onSuccess: (_) {},
      );
      expect(vm.currentPage, 2);

      vm.resetPagination();

      expect(vm.currentPage, 1);
      expect(vm.hasMore, isTrue);
      expect(vm.isLoadingMore, isFalse);
    });

    // ── loadFirstPage ────────────────────────────────────────────────────

    test('loadFirstPage resets to page 1 and calls fetcher', () async {
      final pages = <int>[];
      await vm.loadFirstPage(
        fetcher: (page) async {
          pages.add(page);
          return List.generate(5, (i) => i);
        },
        onSuccess: (_) {},
      );
      expect(pages, [1]);
      expect(vm.currentPage, 1);
    });

    test('loadFirstPage sets hasMore=true when items == pageSize', () async {
      vm.pageSize = 5;
      await vm.loadFirstPage(
        fetcher: (_) async => [1, 2, 3, 4, 5],
        onSuccess: (_) {},
      );
      expect(vm.hasMore, isTrue);
    });

    test('loadFirstPage sets hasMore=false when items < pageSize', () async {
      vm.pageSize = 20;
      await vm.loadFirstPage(
        fetcher: (_) async => [1, 2, 3],
        onSuccess: (_) {},
      );
      expect(vm.hasMore, isFalse);
    });

    test('loadFirstPage calls onSuccess with fetched items', () async {
      final received = <int>[];
      await vm.loadFirstPage(
        fetcher: (_) async => [10, 20, 30],
        onSuccess: (items) => received.addAll(items),
      );
      expect(received, [10, 20, 30]);
    });

    test('loadFirstPage calls onError on exception', () async {
      String? err;
      await vm.loadFirstPage(
        fetcher: (_) async => throw Exception('fail'),
        onSuccess: (_) {},
        onError: (e) => err = e,
      );
      expect(err, isNotNull);
      expect(err, contains('fail'));
    });

    // ── loadNextPage ─────────────────────────────────────────────────────

    test('loadNextPage increments page number', () async {
      vm.pageSize = 5;
      await vm.loadFirstPage(
        fetcher: (_) async => [1, 2, 3, 4, 5],
        onSuccess: (_) {},
      );
      expect(vm.currentPage, 1);

      await vm.loadNextPage(
        fetcher: (page) async {
          expect(page, 2);
          return [];
        },
        onSuccess: (_) {},
      );
      expect(vm.currentPage, 2);
    });

    test('loadNextPage is a no-op when hasMore=false', () async {
      vm.pageSize = 20;
      await vm.loadFirstPage(
        fetcher: (_) async => [1, 2], // < pageSize → hasMore=false
        onSuccess: (_) {},
      );
      expect(vm.hasMore, isFalse);

      int fetches = 0;
      await vm.loadNextPage(
        fetcher: (_) async { fetches++; return []; },
        onSuccess: (_) {},
      );
      expect(fetches, 0);
    });

    test('loadNextPage rolls back page number on error', () async {
      vm.pageSize = 5;
      await vm.loadFirstPage(
        fetcher: (_) async => [1, 2, 3, 4, 5],
        onSuccess: (_) {},
      );
      expect(vm.currentPage, 1);

      String? err;
      await vm.loadNextPage(
        fetcher: (_) async => throw Exception('network error'),
        onSuccess: (_) {},
        onError: (e) => err = e,
      );

      expect(vm.currentPage, 1); // rolled back
      expect(err, isNotNull);
    });

    test('loadNextPage sets hasMore=false when items < pageSize', () async {
      vm.pageSize = 5;
      await vm.loadFirstPage(
        fetcher: (_) async => [1, 2, 3, 4, 5],
        onSuccess: (_) {},
      );

      await vm.loadNextPage(
        fetcher: (_) async => [1, 2], // < pageSize
        onSuccess: (_) {},
      );

      expect(vm.hasMore, isFalse);
    });
  });
}
