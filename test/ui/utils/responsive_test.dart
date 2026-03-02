import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _screen(double width, Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Responsive breakpoints', () {
    testWidgets('isMobile for width <= 599', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_screen(
        390,
        Builder(builder: (c) { ctx = c; return const SizedBox(); }),
      ));
      expect(Responsive.isMobile(ctx), isTrue);
      expect(Responsive.isTablet(ctx), isFalse);
      expect(Responsive.isDesktop(ctx), isFalse);
    });

    testWidgets('isTablet for width 600–1023', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_screen(
        768,
        Builder(builder: (c) { ctx = c; return const SizedBox(); }),
      ));
      expect(Responsive.isTablet(ctx), isTrue);
      expect(Responsive.isMobile(ctx), isFalse);
      expect(Responsive.isDesktop(ctx), isFalse);
    });

    testWidgets('isDesktop for width > 1023', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_screen(
        1280,
        Builder(builder: (c) { ctx = c; return const SizedBox(); }),
      ));
      expect(Responsive.isDesktop(ctx), isTrue);
      expect(Responsive.isTablet(ctx), isFalse);
      expect(Responsive.isMobile(ctx), isFalse);
    });
  });

  group('Responsive.resolve()', () {
    testWidgets('returns mobile value on mobile', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_screen(
        390,
        Builder(builder: (c) { ctx = c; return const SizedBox(); }),
      ));
      expect(Responsive.resolve(ctx, mobile: 'M', tablet: 'T', desktop: 'D'), 'M');
    });

    testWidgets('returns tablet value on tablet', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_screen(
        768,
        Builder(builder: (c) { ctx = c; return const SizedBox(); }),
      ));
      expect(Responsive.resolve(ctx, mobile: 'M', tablet: 'T', desktop: 'D'), 'T');
    });

    testWidgets('returns desktop value on desktop', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_screen(
        1280,
        Builder(builder: (c) { ctx = c; return const SizedBox(); }),
      ));
      expect(Responsive.resolve(ctx, mobile: 'M', tablet: 'T', desktop: 'D'), 'D');
    });

    testWidgets('cascades: desktop falls back to tablet when desktop omitted',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_screen(
        1280,
        Builder(builder: (c) { ctx = c; return const SizedBox(); }),
      ));
      expect(Responsive.resolve(ctx, mobile: 'M', tablet: 'T'), 'T');
    });

    testWidgets('cascades: desktop falls back to mobile when only mobile set',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_screen(
        1280,
        Builder(builder: (c) { ctx = c; return const SizedBox(); }),
      ));
      expect(Responsive.resolve(ctx, mobile: 'M'), 'M');
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('shows mobile child on mobile width', (tester) async {
      await tester.pumpWidget(_screen(
        390,
        const ResponsiveBuilder(
          mobile: Text('mobile'),
          tablet: Text('tablet'),
          desktop: Text('desktop'),
        ),
      ));
      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('shows tablet child on tablet width', (tester) async {
      await tester.pumpWidget(_screen(
        768,
        const ResponsiveBuilder(
          mobile: Text('mobile'),
          tablet: Text('tablet'),
        ),
      ));
      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
    });
  });
}
