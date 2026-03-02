import 'package:flutter/material.dart';

/// Overlays a loading indicator on top of [child] when [busy] is true.
/// Pointer events are blocked while loading.
///
/// ```dart
/// BusyOverlay(
///   busy: viewModel.isBusy,
///   child: MyForm(),
/// )
/// ```
class BusyOverlay extends StatelessWidget {
  final Widget child;
  final bool busy;
  final Color? overlayColor;
  final Color? indicatorColor;

  const BusyOverlay({
    required this.child,
    required this.busy,
    this.overlayColor,
    this.indicatorColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (busy)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: ColoredBox(
                color: overlayColor ?? Colors.black.withOpacity(0.15),
                child: Center(
                  child: CircularProgressIndicator(
                    color:
                        indicatorColor ?? Theme.of(context).colorScheme.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
