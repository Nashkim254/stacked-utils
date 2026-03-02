import 'package:flutter/material.dart';

/// Border-radius constants.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double button = 12;
  static const double card = 16;
  static const double input = 10;
  static const double full = 999;

  // Convenience [BorderRadius] objects
  static final BorderRadius xsBR = BorderRadius.circular(xs);
  static final BorderRadius smBR = BorderRadius.circular(sm);
  static final BorderRadius mdBR = BorderRadius.circular(md);
  static final BorderRadius lgBR = BorderRadius.circular(lg);
  static final BorderRadius xlBR = BorderRadius.circular(xl);
  static final BorderRadius buttonBR = BorderRadius.circular(button);
  static final BorderRadius cardBR = BorderRadius.circular(card);
  static final BorderRadius inputBR = BorderRadius.circular(input);
  static final BorderRadius fullBR = BorderRadius.circular(full);
}
