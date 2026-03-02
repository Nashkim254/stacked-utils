import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ThemeService with ListenableServiceMixin {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
