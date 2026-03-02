import 'package:flutter/material.dart';

extension TextStyleX on TextStyle {
  // ── Weight ──────────────────────────────────────────────────────────────
  TextStyle get thin => copyWith(fontWeight: FontWeight.w100);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);
  TextStyle get black => copyWith(fontWeight: FontWeight.w900);

  // ── Style ───────────────────────────────────────────────────────────────
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  // ── Color & Size ────────────────────────────────────────────────────────
  TextStyle colored(Color c) => copyWith(color: c);
  TextStyle sized(double s) => copyWith(fontSize: s);
  TextStyle spaced(double ls) => copyWith(letterSpacing: ls);
  TextStyle height(double h) => copyWith(height: h);
}
