import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

/// Mix into a [BaseViewModel] to get a managed [FormState] with
/// autovalidation and reset support.
///
/// ```dart
/// class LoginViewModel extends BaseViewModel with FormMixin {
///   void submit() {
///     if (!validate()) return;
///     // proceed
///   }
/// }
/// ```
/// In the view, pass [formKey] to the [Form] widget and
/// [autovalidateMode] to enable per-field validation after first submit.
mixin FormMixin on BaseViewModel {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  AutovalidateMode get autovalidateMode => _autovalidateMode;

  /// Switches autovalidation on, rebuilds the widget tree, then validates the
  /// form. Returns `true` if every field passes its validator.
  bool validate() {
    _autovalidateMode = AutovalidateMode.onUserInteraction;
    notifyListeners();
    return formKey.currentState?.validate() ?? false;
  }

  /// Resets every field to its initial value and turns autovalidation off.
  void resetForm() {
    formKey.currentState?.reset();
    _autovalidateMode = AutovalidateMode.disabled;
    notifyListeners();
  }

  /// Returns whether the form is currently valid without changing
  /// [autovalidateMode] or triggering a rebuild.
  bool get isFormValid => formKey.currentState?.validate() ?? false;
}
