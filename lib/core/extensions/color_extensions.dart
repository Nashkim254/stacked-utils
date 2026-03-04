import 'package:flutter/material.dart';

/// Extensions on [Color] for hex conversion, lightness manipulation, and
/// contrast helpers.
extension ColorX on Color {
  // ── Hex conversion ────────────────────────────────────────────────────────

  /// Returns the color as a hex string, e.g. `'#1A2B3C'`.
  ///
  /// [leadingHash]  — prepend `#` (default `true`).
  /// [includeAlpha] — include the two alpha digits before the RGB components
  ///                  (default `false`).
  ///
  /// ```dart
  /// const Color(0xFF1A2B3C).toHex();                    // '#1A2B3C'
  /// const Color(0x801A2B3C).toHex(includeAlpha: true);  // '#801A2B3C'
  /// const Color(0xFF1A2B3C).toHex(leadingHash: false);  // '1A2B3C'
  /// ```
  String toHex({bool leadingHash = true, bool includeAlpha = false}) {
    final hash = leadingHash ? '#' : '';
    final aHex = (a * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final rHex = (r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final gHex = (g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    final bHex = (b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
    return includeAlpha ? '$hash$aHex$rHex$gHex$bHex' : '$hash$rHex$gHex$bHex';
  }

  // ── Lightness ─────────────────────────────────────────────────────────────

  /// Returns a lighter version of this color by increasing HSL lightness by
  /// [amount] (clamped to the range 0.0–1.0).
  ///
  /// ```dart
  /// Colors.blue.lighten(0.2); // a visibly lighter blue
  /// ```
  Color lighten(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Returns a darker version of this color by decreasing HSL lightness by
  /// [amount] (clamped to the range 0.0–1.0).
  ///
  /// ```dart
  /// Colors.blue.darken(0.2); // a visibly darker blue
  /// ```
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  // ── Contrast helpers ──────────────────────────────────────────────────────

  /// `true` if the perceived luminance of this color is less than 0.5.
  bool get isDark => computeLuminance() < 0.5;

  /// `true` if the perceived luminance of this color is 0.5 or greater.
  bool get isLight => !isDark;

  /// The color to use for text or icons drawn on top of this color.
  ///
  /// Returns [Colors.white] for dark backgrounds and [Colors.black] for light
  /// backgrounds.
  Color get onColor => isDark ? Colors.white : Colors.black;
}
