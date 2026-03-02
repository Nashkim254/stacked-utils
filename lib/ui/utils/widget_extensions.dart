import 'package:flutter/material.dart';

extension WidgetX on Widget {
  // ── Padding ─────────────────────────────────────────────────────────────
  Widget padAll(double v) => Padding(padding: EdgeInsets.all(v), child: this);

  Widget padH(double v) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: v), child: this);

  Widget padV(double v) =>
      Padding(padding: EdgeInsets.symmetric(vertical: v), child: this);

  Widget padOnly({double l = 0, double r = 0, double t = 0, double b = 0}) =>
      Padding(
        padding: EdgeInsets.only(left: l, right: r, top: t, bottom: b),
        child: this,
      );

  Widget padLTRB(double left, double top, double right, double bottom) =>
      Padding(
        padding: EdgeInsets.fromLTRB(left, top, right, bottom),
        child: this,
      );

  // ── Layout ──────────────────────────────────────────────────────────────
  Widget center() => Center(child: this);

  Widget expand([int flex = 1]) => Expanded(flex: flex, child: this);

  Widget flexible([int flex = 1]) => Flexible(flex: flex, child: this);

  Widget sizedBox({double? width, double? height}) =>
      SizedBox(width: width, height: height, child: this);

  Widget constrained(
          {double? minW, double? maxW, double? minH, double? maxH}) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minW ?? 0,
          maxWidth: maxW ?? double.infinity,
          minHeight: minH ?? 0,
          maxHeight: maxH ?? double.infinity,
        ),
        child: this,
      );

  Widget align(AlignmentGeometry alignment) =>
      Align(alignment: alignment, child: this);

  // ── Visibility ──────────────────────────────────────────────────────────
  Widget visible(bool condition) => Visibility(visible: condition, child: this);

  Widget opacity(double value) => Opacity(opacity: value, child: this);

  // ── Interaction ─────────────────────────────────────────────────────────
  Widget onTap(VoidCallback fn, {bool opaque = true}) => GestureDetector(
        behavior:
            opaque ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
        onTap: fn,
        child: this,
      );

  Widget inkWell({required VoidCallback onTap, BorderRadius? borderRadius}) =>
      InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: this,
      );

  // ── Decoration ──────────────────────────────────────────────────────────
  Widget decorated(BoxDecoration decoration) =>
      DecoratedBox(decoration: decoration, child: this);

  Widget clipRounded(double radius) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: this,
      );

  Widget clipOval() => ClipOval(child: this);

  // ── Sliver ──────────────────────────────────────────────────────────────
  Widget get sliver => SliverToBoxAdapter(child: this);
}
