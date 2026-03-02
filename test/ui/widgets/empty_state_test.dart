import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('EmptyState', () {
    testWidgets('shows message text', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const EmptyState(icon: Icons.inbox, message: 'Nothing here'),
      ));
      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('shows icon', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const EmptyState(icon: Icons.inbox, message: 'Empty'),
      ));
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('shows subMessage when provided', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const EmptyState(
          icon: Icons.inbox,
          message: 'Empty',
          subMessage: 'Add something to get started',
        ),
      ));
      expect(find.text('Add something to get started'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(wrapWidget(
        EmptyState(
          icon: Icons.inbox,
          message: 'Empty',
          onRetry: () {},
          retryLabel: 'Refresh',
        ),
      ));
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button tapped', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrapWidget(
        EmptyState(
          icon: Icons.inbox,
          message: 'Empty',
          onRetry: () => count++,
        ),
      ));
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(count, 1);
    });

    testWidgets('does not show retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const EmptyState(icon: Icons.inbox, message: 'Empty'),
      ));
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });
}
