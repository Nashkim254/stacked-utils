import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppAvatar', () {
    group('initials', () {
      testWidgets('shows two initials for a two-word name', (tester) async {
        await tester.pumpWidget(wrapWidget(AppAvatar(name: 'John Doe')));
        expect(find.text('JD'), findsOneWidget);
      });

      testWidgets('shows one initial for a single-word name', (tester) async {
        await tester.pumpWidget(wrapWidget(AppAvatar(name: 'Alice')));
        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('uses first and last word for multi-word names', (tester) async {
        await tester.pumpWidget(wrapWidget(AppAvatar(name: 'Bob Jones Smith')));
        expect(find.text('BS'), findsOneWidget);
      });

      testWidgets('uppercases initials', (tester) async {
        await tester.pumpWidget(wrapWidget(AppAvatar(name: 'john doe')));
        expect(find.text('JD'), findsOneWidget);
      });

      testWidgets('shows "?" when name is null', (tester) async {
        await tester.pumpWidget(wrapWidget(const AppAvatar()));
        expect(find.text('?'), findsOneWidget);
      });

      testWidgets('shows "?" when name is empty', (tester) async {
        await tester.pumpWidget(wrapWidget(const AppAvatar(name: '')));
        expect(find.text('?'), findsOneWidget);
      });
    });

    testWidgets('calls onTap when tapped', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrapWidget(
        AppAvatar(name: 'Test User', onTap: () => count++),
      ));
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(count, 1);
    });

    testWidgets('renders badge when provided', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppAvatar(
          name: 'User',
          badge: Container(
            width: 12,
            height: 12,
            color: Colors.green,
            key: const ValueKey('badge'),
          ),
        ),
      ));
      expect(find.byKey(const ValueKey('badge')), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(wrapWidget(AppAvatar(name: 'X', size: 64)));
      final circle = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circle.radius, 32);
    });
  });
}
