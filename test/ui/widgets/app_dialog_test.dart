import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppDialog', () {
    // ── Basic rendering ────────────────────────────────────────────────────

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppDialog(title: 'Hello'),
      ));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders content text', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppDialog(content: 'Some body text'),
      ));
      expect(find.text('Some body text'), findsOneWidget);
    });

    testWidgets('renders custom body widget when provided', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppDialog(
          body: Text('Custom widget body', key: Key('custom_body')),
        ),
      ));
      expect(find.byKey(const Key('custom_body')), findsOneWidget);
    });

    testWidgets('shows Close button when actions is null', (tester) async {
      await tester.pumpWidget(wrapWidget(const AppDialog()));
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('renders provided action buttons', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppDialog(
          title: 'Confirm',
          actions: [
            AppButton(label: 'Cancel', onTap: () {}),
            AppButton(label: 'OK', onTap: () {}),
          ],
        ),
      ));
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    // ── AppDialog.show ─────────────────────────────────────────────────────

    testWidgets('AppDialog.show displays the dialog', (tester) async {
      await tester.pumpWidget(wrapWidget(
        Builder(
          builder: (ctx) => AppButton(
            label: 'Open',
            onTap: () => AppDialog.show(ctx, title: 'Shown', content: 'Details'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Shown'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('AppDialog.show — Close button dismisses dialog', (tester) async {
      await tester.pumpWidget(wrapWidget(
        Builder(
          builder: (ctx) => AppButton(
            label: 'Open',
            onTap: () => AppDialog.show(ctx, title: 'To Close'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('To Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('To Close'), findsNothing);
    });

    // ── AppDialog.alert ────────────────────────────────────────────────────

    testWidgets('AppDialog.alert displays title and OK button', (tester) async {
      await tester.pumpWidget(wrapWidget(
        Builder(
          builder: (ctx) => AppButton(
            label: 'Alert',
            onTap: () =>
                AppDialog.alert(ctx, title: 'Error!', content: 'Something failed'),
          ),
        ),
      ));

      await tester.tap(find.text('Alert'));
      await tester.pumpAndSettle();

      expect(find.text('Error!'), findsOneWidget);
      expect(find.text('Something failed'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('AppDialog.alert custom buttonText is shown', (tester) async {
      await tester.pumpWidget(wrapWidget(
        Builder(
          builder: (ctx) => AppButton(
            label: 'Alert',
            onTap: () => AppDialog.alert(
              ctx,
              title: 'Notice',
              buttonText: 'Got it',
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Alert'));
      await tester.pumpAndSettle();

      expect(find.text('Got it'), findsOneWidget);
    });

    testWidgets('AppDialog.alert OK button dismisses dialog', (tester) async {
      await tester.pumpWidget(wrapWidget(
        Builder(
          builder: (ctx) => AppButton(
            label: 'Alert',
            onTap: () => AppDialog.alert(ctx, title: 'Warning'),
          ),
        ),
      ));

      await tester.tap(find.text('Alert'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Warning'), findsNothing);
    });

    // ── AppDialog.confirm ──────────────────────────────────────────────────

    testWidgets('AppDialog.confirm shows title, confirm and cancel buttons',
        (tester) async {
      await tester.pumpWidget(wrapWidget(
        Builder(
          builder: (ctx) => AppButton(
            label: 'Confirm',
            onTap: () => AppDialog.confirm(ctx, title: 'Delete?'),
          ),
        ),
      ));

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Delete?'), findsOneWidget);
      expect(find.text('Confirm'), findsWidgets); // button + trigger
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('AppDialog.confirm returns true when Confirm pressed',
        (tester) async {
      bool? result;
      await tester.pumpWidget(wrapWidget(
        Builder(
          builder: (ctx) => AppButton(
            label: 'Open',
            onTap: () async {
              result = await AppDialog.confirm(ctx, title: 'Sure?');
            },
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap the 'Confirm' button inside the dialog.
      // There are two 'Confirm' texts: the trigger button + dialog button.
      // The dialog's Confirm button is the last one found.
      final confirmButtons = find.text('Confirm');
      await tester.tap(confirmButtons.last);
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets('AppDialog.confirm returns false when Cancel pressed',
        (tester) async {
      bool? result;
      await tester.pumpWidget(wrapWidget(
        Builder(
          builder: (ctx) => AppButton(
            label: 'Open',
            onTap: () async {
              result = await AppDialog.confirm(ctx, title: 'Sure?');
            },
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('AppDialog.confirm with custom confirmText and cancelText',
        (tester) async {
      await tester.pumpWidget(wrapWidget(
        Builder(
          builder: (ctx) => AppButton(
            label: 'Open',
            onTap: () => AppDialog.confirm(
              ctx,
              title: 'Archive?',
              confirmText: 'Archive',
              cancelText: 'Dismiss',
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Archive'), findsWidgets);
      expect(find.text('Dismiss'), findsOneWidget);
    });
  });
}
