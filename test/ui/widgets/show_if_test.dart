import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShowIf', () {
    testWidgets('shows child when condition is true', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ShowIf(
            condition: true,
            child: Text('visible'),
            fallback: Text('hidden'),
          ),
        ),
      ));
      expect(find.text('visible'), findsOneWidget);
      expect(find.text('hidden'), findsNothing);
    });

    testWidgets('shows fallback when condition is false', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ShowIf(
            condition: false,
            child: Text('visible'),
            fallback: Text('hidden'),
          ),
        ),
      ));
      expect(find.text('hidden'), findsOneWidget);
      expect(find.text('visible'), findsNothing);
    });

    testWidgets('renders SizedBox.shrink when condition=false and no fallback',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ShowIf(condition: false, child: Text('visible')),
        ),
      ));
      expect(find.text('visible'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('rebuilds correctly when condition changes', (tester) async {
      bool show = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (_, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ShowIf(condition: show, child: const Text('content')),
                  ElevatedButton(
                    onPressed: () => setState(() => show = !show),
                    child: const Text('toggle'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
      await tester.tap(find.text('toggle'));
      await tester.pump();
      expect(find.text('content'), findsNothing);
    });
  });
}
