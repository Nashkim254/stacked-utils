import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppDivider', () {
    testWidgets('renders a plain Divider when no label', (tester) async {
      await tester.pumpWidget(wrapWidget(const AppDivider()));
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('renders label text when provided', (tester) async {
      await tester.pumpWidget(wrapWidget(const AppDivider(label: 'or')));
      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('renders two Dividers when label is centred', (tester) async {
      await tester.pumpWidget(wrapWidget(const AppDivider(label: 'or')));
      // Two Expanded Dividers flank the label
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('left-aligned label renders one Divider', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const AppDivider(label: 'Section', labelLeft: true)),
      );
      expect(find.text('Section'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
