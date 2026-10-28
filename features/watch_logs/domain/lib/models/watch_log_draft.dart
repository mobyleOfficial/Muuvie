import 'package:core/core.dart';
import 'package:watch_logs_domain/models/gif.dart';

/// Fields of a watch session form. The server resolves minutes and percent against the runtime.
class WatchLogDraft {
  final DateTime watchedOn;
  final WatchMode mode;
  final int? minutesWatched;
  final int? percent;
  final WatchVenue? venue;
  final String? providerName;
  final List<Emotion> emotions;
  final Gif? gif;
  final String? comment;
  final bool hasSpoiler;
  final ContentVisibility visibility;

  const WatchLogDraft({
    required this.watchedOn,
    this.mode = WatchMode.watched,
    this.minutesWatched,
    this.percent,
    this.venue,
    this.providerName,
    this.emotions = const [],
    this.gif,
    this.comment,
    this.hasSpoiler = false,
    this.visibility = ContentVisibility.public,
  });

  /// The one-tap "Já assisti": only the date (F2.1).
  factory WatchLogDraft.watchedOn(DateTime date) =>
      WatchLogDraft(watchedOn: date);
}
