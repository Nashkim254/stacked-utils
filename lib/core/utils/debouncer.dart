import 'dart:async';

import 'package:flutter/material.dart';

/// Delays execution of [call] until [delay] has passed without another call.
/// Ideal for search fields, form auto-save, and any input-driven API calls.
///
/// ```dart
/// // In a widget or ViewModel:
/// final _debounce = Debouncer(delay: Duration(milliseconds: 500));
///
/// void onSearchChanged(String query) {
///   _debounce(() => _search(query));
/// }
///
/// @override
/// void dispose() {
///   _debounce.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Schedules [action] to run after [delay]. Cancels any pending call.
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending call without running it.
  void cancel() => _timer?.cancel();

  /// Cancels any pending call and releases the timer.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isPending => _timer?.isActive ?? false;
}

/// Like [Debouncer] but ensures [action] can only run once per [interval]
/// regardless of how many times it is called.
///
/// ```dart
/// final _throttle = Throttler(interval: Duration(seconds: 1));
/// button.onTap = () => _throttle(() => submitForm());
/// ```
class Throttler {
  final Duration interval;
  Timer? _timer;

  Throttler({this.interval = const Duration(seconds: 1)});

  void call(VoidCallback action) {
    if (_timer?.isActive ?? false) return;
    action();
    _timer = Timer(interval, () {});
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
