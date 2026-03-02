import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppTextField(label: 'Email'),
      ));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppTextField(label: 'Email', hint: 'you@example.com'),
      ));
      expect(find.text('you@example.com'), findsOneWidget);
    });

    // ── clear button ────────────────────────────────────────────────────

    testWidgets('clear button hidden when field is empty', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(wrapWidget(
        AppTextField(label: 'Search', controller: ctrl, showClearButton: true),
      ));
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      ctrl.dispose();
    });

    testWidgets('clear button appears after entering text', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(wrapWidget(
        AppTextField(label: 'Search', controller: ctrl, showClearButton: true),
      ));
      await tester.enterText(find.byType(TextFormField), 'hello');
      await tester.pump();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      ctrl.dispose();
    });

    testWidgets('tapping clear button clears the text', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(wrapWidget(
        AppTextField(label: 'Search', controller: ctrl, showClearButton: true),
      ));
      await tester.enterText(find.byType(TextFormField), 'hello');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(ctrl.text, isEmpty);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      ctrl.dispose();
    });

    testWidgets('clear button fires onChanged with empty string', (tester) async {
      final ctrl = TextEditingController();
      String? lastValue;
      await tester.pumpWidget(wrapWidget(
        AppTextField(
          label: 'Search',
          controller: ctrl,
          showClearButton: true,
          onChanged: (v) => lastValue = v,
        ),
      ));
      await tester.enterText(find.byType(TextFormField), 'hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(lastValue, '');
      ctrl.dispose();
    });

    // ── password toggle ──────────────────────────────────────────────────

    testWidgets('shows visibility icon when obscure=true', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppTextField(label: 'Password', obscure: true),
      ));
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('tapping visibility icon toggles text visibility', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppTextField(label: 'Password', obscure: true),
      ));
      // Initially obscured → visibility icon shown
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // After toggle → visibility_off shown
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    // ── states ───────────────────────────────────────────────────────────

    testWidgets('read-only field renders without error', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppTextField(
          label: 'Read only',
          initialValue: 'value',
          readOnly: true,
        ),
      ));
      expect(find.text('value'), findsOneWidget);
    });

    testWidgets('disabled field renders without error', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppTextField(
          label: 'Disabled',
          initialValue: 'value',
          enabled: false,
        ),
      ));
      expect(find.text('value'), findsOneWidget);
    });

    // ── onChanged ────────────────────────────────────────────────────────

    testWidgets('onChanged is called as user types', (tester) async {
      final values = <String>[];
      await tester.pumpWidget(wrapWidget(
        AppTextField(label: 'Input', onChanged: values.add),
      ));
      await tester.enterText(find.byType(TextFormField), 'hi');
      await tester.pump();
      expect(values, isNotEmpty);
      expect(values.last, 'hi');
    });
  });
}
