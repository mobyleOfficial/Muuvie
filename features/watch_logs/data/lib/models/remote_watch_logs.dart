import 'package:core/core.dart';
import 'package:watch_logs_domain/models/models.dart';

/// JSON of the v1 watch endpoints (backend README, "Watch sessions, rating and
/// comments") to domain models, and domain drafts to request bodies.
abstract final class RemoteWatchLogs {
  static WatchLog watchLog(Map<String, dynamic> json) => WatchLog(
    id: _int(json['id']),
    userId: json['userId'] as String? ?? '',
    movieId: _int(json['movieId']),
    watchedOn: DateTime.parse(json['watchedOn'] as String),
    cycle: _int(json['cycle'], fallback: 1),
    mode: WatchMode.fromWireValue(json['mode'] as String?) ?? WatchMode.watched,
    minutesWatched: (json['minutesWatched'] as num?)?.toInt(),
    percent: (json['percent'] as num?)?.toInt(),
    completed: json['completed'] as bool? ?? false,
    venue: WatchVenue.fromWireValue(json['venue'] as String?),
    providerName: json['providerName'] as String?,
    emotions: _emotions(json['emotions']),
    gif: switch (json['gif']) {
      final Map<String, dynamic> gif => Gif(
        id: gif['id'] as String,
        url: gif['url'] as String,
        previewUrl: gif['previewUrl'] as String?,
      ),
      _ => null,
    },
    comment: json['comment'] as String?,
    hasSpoiler: json['hasSpoiler'] as bool? ?? false,
    visibility:
        ContentVisibility.fromWireValue(json['visibility'] as String?) ??
        ContentVisibility.public,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime(0),
    self: json['self'] as bool? ?? false,
  );

