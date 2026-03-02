import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import 'screens/home_screen.dart';

/// App brand colors — defined once per app, passed into AppTheme.
abstract final class BrandColors {
  static const primary   = Color(0xFF1E6BFF);
  static const secondary = Color(0xFF00C896);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLocator();
  runApp(const AppKitExampleApp());
}

/// Minimal locator setup — register Stacked services so CommonViewModel works.
void _setupLocator() {
  locator
    ..registerLazySingleton<NavigationService>(NavigationService.new)
    ..registerLazySingleton<DialogService>(DialogService.new)
    ..registerLazySingleton<SnackbarService>(SnackbarService.new)
    ..registerLazySingleton<ConnectivityService>(ConnectivityService.new);
}

class AppKitExampleApp extends StatelessWidget {
  const AppKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app_kit Example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(
        colorScheme: const ColorScheme.light(
          primary: BrandColors.primary,
          secondary: BrandColors.secondary,
        ),
      ),
      darkTheme: AppTheme.dark(
        colorScheme: const ColorScheme.dark(
          primary: BrandColors.primary,
          secondary: BrandColors.secondary,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
