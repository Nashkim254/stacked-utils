import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('ErrorView', () {
    testWidgets('shows custom message text', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const ErrorView(message: 'Failed to load data'),
      ));
      expect(find.text('Failed to load data'), findsOneWidget);
    });

    testWidgets('always shows "Something went wrong" heading', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const ErrorView(message: 'Network error'),
      ));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows error icon', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const ErrorView(message: 'Network error'),
      ));
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(wrapWidget(
        ErrorView(message: 'Network error', onRetry: () {}),
      ));
      // ElevatedButton.icon — search by the refresh icon it contains
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrapWidget(
        ErrorView(message: 'Network error', onRetry: () => count++),
      ));
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();
      expect(count, 1);
    });

    testWidgets('uses custom retryLabel', (tester) async {
      await tester.pumpWidget(wrapWidget(
        ErrorView(message: 'Error', onRetry: () {}, retryLabel: 'Try again'),
      ));
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('no retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const ErrorView(message: 'Error'),
      ));
      expect(find.byIcon(Icons.refresh_rounded), findsNothing);
    });
  });
}
