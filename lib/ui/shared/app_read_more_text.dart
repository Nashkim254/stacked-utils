import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

/// A text widget that truncates long content and provides a "Read more" /
/// "Read less" inline toggle.
///
/// Uses [ValueNotifier] + [ValueListenableBuilder] for expanded state —
/// no setState.  The toggle link color defaults to
/// `Theme.of(context).colorScheme.primary` so it stays on-brand.
///
/// ```dart
/// AppReadMoreText(
///   text: article.summary,
///   maxLines: 4,
///   readMoreText: 'Show more',
///   readLessText: 'Show less',
/// )
/// ```
class AppReadMoreText extends StatefulWidget {
  /// The full text to display.
  final String text;

  /// Maximum lines shown in the collapsed state.
  final int maxLines;

  /// Optional explicit text style; defaults to [AppTextStyles.body].
  final TextStyle? style;

  /// Label shown on the inline toggle when collapsed.
  final String readMoreText;

  /// Label shown on the inline toggle when expanded.
  final String readLessText;

  /// Color of the "Read more" / "Read less" link.
  /// Defaults to `colorScheme.primary`.
  final Color? linkColor;

  const AppReadMoreText({
    required this.text,
    this.maxLines = 3,
    this.style,
    this.readMoreText = 'Read more',
    this.readLessText = 'Read less',
    this.linkColor,
    super.key,
  });

  @override
  State<AppReadMoreText> createState() => _AppReadMoreTextState();
}

class _AppReadMoreTextState extends State<AppReadMoreText> {
  final ValueNotifier<bool> _expanded = ValueNotifier<bool>(false);

  /// We need to know whether the text actually overflows at [maxLines] before
  /// we decide whether to show a toggle at all.  This is measured with a
  /// [LayoutBuilder] + [TextPainter].
  bool _textOverflows(double maxWidth, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return painter.didExceedMaxLines;
  }

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveLinkColor = widget.linkColor ?? cs.primary;
    final textStyle = widget.style ?? AppTextStyles.body;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final overflows = _textOverflows(maxWidth, textStyle);

        if (!overflows) {
          // Text fits — render it plain with no toggle.
          return Text(widget.text, style: textStyle);
        }

        return ValueListenableBuilder<bool>(
          valueListenable: _expanded,
          builder: (context, expanded, _) {
            final linkText =
                expanded ? widget.readLessText : widget.readMoreText;
            final linkStyle = textStyle.copyWith(
              color: effectiveLinkColor,
              fontWeight: FontWeight.w600,
            );

            if (expanded) {
              // Expanded: full text + inline "Read less" at the end.
              return RichText(
                text: TextSpan(
                  style: textStyle,
                  children: [
                    TextSpan(text: '${widget.text} '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () => _expanded.value = false,
                        child: Text(linkText, style: linkStyle),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Collapsed: truncated text + inline "Read more".
            return _CollapsedReadMore(
              text: widget.text,
              maxLines: widget.maxLines,
              textStyle: textStyle,
              linkStyle: linkStyle,
              linkText: linkText,
              maxWidth: maxWidth,
              onTap: () => _expanded.value = true,
            );
          },
        );
      },
    );
  }
}

// ── Helper widget for the collapsed state ────────────────────────────────────

/// Renders the truncated text with the "Read more" link appended inline.
/// The link is painted as a suffix using a [CustomPainter]-free approach:
/// we use a [Stack] with an absolutely-positioned [RichText] for the trimmed
/// body and overlay the link at the bottom-right.
class _CollapsedReadMore extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextStyle textStyle;
  final TextStyle linkStyle;
  final String linkText;
  final double maxWidth;
  final VoidCallback onTap;

  const _CollapsedReadMore({
    required this.text,
    required this.maxLines,
    required this.textStyle,
    required this.linkStyle,
    required this.linkText,
    required this.maxWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Measure the link width so we know how many characters to trim.
    final linkPainter = TextPainter(
      text: TextSpan(text: ' … $linkText', style: linkStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final linkWidth = linkPainter.width;

    // Build the truncated body, leaving space for the link on the last line.
    final bodyPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      ellipsis: '',
    )..layout(maxWidth: maxWidth - linkWidth);

    // Walk character-by-character backwards to find the safe trim point.
    int endIndex = text.length;
    for (int i = text.length; i >= 0; i--) {
      final p = TextPainter(
        text: TextSpan(text: text.substring(0, i), style: textStyle),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth - linkWidth);

      if (!p.didExceedMaxLines) {
        endIndex = i;
        break;
      }
    }

    final trimmed = text.substring(0, endIndex).trimRight();
    // Suppress unused variable warning — bodyPainter was used above for
    // layout; discard cleanly.
    bodyPainter.dispose();
    linkPainter.dispose();

    return RichText(
      maxLines: maxLines,
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: trimmed),
          TextSpan(text: ' … ', style: textStyle),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onTap,
              child: Text(linkText, style: linkStyle),
            ),
          ),
        ],
      ),
    );
  }
}
