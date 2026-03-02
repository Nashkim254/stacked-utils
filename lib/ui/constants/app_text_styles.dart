import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Pre-defined text styles built on the Inter font family.
/// Consume through [AppTheme]'s [TextTheme] for automatic light/dark
/// adaptation, or use directly when you need an exact style.
abstract final class AppTextStyles {
  static const TextStyle _base = TextStyle(
    fontFamily: 'Inter',
    color: AppColors.grey900,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // ── Display ──────────────────────────────────────────────────────────────
  static final TextStyle displayLg = _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );
  static final TextStyle displaySm = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  // ── Headings ─────────────────────────────────────────────────────────────
  static final TextStyle h1 = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static final TextStyle h2 = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static final TextStyle h3 = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  static final TextStyle bodyLg = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static final TextStyle body = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static final TextStyle bodySm = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── Label / Caption ──────────────────────────────────────────────────────
  static final TextStyle label = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static final TextStyle caption = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.grey400,
  );

  // ── Overline ─────────────────────────────────────────────────────────────
  static final TextStyle overline = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.4,
  );
}
