import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/src/maratona/muuvie_color_picker.dart';
import 'package:flutter/material.dart';

/// A user's round avatar: the photo when there is one, else the initial on
/// the profile's accent color. [name] is read by screen readers.
class MuuvieUserAvatar extends StatelessWidget {
  final String? url;
  final String name;

  /// `#RRGGBB` accent of the profile, or null for the theme color.
  final String? accentColor;
  final double radius;

  const MuuvieUserAvatar({
    super.key,
    this.url,
    required this.name,
    this.accentColor,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = MuuvieColorPicker.fromHex(accentColor);
    final background = accent ?? colorScheme.secondaryContainer;
    final foreground = accent == null
        ? colorScheme.onSecondaryContainer
        : (accent.computeLuminance() > 0.5 ? Colors.black : Colors.white);
    final photo = url;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Semantics(
      label: name,
      image: true,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: background,
        backgroundImage: photo != null
            ? CachedNetworkImageProvider(photo)
            : null,
        child: photo == null
            ? ExcludeSemantics(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: radius * 0.8,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
