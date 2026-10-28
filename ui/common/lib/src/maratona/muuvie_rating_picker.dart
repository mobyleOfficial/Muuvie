import 'package:common/app_localizations.dart';
import 'package:common/src/maratona/muuvie_rating_badge.dart';
import 'package:common/src/vocabulary/vocabulary_labels.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// The seven rating labels as a single-choice list, in the vocabulary order.
class MuuvieRatingPicker extends StatelessWidget {
  final Rating? selected;
  final ValueChanged<Rating> onChanged;

  const MuuvieRatingPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final rating in Rating.values)
          Semantics(
            inMutuallyExclusiveGroup: true,
            checked: rating == selected,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              selected: rating == selected,
              leading: Builder(
                builder: (context) {
                  final (background, foreground) = MuuvieRatingBadge.colorsFor(
                    rating,
                    colorScheme,
                  );
                  return CircleAvatar(
                    backgroundColor: background,
                    child: Icon(
                      MuuvieRatingBadge.iconFor(rating),
                      color: foreground,
                    ),
                  );
                },
              ),
              title: Text(l10n?.rating(rating) ?? ''),
              trailing: Icon(
                rating == selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: rating == selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              onTap: () => onChanged(rating),
            ),
          ),
      ],
    );
  }
}
