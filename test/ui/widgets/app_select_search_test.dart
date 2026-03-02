import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

const _items = ['Nigeria', 'Ghana', 'Kenya', 'South Africa', 'Egypt'];

/// Builds the widget under test, optionally tracking [onSelected] calls.
Widget _build({
  String? value,
  ValueChanged<String?>? onSelected,
  String? Function(String?)? validator,
  ValueChanged<String>? onSearchChanged,
}) {
  return wrapWidget(
    AppSelectSearch<String>(
      label: 'Country',
      items: _items,
      displayLabel: (c) => c,
      value: value,
      onSelected: onSelected ?? (_) {},
      validator: validator,
      onSearchChanged: onSearchChanged,
    ),
  );
}

void main() {
  group('AppSelectSearch', () {
    // ── Rendering ────────────────────────────────────────────────────────────

    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_build());
      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('shows search icon when nothing is selected', (tester) async {
      await tester.pumpWidget(_build());
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('displays preset value in the field', (tester) async {
      await tester.pumpWidget(_build(value: 'Ghana'));
      expect(find.text('Ghana'), findsOneWidget);
    });

    testWidgets('shows clear button when a value is pre-set', (tester) async {
      await tester.pumpWidget(_build(value: 'Kenya'));
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsNothing);
    });

    // ── Dropdown open ────────────────────────────────────────────────────────

    testWidgets('tapping field shows all items in overlay', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      for (final item in _items) {
        expect(find.text(item), findsOneWidget);
      }
    });

    // ── Filtering ────────────────────────────────────────────────────────────

    testWidgets('typing filters results in real time', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'gh');
      await tester.pump();

      expect(find.text('Ghana'), findsOneWidget);
      expect(find.text('Nigeria'), findsNothing);
      expect(find.text('Kenya'), findsNothing);
    });

    testWidgets('filter is case-insensitive', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'GHANA');
      await tester.pump();

      expect(find.text('Ghana'), findsOneWidget);
    });

    testWidgets('filter matches substring anywhere in the label', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // 'outh' matches 'South Africa' but nothing else
      await tester.enterText(find.byType(TextFormField), 'outh');
      await tester.pump();

      expect(find.text('South Africa'), findsOneWidget);
      expect(find.text('Nigeria'), findsNothing);
    });

    testWidgets('shows no-results text when query has no matches', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'zzz');
      await tester.pump();

      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('clearing the query shows all items again', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'gh');
      await tester.pump();
      expect(find.text('Nigeria'), findsNothing);

      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();
      expect(find.text('Nigeria'), findsOneWidget);
    });

    // ── Selection ────────────────────────────────────────────────────────────

    testWidgets('tapping an item calls onSelected with the item', (tester) async {
      String? selected;
      await tester.pumpWidget(_build(onSelected: (v) => selected = v));
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      await tester.tap(find.text('Ghana'));
      await tester.pump();

      expect(selected, 'Ghana');
    });

    testWidgets('selected item label appears in the field', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      await tester.tap(find.text('Kenya'));
      await tester.pump();

      expect(find.text('Kenya'), findsOneWidget);
    });

    testWidgets('after selection search icon becomes clear button', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      await tester.tap(find.text('Kenya'));
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsNothing);
    });

    // ── Clear ────────────────────────────────────────────────────────────────

    testWidgets('clear button calls onSelected(null)', (tester) async {
      String? selected = 'Ghana';
      await tester.pumpWidget(
        StatefulBuilder(builder: (ctx, setState) {
          return wrapWidget(AppSelectSearch<String>(
            label: 'Country',
            items: _items,
            displayLabel: (c) => c,
            value: selected,
            onSelected: (v) => setState(() => selected = v),
          ));
        }),
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(selected, isNull);
    });

    testWidgets('clear button swaps back to search icon', (tester) async {
      await tester.pumpWidget(_build());
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      await tester.tap(find.text('Nigeria'));
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    // ── Validation ───────────────────────────────────────────────────────────

    testWidgets('validator fires with null when nothing selected', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(wrapWidget(
        Form(
          key: formKey,
          child: AppSelectSearch<String>(
            label: 'Country',
            items: _items,
            displayLabel: (c) => c,
            onSelected: (_) {},
            validator: (v) => v == null ? 'Required' : null,
          ),
        ),
      ));

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('validator passes after selecting an item', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(wrapWidget(
        Form(
          key: formKey,
          child: AppSelectSearch<String>(
            label: 'Country',
            items: _items,
            displayLabel: (c) => c,
            onSelected: (_) {},
            validator: (v) => v == null ? 'Required' : null,
          ),
        ),
      ));

      // Select an item
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      await tester.tap(find.text('Ghana'));
      await tester.pump();

      // Now validate — should pass
      final valid = formKey.currentState!.validate();
      await tester.pump();

      expect(valid, isTrue);
      expect(find.text('Required'), findsNothing);
    });

    // ── onSearchChanged ──────────────────────────────────────────────────────

    testWidgets('onSearchChanged is called on each keystroke', (tester) async {
      final queries = <String>[];
      await tester.pumpWidget(_build(onSearchChanged: queries.add));

      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'gh');
      await tester.pump();

      expect(queries, isNotEmpty);
      expect(queries.last, 'gh');
    });

    // ── Disabled ─────────────────────────────────────────────────────────────

    testWidgets('disabled field renders without error', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppSelectSearch<String>(
          label: 'Country',
          items: _items,
          displayLabel: (c) => c,
          onSelected: (_) {},
          enabled: false,
        ),
      ));
      expect(find.text('Country'), findsOneWidget);
    });
  });
}
