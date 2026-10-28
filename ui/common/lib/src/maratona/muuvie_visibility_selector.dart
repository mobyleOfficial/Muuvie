import 'package:common/app_localizations.dart';
import 'package:common/src/theme/muuvie_radius.dart';
import 'package:common/src/vocabulary/vocabulary_labels.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

IconData _iconFor(ContentVisibility visibility) => switch (visibility) {
  ContentVisibility.public => Icons.public,
  ContentVisibility.mutual => Icons.group_outlined,
  ContentVisibility.secret => Icons.visibility_off_outlined,
};

/// Read-only chip showing who can see a shelf, locadora or log.
class MuuvieVisibilityChip extends StatelessWidget {
  final ContentVisibility visibility;

  const MuuvieVisibilityChip({super.key, required this.visibility});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final label =
        AppLocalizations.of(context)?.contentVisibility(visibility) ?? '';

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: MuuvieRadius.pillAll,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconFor(visibility),
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Público / Mútuo / Secreto picker used in shelf, locadora and log forms.
class MuuvieVisibilitySelector extends StatelessWidget {
  final ContentVisibility value;
  final ValueChanged<ContentVisibility> onChanged;

  const MuuvieVisibilitySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SegmentedButton<ContentVisibility>(
      segments: [
        for (final visibility in ContentVisibility.values)
          ButtonSegment(
            value: visibility,
            icon: Icon(_iconFor(visibility)),
            label: Text(l10n?.contentVisibility(visibility) ?? ''),
          ),
      ],
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.single),
    );
  }
}
