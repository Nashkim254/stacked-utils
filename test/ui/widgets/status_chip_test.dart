import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('StatusChip', () {
    testWidgets('active() shows "Active" label', (tester) async {
      await tester.pumpWidget(wrapWidget(const StatusChip.active()));
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('inactive() shows "Inactive" label', (tester) async {
      await tester.pumpWidget(wrapWidget(const StatusChip.inactive()));
      expect(find.text('Inactive'), findsOneWidget);
    });

    testWidgets('pending() shows "Pending" label', (tester) async {
      await tester.pumpWidget(wrapWidget(const StatusChip.pending()));
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('failed() shows "Failed" label', (tester) async {
      await tester.pumpWidget(wrapWidget(const StatusChip.failed()));
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('verified() shows "Verified" label', (tester) async {
      await tester.pumpWidget(wrapWidget(const StatusChip.verified()));
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('custom label and color are rendered', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const StatusChip(label: 'Custom', color: Colors.purple),
      ));
      expect(find.text('Custom'), findsOneWidget);
    });
  });
}
