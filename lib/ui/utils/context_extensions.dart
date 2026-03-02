import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  // ── Screen dimensions ───────────────────────────────────────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  double get statusBarHeight => MediaQuery.paddingOf(this).top;
  double get bottomInset => MediaQuery.viewInsetsOf(this).bottom;
  double get safeAreaBottom => MediaQuery.paddingOf(this).bottom;
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  // ── Theme shortcuts ─────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isLight => !isDark;

  // ── Color shortcuts ─────────────────────────────────────────────────────
  Color get primaryColor => colors.primary;
  Color get errorColor => colors.error;
  Color get surfaceColor => colors.surface;

  // ── Navigation ──────────────────────────────────────────────────────────
  NavigatorState get navigator => Navigator.of(this);
  void pop<T>([T? result]) => navigator.pop(result);
  Future<T?> push<T>(Widget page) => navigator.push<T>(
        MaterialPageRoute(builder: (_) => page),
      );
  Future<T?> pushReplacement<T>(Widget page) =>
      navigator.pushReplacement(MaterialPageRoute(builder: (_) => page));

  // ── Focus ───────────────────────────────────────────────────────────────
  void unfocus() => FocusScope.of(this).unfocus();

  // ── Snackbar ────────────────────────────────────────────────────────────
  void showSnackbar(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }
}
