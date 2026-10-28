import 'package:common/app_localizations.dart';
import 'package:common/src/theme/muuvie_radius.dart';
import 'package:common/src/vocabulary/vocabulary_labels.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Icon + label for a rating (Favoritado, Adorei... Na geladeira).
///
/// Colors come from `*Container` / `on*Container` pairs so contrast holds in
/// light and dark; the icon and text carry the meaning, not the color.
class MuuvieRatingBadge extends StatelessWidget {
  final Rating rating;

  const MuuvieRatingBadge({super.key, required this.rating});

  static IconData iconFor(Rating rating) => switch (rating) {
    Rating.favorite => Icons.favorite,
    Rating.loved => Icons.sentiment_very_satisfied,
    Rating.liked => Icons.thumb_up,
    Rating.neutral => Icons.sentiment_neutral,
    Rating.notForMe => Icons.thumb_down,
    Rating.abandoned => Icons.block,
    Rating.onHold => Icons.ac_unit,
  };

  /// Background and foreground of the label, also used by the rating bars.
  static (Color, Color) colorsFor(Rating rating, ColorScheme colorScheme) =>
      switch (rating) {
        Rating.favorite => (
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
        ),
        Rating.loved => (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
        ),
        Rating.liked => (
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
        ),
        Rating.neutral => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
        ),
        Rating.notForMe => (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
        ),
        // surfaceContainerHigh is too close to the page background.
        Rating.abandoned => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurface,
        ),
        Rating.onHold => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final label = AppLocalizations.of(context)?.rating(rating) ?? '';
    final (background, foreground) = colorsFor(rating, colorScheme);

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: MuuvieRadius.pillAll,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconFor(rating), size: 14, color: foreground),
              const SizedBox(width: 4),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
