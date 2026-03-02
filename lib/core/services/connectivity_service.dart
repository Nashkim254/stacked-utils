import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Provides internet connectivity state and a stream of changes.
///
/// Register as a singleton in your locator:
/// ```dart
/// locator.registerLazySingleton<ConnectivityService>(ConnectivityService.new);
/// ```
///
/// Use in a ViewModel:
/// ```dart
/// class HomeViewModel extends BaseViewModel with CommonViewModel {
///   final _connectivity = locate<ConnectivityService>();
///
///   bool get isOnline => _connectivity.isOnline;
///
///   Future<void> init() async {
///     _connectivity.onStatusChanged.listen((online) {
///       if (!online) showErr('No internet connection');
///       notifyListeners();
///     });
///   }
/// }
/// ```
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  final _controller = StreamController<bool>.broadcast();

  /// Stream that emits `true` when online, `false` when offline.
  Stream<bool> get onStatusChanged => _controller.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    // Seed the initial state
    checkConnectivity();
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = _isConnected(result);
    return _isOnline;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final online = _isConnected(results);
    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(_isOnline);
    }
  }

  bool _isConnected(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  void dispose() {
    _controller.close();
  }
}
