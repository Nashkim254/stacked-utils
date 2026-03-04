import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppExpandable', () {
    // ── Rendering ──────────────────────────────────────────────────────────

    testWidgets('renders title widget', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppExpandable(
          title: const Text('My Section'),
          child: const Text('Hidden content'),
        ),
      ));
      expect(find.text('My Section'), findsOneWidget);
    });

    testWidgets('child is not visible when collapsed by default', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppExpandable(
          title: const Text('Header'),
          child: const Text('Body content'),
        ),
      ));
      await tester.pump();

      // SizeTransition sets its own height to 0 when sizeFactor = 0.
      // Check the SizeTransition's rendered height, not the inner text widget.
      final size = tester.getSize(find.byType(SizeTransition));
      expect(size.height, 0.0);
    });

    testWidgets('child is visible when initiallyExpanded = true', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppExpandable(
          title: const Text('Header'),
          child: const Text('Visible body'),
          initiallyExpanded: true,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Visible body'), findsOneWidget);
      final size = tester.getSize(find.text('Visible body'));
      expect(size.height, greaterThan(0));
    });

    // ── fromString convenience constructor ────────────────────────────────

    testWidgets('fromString renders title as Text', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppExpandable.fromString(
          titleText: 'FAQ Title',
          child: const Text('Answer'),
        ),
      ));
      expect(find.text('FAQ Title'), findsOneWidget);
    });

    // ── Expand / collapse toggle ───────────────────────────────────────────

    testWidgets('tapping header expands the body', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppExpandable(
          title: const Text('Toggle Me'),
          child: const Text('Revealed'),
        ),
      ));

      await tester.tap(find.text('Toggle Me'));
      await tester.pumpAndSettle();

      expect(find.text('Revealed'), findsOneWidget);
      final size = tester.getSize(find.text('Revealed'));
      expect(size.height, greaterThan(0));
    });

    testWidgets('tapping header twice collapses body back', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppExpandable(
          title: const Text('Toggle'),
          child: const Text('Content'),
        ),
      ));

      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // After collapse the SizeTransition height must return to 0.
      final size = tester.getSize(find.byType(SizeTransition));
      expect(size.height, 0.0);
    });

    // ── onExpansionChanged callback ────────────────────────────────────────

    testWidgets('onExpansionChanged fires with true on expand', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(wrapWidget(
        AppExpandable(
          title: const Text('Header'),
          child: const Text('Child'),
          onExpansionChanged: (v) => lastValue = v,
        ),
      ));

      await tester.tap(find.text('Header'));
      await tester.pumpAndSettle();
      expect(lastValue, true);
    });

    testWidgets('onExpansionChanged fires with false on collapse', (tester) async {
      final values = <bool>[];
      await tester.pumpWidget(wrapWidget(
        AppExpandable(
          title: const Text('Header'),
          child: const Text('Child'),
          initiallyExpanded: true,
          onExpansionChanged: values.add,
        ),
      ));

      await tester.tap(find.text('Header'));
      await tester.pumpAndSettle();
      expect(values.last, false);
    });

    // ── Custom trailing ────────────────────────────────────────────────────

    testWidgets('custom trailing widget is rendered', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppExpandable(
          title: const Text('Title'),
          child: const Text('Body'),
          trailing: const Icon(Icons.add, key: Key('custom_trailing')),
        ),
      ));
      expect(find.byKey(const Key('custom_trailing')), findsOneWidget);
    });

    // ── Default chevron icon ───────────────────────────────────────────────

    testWidgets('default chevron icon is shown when trailing is null',
        (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppExpandable(
          title: const Text('Title'),
          child: const Text('Body'),
        ),
      ));
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });
  });
}
