import 'package:core/core.dart';
import 'package:watch_logs_domain/models/gif.dart';

/// One watch session (F2.1). [cycle] is 1 on the first watch and grows with each rewatch.
class WatchLog {
  final int id;
  final String userId;
  final int movieId;
  final DateTime watchedOn;
  final int cycle;
  final WatchMode mode;
  final int? minutesWatched;
  final int? percent;
  final bool completed;
  final WatchVenue? venue;
  final String? providerName;
  final List<Emotion> emotions;
  final Gif? gif;
  final String? comment;
  final bool hasSpoiler;
  final ContentVisibility visibility;
  final DateTime createdAt;

  /// The log belongs to the current user.
  final bool self;

  const WatchLog({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.watchedOn,
    required this.cycle,
    required this.mode,
    this.minutesWatched,
    this.percent,
    required this.completed,
    this.venue,
    this.providerName,
    this.emotions = const [],
    this.gif,
    this.comment,
    this.hasSpoiler = false,
    this.visibility = ContentVisibility.public,
    required this.createdAt,
    this.self = false,
  });
}
