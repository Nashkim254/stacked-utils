import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppBadge', () {
    for (final variant in BadgeVariant.values) {
      testWidgets('renders label for variant $variant', (tester) async {
        await tester.pumpWidget(wrapWidget(
          AppBadge(label: 'Test', variant: variant),
        ));
        expect(find.text('Test'), findsOneWidget);
      });
    }

    testWidgets('renders optional icon alongside label', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppBadge(
          label: 'Active',
          variant: BadgeVariant.success,
          icon: Icon(Icons.check_circle_outline),
        ),
      ));
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders without icon by default', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppBadge(label: 'Info', variant: BadgeVariant.info),
      ));
      expect(find.byType(Icon), findsNothing);
    });
  });
}
