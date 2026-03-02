import 'package:get_it/get_it.dart';

/// Global locator instance — assign this to your app's [GetIt] instance.
///
/// ```dart
/// // In your app's locator setup:
/// locator = GetIt.instance;
/// setupLocator();
/// ```
GetIt locator = GetIt.instance;

/// Shorthand for [locator.get<T>()].
///
/// ```dart
/// final _authService = locate<AuthService>();
/// ```
T locate<T extends Object>() => locator<T>();
