import 'package:shelves_domain/models/models.dart';

/// Sections of the Destaques tab (F5.4). A profile has at most one of each.
enum HighlightType {
  top4('top4'),
  shelf('shelf'),
  locadora('locadora'),
  soundtrack('soundtrack');

  final String wireValue;

  const HighlightType(this.wireValue);

  static HighlightType? fromWireValue(String? value) {
    for (final type in values) {
      if (type.wireValue == value) return type;
    }
    return null;
  }
}

/// Where the soundtrack of a profile plays, told apart by the link's host.
enum SoundtrackService {
  spotify('open.spotify.com'),
  youtubeMusic('music.youtube.com');

  final String host;

  const SoundtrackService(this.host);

  /// The service of an https link to one of the hosts; null for anything else.
  static SoundtrackService? of(String? url) {
    final uri = Uri.tryParse(url?.trim() ?? '');
    if (uri == null || uri.scheme != 'https' || uri.path.length < 2) {
      return null;
    }
    for (final service in values) {
      if (uri.host == service.host) return service;
    }
    return null;
  }
}

/// A movie of the top 4.
class HighlightMovie {
  /// Database id (opens the movie detail).
  final int movieId;
  final int? tmdbId;
  final String title;
  final String? posterPath;
  final int? year;

  const HighlightMovie({
    required this.movieId,
    this.tmdbId,
    required this.title,
    this.posterPath,
    this.year,
  });
}

/// A section of the Destaques tab: its configuration and what it points to.
class ProfileHighlight {
  final HighlightType type;
  final bool enabled;
  final List<int> movieIds;
  final int? shelfId;
  final int? locadoraId;
  final String? soundtrackUrl;
  final List<HighlightMovie> movies;
  final Shelf? shelf;
  final Locadora? locadora;

  const ProfileHighlight({
    required this.type,
    this.enabled = true,
    this.movieIds = const [],
    this.shelfId,
    this.locadoraId,
    this.soundtrackUrl,
    this.movies = const [],
    this.shelf,
    this.locadora,
  });

  ProfileHighlight copyWith({bool? enabled}) => ProfileHighlight(
    type: type,
    enabled: enabled ?? this.enabled,
    movieIds: movieIds,
    shelfId: shelfId,
    locadoraId: locadoraId,
    soundtrackUrl: soundtrackUrl,
    movies: movies,
    shelf: shelf,
    locadora: locadora,
  );
}
