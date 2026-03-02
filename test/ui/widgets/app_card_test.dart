import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppCard(child: Text('Hello')),
      ));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrapWidget(
        AppCard(onTap: () => count++, child: const Text('tap me')),
      ));
      await tester.tap(find.byType(AppCard));
      await tester.pump();
      expect(count, 1);
    });

    testWidgets('renders without onTap (non-tappable)', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppCard(child: Text('static')),
      ));
      expect(find.text('static'), findsOneWidget);
    });

    testWidgets('renders without border when showBorder=false', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppCard(showBorder: false, child: Text('no border')),
      ));
      expect(find.text('no border'), findsOneWidget);
    });

    testWidgets('applies custom padding via EdgeInsets.zero', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppCard(
          padding: EdgeInsets.zero,
          child: Text('no padding'),
        ),
      ));
      expect(find.text('no padding'), findsOneWidget);
    });
  });
}
