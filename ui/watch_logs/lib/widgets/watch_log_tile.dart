import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/widgets/spoiler_text.dart';

enum _LogAction { edit, delete }

/// One session of the history: date, progress, where, emotions, GIF and comment.
class WatchLogTile extends StatelessWidget {
  final WatchLog log;
  final int? runtime;

  /// Null hides the action (sessions of other users).
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WatchLogTile({
    super.key,
    required this.log,
    this.runtime,
    this.onEdit,
    this.onDelete,
  });

  String _progressLabel(AppLocalizations? l10n) {
    if (log.completed) return l10n?.watchStatus(WatchStatus.watched) ?? '';
    final minutes = log.minutesWatched;
    final total = runtime;
    if (minutes != null && total != null && total > 0) {
      return l10n?.movieProgressMinutes(minutes, total) ?? '';
    }
    final percent = log.percent;
    if (percent != null) return l10n?.watchProgressPercent(percent) ?? '';
    return minutes != null ? l10n?.watchLogMinutesValue(minutes) ?? '' : '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final gif = log.gif;
    final comment = log.comment;
    final venue = log.venue;
    final where = [
      if (venue != null) l10n?.watchVenue(venue) ?? '',
      ?log.providerName,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(log.watchedOn),
                        style: textTheme.titleSmall,
                      ),
                      Text(
                        _progressLabel(l10n),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (where.isNotEmpty)
                        Text(
                          where,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                MuuvieVisibilityChip(visibility: log.visibility),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<_LogAction>(
                    onSelected: (action) => switch (action) {
                      _LogAction.edit => onEdit?.call(),
                      _LogAction.delete => onDelete?.call(),
                    },
                    itemBuilder: (_) => [
                      if (onEdit != null)
                        PopupMenuItem(
                          value: _LogAction.edit,
                          child: Text(l10n?.historyEdit ?? ''),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: _LogAction.delete,
                          child: Text(l10n?.historyDelete ?? ''),
                        ),
                    ],
                  ),
              ],
            ),
            if (log.emotions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final emotion in log.emotions)
                    Chip(
                      label: Text(l10n?.emotion(emotion) ?? emotion.wireValue),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            if (gif != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: MuuvieRadius.mediumAll,
                child: Semantics(
                  label: l10n?.gifLabel ?? '',
                  image: true,
                  child: CachedNetworkImage(
                    imageUrl: gif.url,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            if (comment != null) ...[
              const SizedBox(height: 8),
              log.hasSpoiler
                  ? SpoilerText(text: comment)
                  : Text(comment, style: textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
