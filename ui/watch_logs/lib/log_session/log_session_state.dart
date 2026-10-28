import 'package:core/core.dart';
import 'package:watch_logs/watch_logs.dart';

/// The session form (F2.1). Minutes and percent keep their own values so
/// switching the mode back and forth does not lose them.
class LogSessionState {
  final DateTime watchedOn;
  final WatchMode mode;
  final int minutes;
  final int percent;
  final WatchVenue? venue;
  final String providerName;
  final Set<Emotion> emotions;
  final List<Emotion> recentEmotions;
  final Gif? gif;
  final String comment;
  final bool hasSpoiler;
  final ContentVisibility visibility;
  final bool isSaving;

  const LogSessionState({
    required this.watchedOn,
    this.mode = WatchMode.watched,
    this.minutes = 0,
    this.percent = 0,
    this.venue,
    this.providerName = '',
    this.emotions = const {},
    this.recentEmotions = const [],
    this.gif,
    this.comment = '',
    this.hasSpoiler = false,
    this.visibility = ContentVisibility.public,
    this.isSaving = false,
  });

  WatchLogDraft toDraft() => WatchLogDraft(
    watchedOn: watchedOn,
    mode: mode,
    minutesWatched: mode == WatchMode.minutes ? minutes : null,
    percent: mode == WatchMode.percent ? percent : null,
    venue: venue,
    providerName: providerName.trim().isEmpty ? null : providerName.trim(),
    emotions: emotions.toList(),
    gif: gif,
    comment: comment.trim().isEmpty ? null : comment.trim(),
    hasSpoiler: hasSpoiler,
    visibility: visibility,
  );

  LogSessionState copyWith({
    DateTime? watchedOn,
    WatchMode? mode,
    int? minutes,
    int? percent,
    WatchVenue? Function()? venue,
    String? providerName,
    Set<Emotion>? emotions,
    List<Emotion>? recentEmotions,
    Gif? Function()? gif,
    String? comment,
    bool? hasSpoiler,
    ContentVisibility? visibility,
    bool? isSaving,
  }) => LogSessionState(
    watchedOn: watchedOn ?? this.watchedOn,
    mode: mode ?? this.mode,
    minutes: minutes ?? this.minutes,
    percent: percent ?? this.percent,
    venue: venue != null ? venue() : this.venue,
    providerName: providerName ?? this.providerName,
    emotions: emotions ?? this.emotions,
    recentEmotions: recentEmotions ?? this.recentEmotions,
    gif: gif != null ? gif() : this.gif,
    comment: comment ?? this.comment,
    hasSpoiler: hasSpoiler ?? this.hasSpoiler,
    visibility: visibility ?? this.visibility,
    isSaving: isSaving ?? this.isSaving,
  );
}
