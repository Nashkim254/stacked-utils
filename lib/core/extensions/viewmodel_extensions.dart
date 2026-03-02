import 'package:stacked/stacked.dart';

extension ViewModelX on BaseViewModel {
  /// Wraps [fn] with busy state management and unified error handling.
  /// Catches any exception and surfaces it via [setError].
  ///
  /// ```dart
  /// await runWithError(() => _authService.login(email, password));
  /// ```
  Future<void> runWithError(
    Future<void> Function() fn, {
    String? fallbackMessage,
    String? busyKey,
  }) async {
    try {
      busyKey != null ? setBusyForObject(busyKey, true) : setBusy(true);
      await fn();
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : fallbackMessage ?? 'Something went wrong';
      setError(message);
    } finally {
      busyKey != null ? setBusyForObject(busyKey, false) : setBusy(false);
    }
  }

  /// Returns `true` if the model has a non-null error.
  bool get hasError => modelError != null;

  /// Clears the current error.
  void clearError() => setError(null);
}
