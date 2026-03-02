import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gap', () {
    testWidgets('Gap(size) renders a vertical SizedBox', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Gap(16))),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.height, 16);
      expect(box.width, isNull);
    });

    testWidgets('Gap.h(size) renders a horizontal SizedBox', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Gap.h(24))),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.width, 24);
      expect(box.height, isNull);
    });

    testWidgets('Gap.v(size) renders a vertical SizedBox', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Gap.v(8))),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.height, 8);
      expect(box.width, isNull);
    });

    testWidgets('renders inside a Column without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [Text('A'), Gap(AppSpacing.md), Text('B')],
            ),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });
}
