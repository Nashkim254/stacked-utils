import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_text_styles.dart';

/// Creates light and dark [ThemeData] objects for your [MaterialApp].
///
/// Pass your app's [ColorScheme] so brand colors flow through the theme.
/// If omitted, Flutter's default [ColorScheme.light] / [ColorScheme.dark] is used.
///
/// ```dart
/// // In your app:
/// MaterialApp(
///   theme: AppTheme.light(
///     colorScheme: ColorScheme.light(
///       primary: BrandColors.primary,
///       secondary: BrandColors.secondary,
///     ),
///   ),
///   darkTheme: AppTheme.dark(
///     colorScheme: ColorScheme.dark(
///       primary: BrandColors.primary,
///       secondary: BrandColors.secondary,
///     ),
///   ),
///   themeMode: ThemeMode.system,
/// )
/// ```
abstract final class AppTheme {
  static ThemeData light({ColorScheme? colorScheme}) => _build(
        brightness: Brightness.light,
        colorScheme: colorScheme,
      );

  static ThemeData dark({ColorScheme? colorScheme}) => _build(
        brightness: Brightness.dark,
        colorScheme: colorScheme,
      );

  static ThemeData _build({
    required Brightness brightness,
    ColorScheme? colorScheme,
  }) {
    final isLight = brightness == Brightness.light;

    // Merge caller's ColorScheme with our surface/error/outline defaults.
    // This ensures AppColors tokens (surfaces, borders, errors) are always
    // applied even when the caller only specifies primary + secondary.
    final defaultScheme = isLight
        ? ColorScheme.light(
            error: AppColors.error,
            surface: AppColors.surface,
            onSurface: AppColors.grey900,
            outline: AppColors.grey200,
          )
        : ColorScheme.dark(
            error: AppColors.error,
            surface: AppColors.surfaceDark,
            onSurface: Colors.white,
            outline: AppColors.borderDark,
          );

    final resolvedScheme = colorScheme != null
        ? defaultScheme.copyWith(
            primary: colorScheme.primary,
            onPrimary: colorScheme.onPrimary,
            primaryContainer: colorScheme.primaryContainer,
            onPrimaryContainer: colorScheme.onPrimaryContainer,
            secondary: colorScheme.secondary,
            onSecondary: colorScheme.onSecondary,
            secondaryContainer: colorScheme.secondaryContainer,
            onSecondaryContainer: colorScheme.onSecondaryContainer,
            tertiary: colorScheme.tertiary,
            onTertiary: colorScheme.onTertiary,
          )
        : defaultScheme;

    final baseTextColor = isLight ? AppColors.grey900 : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Inter',
      colorScheme: resolvedScheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.background : AppColors.backgroundDark,
      textTheme: _textTheme(baseTextColor),
      elevatedButtonTheme: _elevatedButtonTheme(resolvedScheme),
      outlinedButtonTheme: _outlinedButtonTheme(resolvedScheme),
      textButtonTheme: _textButtonTheme(resolvedScheme),
      inputDecorationTheme: _inputTheme(isLight, resolvedScheme),
      cardTheme: _cardTheme(isLight),
      appBarTheme: _appBarTheme(isLight),
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.grey200 : AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
      chipTheme: _chipTheme(isLight),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? AppColors.surface : AppColors.surfaceDark,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isLight ? AppColors.surface : AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBR),
        titleTextStyle: AppTextStyles.h2.copyWith(color: baseTextColor),
        contentTextStyle: AppTextStyles.body.copyWith(color: baseTextColor),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? AppColors.grey900 : AppColors.grey100,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: isLight ? Colors.white : AppColors.grey900,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
      ),
    );
  }

  static TextTheme _textTheme(Color base) => TextTheme(
        displayLarge: AppTextStyles.displayLg.copyWith(color: base),
        displaySmall: AppTextStyles.displaySm.copyWith(color: base),
        headlineLarge: AppTextStyles.h1.copyWith(color: base),
        headlineMedium: AppTextStyles.h2.copyWith(color: base),
        headlineSmall: AppTextStyles.h3.copyWith(color: base),
        bodyLarge: AppTextStyles.bodyLg.copyWith(color: base),
        bodyMedium: AppTextStyles.body.copyWith(color: base),
        bodySmall: AppTextStyles.bodySm.copyWith(color: base),
        labelMedium: AppTextStyles.label.copyWith(color: base),
        labelSmall: AppTextStyles.caption,
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBR),
          textStyle: AppTextStyles.label
              .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBR),
          side: BorderSide(color: cs.primary, width: 1.5),
          textStyle: AppTextStyles.label
              .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );

  static TextButtonThemeData _textButtonTheme(ColorScheme cs) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: AppTextStyles.label
              .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );

  static InputDecorationTheme _inputTheme(bool isLight, ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.grey50 : AppColors.grey800,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: BorderSide(
            color: isLight ? AppColors.grey200 : AppColors.borderDark,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.label.copyWith(
          color: isLight ? AppColors.grey600 : AppColors.grey400,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.grey400),
        errorStyle: AppTextStyles.bodySm.copyWith(color: AppColors.error),
      );

  static CardThemeData _cardTheme(bool isLight) => CardThemeData(
        elevation: 0,
        color: isLight ? AppColors.surface : AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBR,
          side: BorderSide(
            color: isLight ? AppColors.grey200 : AppColors.borderDark,
          ),
        ),
        margin: EdgeInsets.zero,
      );

  static AppBarTheme _appBarTheme(bool isLight) => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: isLight ? AppColors.surface : AppColors.surfaceDark,
        foregroundColor: isLight ? AppColors.grey900 : Colors.white,
        titleTextStyle: AppTextStyles.h3.copyWith(
          color: isLight ? AppColors.grey900 : Colors.white,
        ),
        iconTheme: IconThemeData(
          color: isLight ? AppColors.grey900 : Colors.white,
        ),
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      );

  static ChipThemeData _chipTheme(bool isLight) => ChipThemeData(
        backgroundColor: isLight ? AppColors.grey100 : AppColors.grey800,
        labelStyle: AppTextStyles.label.copyWith(
          color: isLight ? AppColors.grey700 : AppColors.grey300,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fullBR),
        side: BorderSide.none,
      );
}
