import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kit/ui/shared/app_multi_select.dart';

import '../../helpers.dart';

// ── fixtures ──────────────────────────────────────────────────────────────────

const _items = ['Nigeria', 'Ghana', 'Kenya', 'South Africa', 'Egypt'];

// ── factory helper ────────────────────────────────────────────────────────────

Widget _build({
  List<String> values = const [],
  ValueChanged<List<String>>? onChanged,
  String? Function(List<String>?)? validator,
  int? maxSelections,
  bool enabled = true,
  bool searchable = true,
}) {
  return wrapWidget(
    AppMultiSelect<String>(
      label: 'Countries',
      items: _items,
      displayLabel: (c) => c,
      values: values,
      onChanged: onChanged ?? (_) {},
      validator: validator,
      maxSelections: maxSelections,
      enabled: enabled,
      searchable: searchable,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('AppMultiSelect', () {
    // ── Rendering — idle ──────────────────────────────────────────────────

    testWidgets('renders the label text', (tester) async {
      await tester.pumpWidget(_build());
      expect(find.text('Countries'), findsOneWidget);
    });

    testWidgets('shows hint when nothing is selected', (tester) async {
      await tester.pumpWidget(_build());
      // Default hint is 'Select…'
      expect(find.text('Select…'), findsOneWidget);
    });

    testWidgets('shows dropdown arrow when no items are selected', (tester) async {
      await tester.pumpWidget(_build());
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('does not show hint when items are selected', (tester) async {
      await tester.pumpWidget(_build(values: ['Ghana']));
      expect(find.text('Select…'), findsNothing);
    });

    // ── Selected count display ────────────────────────────────────────────

    testWidgets('shows label directly when 1 item is selected', (tester) async {
      await tester.pumpWidget(_build(values: ['Ghana']));
      expect(find.text('Ghana'), findsOneWidget);
    });

    testWidgets('shows comma-joined labels when 2 items are selected',
        (tester) async {
      await tester.pumpWidget(_build(values: ['Ghana', 'Kenya']));
      expect(find.text('Ghana, Kenya'), findsOneWidget);
    });

    testWidgets('shows "N selected" text when 3+ items are selected',
        (tester) async {
      await tester.pumpWidget(
        _build(values: ['Ghana', 'Kenya', 'Nigeria']),
      );
      expect(find.text('3 selected'), findsOneWidget);
    });

    testWidgets('shows "4 selected" when 4 items are selected', (tester) async {
      await tester.pumpWidget(
        _build(values: ['Ghana', 'Kenya', 'Nigeria', 'Egypt']),
      );
      expect(find.text('4 selected'), findsOneWidget);
    });

    // ── Clear icon ────────────────────────────────────────────────────────

    testWidgets('shows clear icon when items are selected', (tester) async {
      await tester.pumpWidget(_build(values: ['Ghana']));
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
    });

    testWidgets('tapping clear icon fires onChanged with empty list',
        (tester) async {
      List<String>? result;
      await tester.pumpWidget(
        _build(
          values: ['Ghana'],
          onChanged: (v) => result = v,
        ),
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(result, isEmpty);
    });

    // ── Bottom sheet ──────────────────────────────────────────────────────

    testWidgets('tapping field opens bottom sheet with all items', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      for (final item in _items) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('bottom sheet shows a search field when searchable=true',
        (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('bottom sheet hides search field when searchable=false',
        (tester) async {
      await tester.pumpWidget(_build(searchable: false));
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsNothing);
    });

    testWidgets('selecting an item in the sheet and pressing Done calls onChanged',
        (tester) async {
      List<String>? result;
      await tester.pumpWidget(
        _build(onChanged: (v) => result = List.from(v)),
      );
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      // Tap the checkbox for Ghana.
      await tester.tap(find.text('Ghana'));
      await tester.pump();

      // Press Done.
      await tester.tap(find.text('Done (1)'));
      await tester.pumpAndSettle();

      expect(result, contains('Ghana'));
      expect(result!.length, 1);
    });

    testWidgets('pre-selected items appear checked in the sheet', (tester) async {
      await tester.pumpWidget(_build(values: ['Kenya']));
      await tester.tap(find.text('Kenya')); // taps the field display text
      await tester.pumpAndSettle();

      // The CheckboxListTile for Kenya should have value=true.
      final tile = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Kenya'),
      );
      expect(tile.value, isTrue);
    });

    // ── Search inside sheet ───────────────────────────────────────────────

    testWidgets('typing in the search field filters the list', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'gh');
      await tester.pump();

      expect(find.text('Ghana'), findsOneWidget);
      expect(find.text('Nigeria'), findsNothing);
    });

    testWidgets('clearing search shows all items again', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'gh');
      await tester.pump();
      expect(find.text('Nigeria'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.text('Nigeria'), findsOneWidget);
    });

    testWidgets('no-results text shown for unmatched search', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();

      expect(find.text('No results found'), findsOneWidget);
    });

    // ── Select All / Clear ────────────────────────────────────────────────

    testWidgets('"Select All" button selects all visible items', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select All'));
      await tester.pump();

      // After selecting all, button label changes to "Clear".
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('"Clear" button deselects all visible items', (tester) async {
      await tester.pumpWidget(_build(values: List.from(_items)));
      await tester.tap(find.text('5 selected'));
      await tester.pumpAndSettle();

      // All are selected → button shows "Clear".
      expect(find.text('Clear'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pump();

      // After clearing → button reverts to "Select All".
      expect(find.text('Select All'), findsOneWidget);
    });

    // ── Disabled ──────────────────────────────────────────────────────────

    testWidgets('disabled field renders without crashing', (tester) async {
      await tester.pumpWidget(_build(enabled: false));
      expect(find.text('Countries'), findsOneWidget);
    });

    testWidgets('disabled field does not open sheet on tap', (tester) async {
      await tester.pumpWidget(_build(enabled: false));
      await tester.tap(find.text('Countries'));
      await tester.pumpAndSettle();

      // Bottom sheet items should not be present.
      expect(find.text('Nigeria'), findsNothing);
    });

    // ── Validation ────────────────────────────────────────────────────────

    testWidgets('validator fires and shows error when nothing is selected',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        wrapWidget(
          Form(
            key: formKey,
            child: AppMultiSelect<String>(
              label: 'Countries',
              items: _items,
              displayLabel: (c) => c,
              values: const [],
              onChanged: (_) {},
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please select at least one' : null,
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please select at least one'), findsOneWidget);
    });

    testWidgets('validator passes when selection is non-empty', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        wrapWidget(
          Form(
            key: formKey,
            child: AppMultiSelect<String>(
              label: 'Countries',
              items: _items,
              displayLabel: (c) => c,
              values: const ['Ghana'],
              onChanged: (_) {},
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please select at least one' : null,
            ),
          ),
        ),
      );

      final isValid = formKey.currentState!.validate();
      await tester.pump();

      expect(isValid, isTrue);
      expect(find.text('Please select at least one'), findsNothing);
    });

    // ── maxSelections cap ─────────────────────────────────────────────────

    testWidgets('maxSelections is respected in the bottom sheet', (tester) async {
      List<String>? result;
      await tester.pumpWidget(
        _build(maxSelections: 2, onChanged: (v) => result = List.from(v)),
      );
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ghana'));
      await tester.pump();
      await tester.tap(find.text('Kenya'));
      await tester.pump();
      // Third tap should be ignored because cap is 2.
      await tester.tap(find.text('Nigeria'));
      await tester.pump();

      await tester.tap(find.text('Done (2)'));
      await tester.pumpAndSettle();

      expect(result!.length, 2);
      expect(result, containsAll(['Ghana', 'Kenya']));
      expect(result, isNot(contains('Nigeria')));
    });
  });
}
