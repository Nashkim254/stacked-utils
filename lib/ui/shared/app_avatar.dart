import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

/// A user avatar with automatic fallback to initials.
/// Uses [CachedNetworkImage] for efficient network image loading.
///
/// ```dart
/// AppAvatar(imageUrl: user.photoUrl, name: user.fullName, size: 48)
/// AppAvatar(name: 'John Doe', size: 40)  // initials fallback
/// ```
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final Widget? badge;

  const AppAvatar({
    this.imageUrl,
    this.name,
    this.size = 44,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.badge,
    super.key,
  });

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.primaryContainer;
    final fg = textColor ?? cs.onPrimaryContainer;
    final fontSize = size * 0.38;

    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (ctx, provider) => CircleAvatar(
          radius: size / 2,
          backgroundImage: provider,
        ),
        placeholder: (_, __) => _initialsCircle(bg, fg, fontSize),
        errorWidget: (_, __, ___) => _initialsCircle(bg, fg, fontSize),
      );
    } else {
      avatar = _initialsCircle(bg, fg, fontSize);
    }

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    if (badge != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: badge!,
          ),
        ],
      );
    }

    return avatar;
  }

  Widget _initialsCircle(Color bg, Color fg, double fontSize) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bg,
      child: Text(
        _initials,
        style: AppTextStyles.label.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
