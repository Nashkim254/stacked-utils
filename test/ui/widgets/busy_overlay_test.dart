import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('BusyOverlay', () {
    testWidgets('shows child normally when busy=false', (tester) async {
      await tester.pumpWidget(wrapWidget(
        BusyOverlay(
          busy: false,
          child: const Text('content'),
        ),
      ));
      expect(find.text('content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows CircularProgressIndicator when busy=true', (tester) async {
      await tester.pumpWidget(wrapWidget(
        BusyOverlay(
          busy: true,
          child: const Text('content'),
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('child still present in the tree when busy=true', (tester) async {
      await tester.pumpWidget(wrapWidget(
        BusyOverlay(
          busy: true,
          child: const Text('content'),
        ),
      ));
      // Child is rendered but pointer events are absorbed
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('AbsorbPointer blocks interaction when busy=true', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrapWidget(
        BusyOverlay(
          busy: true,
          child: GestureDetector(
            onTap: () => count++,
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'), warnIfMissed: false);
      await tester.pump();
      expect(count, 0);
    });
  });
}
