import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../extensions/locator_helper.dart';

/// Mix this into any [BaseViewModel] to get pre-wired access to Stacked
/// services and a unified [run] wrapper — without repeating boilerplate.
///
/// ```dart
/// class HomeViewModel extends BaseViewModel with CommonViewModel {
///   Future<void> loadData() => run(() => _service.fetch());
/// }
/// ```
mixin CommonViewModel on BaseViewModel {
  DialogService get dialogService => locate<DialogService>();
  NavigationService get navService => locate<NavigationService>();
  SnackbarService get snackbarService => locate<SnackbarService>();

  /// Executes [fn] with busy state management, error handling, and an
  /// optional snackbar on failure.
  ///
  /// * [busyKey] — scope busy state to a specific object (e.g., a button id)
  /// * [errorMsg] — override the auto-extracted error message
  /// * [showSnackbarOnError] — automatically show a snackbar when an error occurs
  Future<void> run(
    Future<void> Function() fn, {
    String? busyKey,
    String? errorMsg,
    bool showSnackbarOnError = true,
  }) async {
    busyKey != null ? setBusyForObject(busyKey, true) : setBusy(true);
    notifyListeners();
    try {
      await fn();
    } catch (e) {
      final message = errorMsg ??
          (e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Something went wrong');
      setError(message);
      if (showSnackbarOnError) {
        snackbarService.showSnackbar(message: message);
      }
    } finally {
      busyKey != null ? setBusyForObject(busyKey, false) : setBusy(false);
      notifyListeners();
    }
  }

  /// Like [run] but returns the result of [fn] instead of `void`.
  /// Returns `null` if an error occurs.
  ///
  /// ```dart
  /// final user = await runAndReturn(() => _userService.getUser(id));
  /// if (user != null) _user = user;
  /// ```
  Future<T?> runAndReturn<T>(
    Future<T> Function() fn, {
    String? busyKey,
    String? errorMsg,
    bool showSnackbarOnError = false,
  }) async {
    busyKey != null ? setBusyForObject(busyKey, true) : setBusy(true);
    notifyListeners();
    try {
      return await fn();
    } catch (e) {
      final message = errorMsg ??
          (e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Something went wrong');
      setError(message);
      if (showSnackbarOnError) {
        snackbarService.showSnackbar(message: message);
      }
      return null;
    } finally {
      busyKey != null ? setBusyForObject(busyKey, false) : setBusy(false);
      notifyListeners();
    }
  }

  // ── Dialog helpers ──────────────────────────────────────────────────────

  /// Shows a basic dialog. For custom-styled dialogs, call
  /// [dialogService.showCustomDialog] directly with your app's variant enum.
  void showSuccessDialog(String message, {String? title}) =>
      dialogService.showDialog(
        title: title ?? 'Success',
        description: message,
      );

  void showErrorDialog(String message, {String? title}) =>
      dialogService.showDialog(
        title: title ?? 'Error',
        description: message,
      );

  Future<DialogResponse?> showConfirmDialog({
    required String title,
    required String description,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) =>
      dialogService.showDialog(
        title: title,
        description: description,
        buttonTitle: confirmText,
        cancelTitle: cancelText,
      );

  // ── Snackbar helpers ────────────────────────────────────────────────────

  /// Shows a basic snackbar. For custom-styled snackbars, call
  /// [snackbarService.showCustomSnackBar] directly with your app's variant enum.
  void showSuccess(String message) =>
      snackbarService.showSnackbar(message: message, title: 'Success');

  void showErr(String message) =>
      snackbarService.showSnackbar(message: message, title: 'Error');

  void showInfo(String message) =>
      snackbarService.showSnackbar(message: message);
}
