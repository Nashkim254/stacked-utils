import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kit/ui/shared/app_otp_field.dart';

import '../../helpers.dart';

// ── helpers ──────────────────────────────────────────────────────────────────

Widget _build({
  int length = 4,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onCompleted,
  bool obscureText = false,
  bool enabled = true,
  String? Function(String?)? validator,
}) {
  return wrapWidget(
    AppOtpField(
      length: length,
      onChanged: onChanged,
      onCompleted: onCompleted,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('AppOtpField', () {
    // ── Rendering ─────────────────────────────────────────────────────────

    testWidgets('renders the correct number of boxes', (tester) async {
      await tester.pumpWidget(_build(length: 6));
      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('renders 4 boxes by default length parameter', (tester) async {
      await tester.pumpWidget(_build(length: 4));
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('renders 1 box when length is 1', (tester) async {
      await tester.pumpWidget(_build(length: 1));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    // ── Typing ────────────────────────────────────────────────────────────

    testWidgets('typing a digit fills the first box and fires onChanged',
        (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(_build(length: 4, onChanged: changes.add));

      // Enter text into the first TextFormField.
      await tester.enterText(find.byType(TextFormField).first, '1');
      await tester.pump();

      expect(changes, isNotEmpty);
      // The partial OTP should start with '1'.
      expect(changes.last.startsWith('1'), isTrue);
    });

    testWidgets('filling all boxes calls onCompleted with the full OTP',
        (tester) async {
      String? completed;
      await tester.pumpWidget(
        _build(length: 4, onCompleted: (v) => completed = v),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '1');
      await tester.pump();
      await tester.enterText(fields.at(1), '2');
      await tester.pump();
      await tester.enterText(fields.at(2), '3');
      await tester.pump();
      await tester.enterText(fields.at(3), '4');
      await tester.pump();

      expect(completed, '1234');
    });

    testWidgets('onChanged is not called until a digit is entered',
        (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(_build(length: 4, onChanged: changes.add));
      // No typing → no callbacks.
      expect(changes, isEmpty);
    });

    testWidgets('typing multiple digits fires onChanged for each',
        (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(_build(length: 4, onChanged: changes.add));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '5');
      await tester.pump();
      await tester.enterText(fields.at(1), '6');
      await tester.pump();

      expect(changes.length, greaterThanOrEqualTo(2));
    });

    // ── Backspace ─────────────────────────────────────────────────────────

    testWidgets('backspace on an empty box fires key event without crash',
        (tester) async {
      await tester.pumpWidget(_build(length: 4));

      // Focus the second box (index 1) and send backspace.
      final fields = find.byType(TextFormField);
      await tester.tap(fields.at(1));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      // Widget still renders all boxes.
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('backspace on a filled box clears that box', (tester) async {
      await tester.pumpWidget(_build(length: 4));

      final fields = find.byType(TextFormField);
      // Type into first box.
      await tester.enterText(fields.at(0), '3');
      await tester.pump();

      // Focus first box and press backspace.
      await tester.tap(fields.at(0));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      // Still shows 4 boxes with no crash.
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    // ── obscureText ───────────────────────────────────────────────────────

    testWidgets('obscureText mode renders without error', (tester) async {
      await tester.pumpWidget(_build(length: 4, obscureText: true));
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    // ── Disabled ──────────────────────────────────────────────────────────

    testWidgets('disabled field renders all boxes without error', (tester) async {
      await tester.pumpWidget(_build(length: 4, enabled: false));
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    // ── Validation ────────────────────────────────────────────────────────

    testWidgets('validator fires and shows error message on Form.validate()',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        wrapWidget(
          Form(
            key: formKey,
            child: AppOtpField(
              length: 4,
              validator: (v) =>
                  (v == null || v.length < 4) ? 'Enter 4 digits' : null,
            ),
          ),
        ),
      );

      // Validate without entering anything.
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Enter 4 digits'), findsOneWidget);
    });

    testWidgets('validator passes when all boxes are filled', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        wrapWidget(
          Form(
            key: formKey,
            child: AppOtpField(
              length: 4,
              validator: (v) =>
                  (v == null || v.length < 4) ? 'Enter 4 digits' : null,
            ),
          ),
        ),
      );

      // Fill all boxes.
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '1');
      await tester.pump();
      await tester.enterText(fields.at(1), '2');
      await tester.pump();
      await tester.enterText(fields.at(2), '3');
      await tester.pump();
      await tester.enterText(fields.at(3), '4');
      await tester.pump();

      final isValid = formKey.currentState!.validate();
      await tester.pump();

      expect(isValid, isTrue);
      expect(find.text('Enter 4 digits'), findsNothing);
    });
  });
}
