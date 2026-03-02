import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers.dart';

void main() {
  group('AppListTile', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppListTile(title: 'Settings'),
      ));
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppListTile(title: 'Profile', subtitle: 'Manage account'),
      ));
      expect(find.text('Manage account'), findsOneWidget);
    });

    testWidgets('does not render subtitle when omitted', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppListTile(title: 'Item'),
      ));
      // only the title text exists
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppListTile(
          title: 'Notifications',
          leading: Icon(Icons.notifications_outlined),
        ),
      ));
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(wrapWidget(
        AppListTile(
          title: 'Dark Mode',
          trailing: Switch(value: false, onChanged: (_) {}),
        ),
      ));
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows chevron icon when showChevron=true', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppListTile(title: 'Go', showChevron: true),
      ));
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('no chevron when showChevron=false', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppListTile(title: 'Item'),
      ));
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    testWidgets('shows Divider when showDivider=true', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppListTile(title: 'Item', showDivider: true),
      ));
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('no Divider when showDivider=false', (tester) async {
      await tester.pumpWidget(wrapWidget(
        const AppListTile(title: 'Item'),
      ));
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrapWidget(
        AppListTile(title: 'Item', onTap: () => count++),
      ));
      await tester.tap(find.byType(AppListTile));
      await tester.pump();
      expect(count, 1);
    });
  });
}
