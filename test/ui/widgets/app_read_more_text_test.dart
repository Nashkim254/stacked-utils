import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

/// A short text that should never overflow at any reasonable maxLines value.
const _shortText = 'Hello world.';

/// A long text that is guaranteed to overflow at 3 lines in a 390-px viewport.
const _longText =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
    'nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in '
    'reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla '
    'pariatur. Excepteur sint occaecat cupidatat non proident.';

void main() {
  group('AppReadMoreText', () {
    // ── Short text — no toggle ─────────────────────────────────────────────

    testWidgets('short text renders without read-more link', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppReadMoreText(text: _shortText),
      ));
      await tester.pumpAndSettle();

      expect(find.text(_shortText), findsOneWidget);
      expect(find.text('Read more'), findsNothing);
    });

    // ── Long text — collapsed state ────────────────────────────────────────

    testWidgets('long text shows "Read more" link by default', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppReadMoreText(text: _longText),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Read more'), findsOneWidget);
      expect(find.text('Read less'), findsNothing);
    });

    // ── Expand ────────────────────────────────────────────────────────────

    testWidgets('tapping "Read more" expands and shows "Read less"',
        (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppReadMoreText(text: _longText),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Read more'));
      await tester.pumpAndSettle();

      expect(find.text('Read less'), findsOneWidget);
      expect(find.text('Read more'), findsNothing);
    });

    // ── Collapse ──────────────────────────────────────────────────────────

    testWidgets('tapping "Read less" collapses back', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppReadMoreText(text: _longText),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Read more'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Read less'));
      await tester.pumpAndSettle();

      expect(find.text('Read more'), findsOneWidget);
      expect(find.text('Read less'), findsNothing);
    });

    // ── Custom labels ──────────────────────────────────────────────────────

    testWidgets('custom readMoreText and readLessText are used', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppReadMoreText(
          text: _longText,
          readMoreText: 'Expand',
          readLessText: 'Collapse',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Expand'), findsOneWidget);

      await tester.tap(find.text('Expand'));
      await tester.pumpAndSettle();

      expect(find.text('Collapse'), findsOneWidget);
    });

    // ── Custom style ───────────────────────────────────────────────────────

    testWidgets('accepts custom TextStyle without error', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppReadMoreText(
          text: _longText,
          style: TextStyle(fontSize: 18),
        ),
      ));
      await tester.pumpAndSettle();
      // Should render without throwing.
      expect(find.text('Read more'), findsOneWidget);
    });

    // ── maxLines respected ─────────────────────────────────────────────────

    testWidgets('maxLines=1 triggers overflow for long text', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppReadMoreText(text: _longText, maxLines: 1),
      ));
      await tester.pumpAndSettle();
      // With maxLines=1 a long text definitely overflows.
      expect(find.text('Read more'), findsOneWidget);
    });

    // ── linkColor ─────────────────────────────────────────────────────────

    testWidgets('linkColor parameter is accepted without error', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppReadMoreText(
          text: _longText,
          linkColor: Colors.red,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Read more'), findsOneWidget);
    });
  });
}
