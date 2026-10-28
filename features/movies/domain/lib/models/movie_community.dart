import 'package:core/core.dart';

/// What the community did with a movie (B13.2). Only people whose Já assisti
/// (ratings and watched) or Quero ver is public count; [shelves] counts the
/// public custom shelves and [emotions] comes from the public sessions.
class MovieCommunity {
  /// How many people gave each label; labels nobody gave are absent.
  final Map<Rating, int> ratings;
  final int watched;
  final int wantToWatch;
  final int shelves;

  /// Every emotion marked at least once, the most marked first (B13.5).
  final List<EmotionCount> emotions;

  const MovieCommunity({
    this.ratings = const {},
    this.watched = 0,
    this.wantToWatch = 0,
    this.shelves = 0,
    this.emotions = const [],
  });

  int get totalRatings => ratings.values.fold(0, (sum, count) => sum + count);

  bool get isEmpty =>
      totalRatings == 0 &&
      watched == 0 &&
      wantToWatch == 0 &&
      shelves == 0 &&
      emotions.isEmpty;
}

class EmotionCount {
  final Emotion emotion;
  final int count;

  const EmotionCount({required this.emotion, required this.count});
}

/// Where a movie shows up in the Programação (F12.1).
class MovieEvents {
  final List<MovieEvent> maratonas;
  final List<MovieEvent> cineclubes;

  const MovieEvents({this.maratonas = const [], this.cineclubes = const []});

  bool get isEmpty => maratonas.isEmpty && cineclubes.isEmpty;
}

/// A maratona or CineClube, as the movie detail lists it.
class MovieEvent {
  final String slug;
  final String title;
  final String? accentColor;

  /// `upcoming`, `active` or, in the history pages, `finished`.
  final String status;
  final DateTime startsOn;
  final DateTime endsOn;
  final int participants;
  final bool joined;

  /// Maratonas: the challenges the movie completes. Empty for CineClubes.
  final List<String> challenges;

  const MovieEvent({
    required this.slug,
    required this.title,
    this.accentColor,
    required this.status,
    required this.startsOn,
    required this.endsOn,
    this.participants = 0,
    this.joined = false,
    this.challenges = const [],
  });

  bool get isUpcoming => status == 'upcoming';

  bool get isFinished => status == 'finished';
}

/// A page of the CineClubes that screened a movie or the maratonas it
/// counted in (B13.5).
class MovieEventPage {
  final List<MovieEvent> items;
  final int page;
  final int totalResults;
  final bool hasNext;

  const MovieEventPage({
    this.items = const [],
    this.page = 1,
    this.totalResults = 0,
    this.hasNext = false,
  });
}

/// Public sessions and ratings of a movie per month, oldest first (B13.5).
class MovieTimeline {
  final List<MonthActivity> months;

  const MovieTimeline({this.months = const []});

  bool get isEmpty =>
      months.every((month) => month.sessions == 0 && month.ratings == 0);
}

class MonthActivity {
  /// First day of the month.
  final DateTime month;
  final int sessions;
  final int ratings;

  const MonthActivity({
    required this.month,
    this.sessions = 0,
    this.ratings = 0,
  });
}
