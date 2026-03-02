import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = TextStyle(fontSize: 14, color: Colors.black);

  group('TextStyleX — weight', () {
    test('thin → w100', () => expect(base.thin.fontWeight, FontWeight.w100));
    test('light → w300', () => expect(base.light.fontWeight, FontWeight.w300));
    test('regular → w400', () => expect(base.regular.fontWeight, FontWeight.w400));
    test('medium → w500', () => expect(base.medium.fontWeight, FontWeight.w500));
    test('semiBold → w600', () => expect(base.semiBold.fontWeight, FontWeight.w600));
    test('bold → w700', () => expect(base.bold.fontWeight, FontWeight.w700));
    test('extraBold → w800', () => expect(base.extraBold.fontWeight, FontWeight.w800));
    test('black → w900', () => expect(base.black.fontWeight, FontWeight.w900));
  });

  group('TextStyleX — style', () {
    test('italic sets fontStyle', () {
      expect(base.italic.fontStyle, FontStyle.italic);
    });
    test('underline sets decoration', () {
      expect(base.underline.decoration, TextDecoration.underline);
    });
    test('lineThrough sets decoration', () {
      expect(base.lineThrough.decoration, TextDecoration.lineThrough);
    });
  });

  group('TextStyleX — color & size', () {
    test('colored() sets color', () {
      expect(base.colored(Colors.red).color, Colors.red);
    });
    test('sized() sets fontSize', () {
      expect(base.sized(20).fontSize, 20);
    });
    test('spaced() sets letterSpacing', () {
      expect(base.spaced(2.5).letterSpacing, 2.5);
    });
    test('height() sets height', () {
      // Explicit extension invocation avoids shadowing by TextStyle.height getter
      expect(TextStyleX(base).height(1.5).height, 1.5);
    });
  });

  group('TextStyleX — chaining', () {
    test('chains multiple modifiers', () {
      final style = base.bold.italic.colored(Colors.blue).sized(18);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.fontStyle, FontStyle.italic);
      expect(style.color, Colors.blue);
      expect(style.fontSize, 18);
    });

    test('does not mutate original style', () {
      base.bold;
      expect(base.fontWeight, isNull); // base unchanged
    });
  });
}
