import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppButton(label: 'Submit', onTap: () {}),
      ));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrapWidget(
        AppButton(label: 'Go', onTap: () => count++),
      ));
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(count, 1);
    });

    // ── busy state ───────────────────────────────────────────────────────

    testWidgets('shows CircularProgressIndicator when busy=true', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppButton(label: 'Loading', busy: true, onTap: () {}),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('does not call onTap when busy=true', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrapWidget(
        AppButton(label: 'Go', busy: true, onTap: () => count++),
      ));
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      await tester.pump();
      expect(count, 0);
    });

    // ── disabled state ───────────────────────────────────────────────────

    testWidgets('does not call onTap when disabled=true', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrapWidget(
        AppButton(label: 'Go', disabled: true, onTap: () => count++),
      ));
      await tester.tap(find.byType(InkWell), warnIfMissed: false);
      await tester.pump();
      expect(count, 0);
    });

    // ── variants ────────────────────────────────────────────────────────

    for (final variant in ButtonVariant.values) {
      testWidgets('renders without error for variant $variant', (tester) async {
        await tester.pumpWidget(wrapWidget(
          AppButton(label: 'Btn', variant: variant, onTap: () {}),
        ));
        expect(find.text('Btn'), findsOneWidget);
      });
    }

    // ── sizes ────────────────────────────────────────────────────────────

    for (final size in ButtonSize.values) {
      testWidgets('renders without error for size $size', (tester) async {
        await tester.pumpWidget(wrapWidget(
          AppButton(label: 'Btn', size: size, onTap: () {}),
        ));
        expect(find.text('Btn'), findsOneWidget);
      });
    }

    // ── icon support ─────────────────────────────────────────────────────

    testWidgets('renders icon on the left by default', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppButton(
          label: 'Add',
          icon: const Icon(Icons.add),
          onTap: () {},
        ),
      ));
      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('fixed width is respected', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppButton(label: 'Btn', width: 120, onTap: () {}),
      ));
      final size = tester.getSize(find.byType(AppButton));
      expect(size.width, 120);
    });
  });
}
