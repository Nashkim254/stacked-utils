import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../services/theme_service.dart';

class AppViewModel extends ReactiveViewModel {
  final _themeService = locate<ThemeService>();

  ThemeMode get themeMode => _themeService.themeMode;

  @override
  List<ListenableServiceMixin> get listenableServices => [_themeService];
}