  static MovieLogHistory history(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};
    final logs = json['logs'] as Map<String, dynamic>? ?? const {};
    return MovieLogHistory(
      summary: WatchLogSummary(
        totalMinutes: _int(summary['totalMinutes']),
        sessions: _int(summary['sessions']),
        rewatches: _int(summary['rewatches']),
        currentCycle: _int(summary['currentCycle'], fallback: 1),
        topEmotions: _emotions(summary['topEmotions']),
      ),
      logs: _list(logs['results']).map(watchLog).toList(),
      page: _int(logs['page'], fallback: 1),
      totalResults: _int(logs['totalResults']),
      hasNext: logs['hasNext'] as bool? ?? false,
    );
  }

  static DiaryPage diary(Map<String, dynamic> json) => DiaryPage(
    entries: _list(json['results']).map((entry) {
      final movie = entry['movie'] as Map<String, dynamic>? ?? const {};
      return DiaryEntry(
        log: watchLog(entry['log'] as Map<String, dynamic>),
        movieId: _int(movie['movieId']),
        tmdbId: (movie['tmdbId'] as num?)?.toInt(),
        title: movie['title'] as String? ?? '',
        posterPath: movie['posterPath'] as String?,
        year: (movie['year'] as num?)?.toInt(),
      );
    }).toList(),
    page: _int(json['page'], fallback: 1),
    totalResults: _int(json['totalResults']),
    hasNext: json['hasNext'] as bool? ?? false,
  );

  static WatchProgress progress(Map<String, dynamic> json) => WatchProgress(
    cycle: _int(json['cycle'], fallback: 1),
    minutes: (json['minutes'] as num?)?.toInt(),
    percent: (json['percent'] as num?)?.toInt(),
    completed: json['completed'] as bool? ?? false,
  );

  static MovieRating rating(Map<String, dynamic> json) => ratingOrNull(json)!;

  /// Null for a label this version of the app does not know.
  static MovieRating? ratingOrNull(Map<String, dynamic> json) {
    final label = Rating.fromWireValue(json['rating'] as String?);
    if (label == null) return null;
    return MovieRating(
      id: _int(json['id']),
      rating: label,
      review: json['review'] as String?,
      hasSpoiler: json['hasSpoiler'] as bool? ?? false,
    );
  }

  static MovieUserState userState(Map<String, dynamic> json) => MovieUserState(
    shelfIds: (json['shelfIds'] as List<dynamic>? ?? const [])
        .map((id) => _int(id))
        .toSet(),
    status: WatchStatus.fromWireValue(json['status'] as String?),
    progress: switch (json['progress']) {
      final Map<String, dynamic> value => progress(value),
      _ => null,
    },
    rating: switch (json['rating']) {
      final Map<String, dynamic> value => ratingOrNull(value),
      _ => null,
    },
    rewatches: _int(json['rewatches']),
    watchingNow: json['watchingNow'] as bool? ?? false,
  );

  static WatchingNow watchingNow(Map<String, dynamic> json) => WatchingNow(
    movieId: _int(json['movieId']),
    tmdbId: (json['tmdbId'] as num?)?.toInt(),
    title: json['title'] as String? ?? '',
    posterPath: json['posterPath'] as String?,
    runtime: (json['runtime'] as num?)?.toInt(),
    progress: switch (json['progress']) {
      final Map<String, dynamic> value => progress(value),
      _ => null,
    },
  );

  static Gif gif(Map<String, dynamic> json) => Gif(
    id: json['id'] as String,
    url: json['url'] as String,
    previewUrl: json['previewUrl'] as String?,
  );

  static GifPage gifPage(Map<String, dynamic> json) => GifPage(
    gifs: _list(json['results']).map(gif).toList(),
    nextCursor: json['nextCursor'] as String?,
  );

  static ThreadComment comment(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? const {};
    return ThreadComment(
      id: _int(json['id']),
      parentId: (json['parentId'] as num?)?.toInt(),
      authorId: author['id'] as String? ?? '',
      authorName: author['username'] as String? ?? '',
      authorAvatarUrl: author['avatarUrl'] as String?,
      body: json['body'] as String? ?? '',
      hasSpoiler: json['hasSpoiler'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime(0),
      self: json['self'] as bool? ?? false,
    );
  }

  static CommentPage commentPage(Map<String, dynamic> json) => CommentPage(
    comments: _list(json['results']).map(comment).toList(),
    page: _int(json['page'], fallback: 1),
    totalResults: _int(json['totalResults']),
    hasNext: json['hasNext'] as bool? ?? false,
  );

  static List<Emotion> emotions(List<dynamic> json) => _emotions(json);

  static Map<String, dynamic> draftBody(WatchLogDraft draft) => {
    'watchedOn': _date(draft.watchedOn),
    'mode': draft.mode.wireValue,
    'minutesWatched': ?draft.minutesWatched,
    'percent': ?draft.percent,
    'venue': ?draft.venue?.wireValue,
    'providerName': ?draft.providerName,
    'emotions': draft.emotions.map((emotion) => emotion.wireValue).toList(),
    if (draft.gif case final gif?) 'gif': {'id': gif.id, 'url': gif.url},
    'comment': ?draft.comment,
    'hasSpoiler': draft.hasSpoiler,
    'visibility': draft.visibility.wireValue,
  };

  static Map<String, dynamic> ratingBody(RatingDraft draft) => {
    'rating': draft.rating.wireValue,
    'review': ?draft.review,
    'hasSpoiler': draft.hasSpoiler,
    'emotions': draft.emotions.map((emotion) => emotion.wireValue).toList(),
    'createLog': draft.createLog,
    'visibility': draft.visibility.wireValue,
  };

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static int _int(dynamic value, {int fallback = 0}) =>
      (value as num?)?.toInt() ?? fallback;

  static List<Map<String, dynamic>> _list(dynamic value) =>
      (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  static List<Emotion> _emotions(dynamic value) =>
      (value as List<dynamic>? ?? const [])
          .map((e) => Emotion.fromWireValue(e as String?))
          .nonNulls
          .toList();
}
