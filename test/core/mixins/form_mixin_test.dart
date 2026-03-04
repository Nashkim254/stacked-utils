import 'package:app_kit/core/mixins/form_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked/stacked.dart';

class _TestFormViewModel extends BaseViewModel with FormMixin {}

void main() {
  // GlobalKey.currentState requires the widget binding to be initialised even
  // in pure-unit tests that never build a widget tree.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FormMixin', () {
    late _TestFormViewModel vm;

    setUp(() => vm = _TestFormViewModel());
    tearDown(() => vm.dispose());

    // ── formKey ───────────────────────────────────────────────────────────

    test('formKey is not null', () {
      expect(vm.formKey, isNotNull);
    });

    // ── autovalidateMode ─────────────────────────────────────────────────

    test('autovalidateMode starts as AutovalidateMode.disabled', () {
      expect(vm.autovalidateMode, AutovalidateMode.disabled);
    });

    // ── validate() ───────────────────────────────────────────────────────

    test('validate() switches autovalidateMode to onUserInteraction', () {
      vm.validate();
      expect(vm.autovalidateMode, AutovalidateMode.onUserInteraction);
    });

    test('validate() returns false when form has no currentState', () {
      // Outside a widget tree formKey.currentState is null, so validate()
      // must fall back to false rather than throw.
      expect(vm.validate(), isFalse);
    });

    // ── resetForm() ──────────────────────────────────────────────────────

    test('resetForm() resets autovalidateMode to disabled', () {
      vm.validate(); // advance mode to onUserInteraction
      expect(vm.autovalidateMode, AutovalidateMode.onUserInteraction);

      vm.resetForm();
      expect(vm.autovalidateMode, AutovalidateMode.disabled);
    });

    test('resetForm() does not throw when form has no currentState', () {
      expect(() => vm.resetForm(), returnsNormally);
    });

    // ── isFormValid ──────────────────────────────────────────────────────

    test('isFormValid returns false and does not change autovalidateMode', () {
      expect(vm.isFormValid, isFalse);
      // autovalidateMode must remain untouched
      expect(vm.autovalidateMode, AutovalidateMode.disabled);
    });

    // ── notifyListeners ──────────────────────────────────────────────────

    test('validate() triggers a listener notification', () {
      int notifyCount = 0;
      vm.addListener(() => notifyCount++);

      vm.validate();

      expect(notifyCount, greaterThan(0));
    });

    test('resetForm() triggers a listener notification', () {
      int notifyCount = 0;
      vm.addListener(() => notifyCount++);

      vm.resetForm();

      expect(notifyCount, greaterThan(0));
    });
  });
}
