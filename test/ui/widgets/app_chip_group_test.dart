import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppChipGroup<String>', () {
    const items = ['Red', 'Green', 'Blue'];
    String label(String s) => s;

    // ── Rendering ──────────────────────────────────────────────────────────

    testWidgets('renders all items as chips', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppChipGroup<String>(
          items: items,
          displayLabel: label,
          selected: const [],
          onChanged: (_) {},
        ),
      ));
      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('pre-selected items show a check icon', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppChipGroup<String>(
          items: items,
          displayLabel: label,
          selected: const ['Red'],
          onChanged: (_) {},
        ),
      ));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    // ── Multi-select ───────────────────────────────────────────────────────

    testWidgets('tapping an unselected chip adds it to selection', (tester) async {
      List<String> result = [];
      await tester.pumpWidget(wrapWidget(
        AppChipGroup<String>(
          items: items,
          displayLabel: label,
          selected: const [],
          onChanged: (v) => result = List.from(v),
        ),
      ));

      await tester.tap(find.text('Green'));
      await tester.pump();
      expect(result, contains('Green'));
    });

    testWidgets('tapping a selected chip removes it', (tester) async {
      List<String> result = ['Blue'];
      await tester.pumpWidget(wrapWidget(
        AppChipGroup<String>(
          items: items,
          displayLabel: label,
          selected: const ['Blue'],
          onChanged: (v) => result = List.from(v),
        ),
      ));

      await tester.tap(find.text('Blue'));
      await tester.pump();
      expect(result, isNot(contains('Blue')));
    });

    testWidgets('multiple chips can be selected simultaneously', (tester) async {
      List<String> result = [];
      await tester.pumpWidget(wrapWidget(
        AppChipGroup<String>(
          items: items,
          displayLabel: label,
          selected: const [],
          onChanged: (v) => result = List.from(v),
        ),
      ));

      await tester.tap(find.text('Red'));
      await tester.pump();
      await tester.tap(find.text('Blue'));
      await tester.pump();

      expect(result, containsAll(['Red', 'Blue']));
    });

    // ── Single-select ──────────────────────────────────────────────────────

    testWidgets('singleSelect=true replaces existing selection', (tester) async {
      List<String> result = ['Red'];
      await tester.pumpWidget(wrapWidget(
        AppChipGroup<String>(
          items: items,
          displayLabel: label,
          selected: const ['Red'],
          singleSelect: true,
          onChanged: (v) => result = List.from(v),
        ),
      ));

      await tester.tap(find.text('Green'));
      await tester.pump();

      expect(result, equals(['Green']));
    });

    testWidgets('singleSelect=true deselects when same chip is tapped',
        (tester) async {
      List<String> result = ['Red'];
      await tester.pumpWidget(wrapWidget(
        AppChipGroup<String>(
          items: items,
          displayLabel: label,
          selected: const ['Red'],
          singleSelect: true,
          onChanged: (v) => result = List.from(v),
        ),
      ));

      await tester.tap(find.text('Red'));
      await tester.pump();

      expect(result, isEmpty);
    });

    // ── Disabled ───────────────────────────────────────────────────────────

    testWidgets('disabled=true prevents selection changes', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(wrapWidget(
        AppChipGroup<String>(
          items: items,
          displayLabel: label,
          selected: const [],
          enabled: false,
          onChanged: (_) => callCount++,
        ),
      ));

      await tester.tap(find.text('Red'), warnIfMissed: false);
      await tester.pump();
      expect(callCount, 0);
    });

    // ── Int items ──────────────────────────────────────────────────────────

    testWidgets('works with int items', (tester) async {
      List<int> result = [];
      await tester.pumpWidget(wrapWidget(
        AppChipGroup<int>(
          items: const [1, 2, 3],
          displayLabel: (n) => '$n',
          selected: const [],
          onChanged: (v) => result = List.from(v),
        ),
      ));

      await tester.tap(find.text('2'));
      await tester.pump();
      expect(result, contains(2));
    });
  });
}
