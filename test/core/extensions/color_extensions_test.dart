import 'package:app_kit/core/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorX', () {
    // ── toHex ──────────────────────────────────────────────────────────────
    group('toHex()', () {
      test('known opaque color without alpha produces correct hex', () {
        const color = Color(0xFF1A2B3C);
        expect(color.toHex(), '#1A2B3C');
      });

      test('omits leading hash when leadingHash is false', () {
        const color = Color(0xFF1A2B3C);
        expect(color.toHex(leadingHash: false), '1A2B3C');
      });

      test('includes alpha digits when includeAlpha is true', () {
        const color = Color(0x801A2B3C);
        expect(color.toHex(includeAlpha: true), '#801A2B3C');
      });

      test('fully opaque alpha is FF', () {
        const color = Color(0xFF000000);
        expect(color.toHex(includeAlpha: true), '#FF000000');
      });

      test('white produces #FFFFFF', () {
        expect(Colors.white.toHex(), '#FFFFFF');
      });

      test('black produces #000000', () {
        expect(Colors.black.toHex(), '#000000');
      });

      test('no hash and no alpha flags both applied', () {
        const color = Color(0xFFABCDEF);
        expect(color.toHex(leadingHash: false, includeAlpha: false), 'ABCDEF');
      });
    });

    // ── lighten ─────────────────────────────────────────────────────────────
    group('lighten()', () {
      test('lightened color has greater luminance than original', () {
        final original = Colors.blue;
        final lighter = original.lighten(0.2);
        expect(lighter.computeLuminance(), greaterThan(original.computeLuminance()));
      });

      test('lightening a fully light color stays at white', () {
        final result = Colors.white.lighten(0.5);
        expect(result.computeLuminance(), closeTo(1.0, 0.01));
      });

      test('lightening by 0 returns the same color', () {
        final color = Colors.blue;
        final result = color.lighten(0.0);
        expect(result.toHex(), color.toHex());
      });
    });

    // ── darken ──────────────────────────────────────────────────────────────
    group('darken()', () {
      test('darkened color has lesser luminance than original', () {
        final original = Colors.blue;
        final darker = original.darken(0.2);
        expect(darker.computeLuminance(), lessThan(original.computeLuminance()));
      });

      test('darkening a fully dark color stays at black', () {
        final result = Colors.black.darken(0.5);
        expect(result.computeLuminance(), closeTo(0.0, 0.01));
      });

      test('darkening by 0 returns the same color', () {
        final color = Colors.blue;
        final result = color.darken(0.0);
        expect(result.toHex(), color.toHex());
      });
    });

    // ── isDark / isLight ────────────────────────────────────────────────────
    group('isDark', () {
      test('black is dark', () {
        expect(Colors.black.isDark, isTrue);
      });

      test('dark grey is dark', () {
        expect(Colors.grey.shade800.isDark, isTrue);
      });

      test('white is not dark', () {
        expect(Colors.white.isDark, isFalse);
      });

      test('yellow is not dark', () {
        expect(Colors.yellow.isDark, isFalse);
      });
    });

    group('isLight', () {
      test('white is light', () {
        expect(Colors.white.isLight, isTrue);
      });

      test('yellow is light', () {
        expect(Colors.yellow.isLight, isTrue);
      });

      test('black is not light', () {
        expect(Colors.black.isLight, isFalse);
      });

      test('isLight is opposite of isDark', () {
        const color = Color(0xFF123456);
        expect(color.isLight, equals(!color.isDark));
      });
    });

    // ── onColor ─────────────────────────────────────────────────────────────
    group('onColor', () {
      test('dark background returns white', () {
        expect(Colors.black.onColor, Colors.white);
      });

      test('dark blue returns white', () {
        expect(Colors.blue.shade900.onColor, Colors.white);
      });

      test('light background returns black', () {
        expect(Colors.white.onColor, Colors.black);
      });

      test('yellow returns black', () {
        expect(Colors.yellow.onColor, Colors.black);
      });
    });
  });
}
