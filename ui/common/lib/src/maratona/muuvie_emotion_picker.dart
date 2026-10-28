import 'package:common/app_localizations.dart';
import 'package:common/src/vocabulary/vocabulary_labels.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Picks up to [max] emotions for a watch session. [recent] ones come first.
class MuuvieEmotionPicker extends StatelessWidget {
  final Set<Emotion> selected;
  final ValueChanged<Set<Emotion>> onChanged;
  final List<Emotion> recent;
  final int max;

  const MuuvieEmotionPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.recent = const [],
    this.max = Emotion.maxPerLog,
  });

  List<Emotion> get _ordered => [
    ...recent,
    ...Emotion.values.where((emotion) => !recent.contains(emotion)),
  ];

  void _toggle(Emotion emotion) {
    final next = {...selected};
    if (!next.remove(emotion) && next.length < max) next.add(emotion);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isFull = selected.length >= max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            l10n?.emotionPickerCount(selected.length, max) ?? '',
            style: textTheme.labelMedium,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final emotion in _ordered)
              FilterChip(
                label: Text(l10n?.emotion(emotion) ?? emotion.wireValue),
                selected: selected.contains(emotion),
                // Once full, only selected chips can be tapped (to unselect).
                onSelected: isFull && !selected.contains(emotion)
                    ? null
                    : (_) => _toggle(emotion),
              ),
          ],
        ),
      ],
    );
  }
}
