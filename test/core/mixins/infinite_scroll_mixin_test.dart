import 'package:app_kit/core/mixins/infinite_scroll_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked/stacked.dart';

class _TestScrollViewModel extends BaseViewModel with InfiniteScrollMixin {
  int endReachedCount = 0;

  @override
  void onEndReached() => endReachedCount++;
}

void main() {
  group('InfiniteScrollMixin', () {
    late _TestScrollViewModel vm;

    setUp(() => vm = _TestScrollViewModel());
    tearDown(() => vm.dispose());

    // ── scrollController ─────────────────────────────────────────────────

    test('scrollController is not null', () {
      expect(vm.scrollController, isNotNull);
    });

    test('scrollController is a ScrollController instance', () {
      expect(vm.scrollController, isA<ScrollController>());
    });

    // ── scrollThreshold ──────────────────────────────────────────────────

    test('scrollThreshold defaults to 200.0', () {
      expect(vm.scrollThreshold, 200.0);
    });

    // ── resetScrollState ─────────────────────────────────────────────────

    test('resetScrollState() does not throw', () {
      expect(() => vm.resetScrollState(), returnsNormally);
    });

    // ── onEndReached (direct call) ────────────────────────────────────────

    test('onEndReached fires and increments counter', () {
      expect(vm.endReachedCount, 0);
      vm.onEndReached();
      expect(vm.endReachedCount, 1);
    });

    // ── scroll-based trigger via widget tests ─────────────────────────────

    testWidgets(
      'onEndReached is called when scroll reaches threshold',
      (tester) async {
        final scrollVm = _TestScrollViewModel();
        addTearDown(scrollVm.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollVm.scrollController,
                itemCount: 50,
                itemBuilder: (_, i) =>
                    SizedBox(height: 60, child: Text('Item $i')),
              ),
            ),
          ),
        );

        // Jump to within the threshold from the bottom.
        final maxExtent =
            scrollVm.scrollController.position.maxScrollExtent;
        scrollVm.scrollController.jumpTo(
          maxExtent - (scrollVm.scrollThreshold - 1),
        );
        await tester.pump();

        expect(scrollVm.endReachedCount, 1);
      },
    );

    testWidgets(
      'onEndReached is NOT called again before resetScrollState()',
      (tester) async {
        final scrollVm = _TestScrollViewModel();
        addTearDown(scrollVm.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollVm.scrollController,
                itemCount: 50,
                itemBuilder: (_, i) =>
                    SizedBox(height: 60, child: Text('Item $i')),
              ),
            ),
          ),
        );

        final maxExtent =
            scrollVm.scrollController.position.maxScrollExtent;

        // First trigger.
        scrollVm.scrollController.jumpTo(maxExtent);
        await tester.pump();
        expect(scrollVm.endReachedCount, 1);

        // Scroll back up, then to the bottom again — guard must block a
        // second fire until resetScrollState() is called.
        scrollVm.scrollController.jumpTo(maxExtent - 1000);
        await tester.pump();
        scrollVm.scrollController.jumpTo(maxExtent);
        await tester.pump();

        expect(scrollVm.endReachedCount, 1); // still 1
      },
    );

    testWidgets(
      'resetScrollState() allows onEndReached to fire again',
      (tester) async {
        final scrollVm = _TestScrollViewModel();
        addTearDown(scrollVm.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollVm.scrollController,
                itemCount: 50,
                itemBuilder: (_, i) =>
                    SizedBox(height: 60, child: Text('Item $i')),
              ),
            ),
          ),
        );

        final maxExtent =
            scrollVm.scrollController.position.maxScrollExtent;

        // First trigger.
        scrollVm.scrollController.jumpTo(maxExtent);
        await tester.pump();
        expect(scrollVm.endReachedCount, 1);

        // Re-arm the guard.
        scrollVm.resetScrollState();

        // Scroll back to the top then to the bottom again.
        scrollVm.scrollController.jumpTo(0);
        await tester.pump();
        scrollVm.scrollController.jumpTo(maxExtent);
        await tester.pump();

        expect(scrollVm.endReachedCount, 2); // fired again after reset
      },
    );

    // ── dispose ───────────────────────────────────────────────────────────

    test('dispose() does not throw', () {
      final disposeVm = _TestScrollViewModel();
      expect(() => disposeVm.dispose(), returnsNormally);
    });

    test('scrollController has no clients after dispose()', () {
      final disposeVm = _TestScrollViewModel();
      final controller = disposeVm.scrollController;
      disposeVm.dispose();
      expect(controller.hasClients, isFalse);
    });
  });
}
