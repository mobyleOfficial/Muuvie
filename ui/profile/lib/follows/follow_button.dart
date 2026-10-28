import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// Follow button with the mutual states of F6.3: "Seguir", "Seguir de volta"
/// when the other one already follows, and "Seguindo" (tap to unfollow).
class FollowButton extends StatelessWidget {
  final bool following;
  final bool followedBy;
  final bool busy;
  final VoidCallback onPressed;

  /// Fill color of "Seguir"; the profile's accent on a profile header.
  final Color? accent;

  const FollowButton({
    super.key,
    required this.following,
    required this.followedBy,
    required this.onPressed,
    this.busy = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (following) {
      return OutlinedButton(
        onPressed: busy ? null : onPressed,
        child: Text(l10n?.followingLabel ?? ''),
      );
    }
    final color = accent;
    final onColor = color == null
        ? null
        : (color.computeLuminance() > 0.5 ? Colors.black : Colors.white);
    return FilledButton(
      style: color == null
          ? null
          : FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: onColor,
            ),
      onPressed: busy ? null : onPressed,
      child: Text(
        followedBy ? l10n?.followBackLabel ?? '' : l10n?.followLabel ?? '',
      ),
    );
  }
}
