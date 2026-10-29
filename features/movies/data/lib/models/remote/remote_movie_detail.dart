import 'package:movies_data/models/remote/remote_movie.dart';
import 'package:movies_domain/domain.dart';

class RemoteMovieDetail {
  final int id;
  final String title;
  final String? localTitle;
  final String overview;

  /// ISO 639-1 of [overview] when it is not Portuguese; absent otherwise.
  final String? overviewLanguage;

  /// True when [overview] was machine translated into Portuguese.
  final bool overviewTranslated;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final String tagline;
  final int? runtime;
  final List<String> genres;
  final String? director;
  final int? directorId;
  final List<CastMember>? cast;
  final List<Person>? writers;
  final String? trailerKey;
  final List<RemoteWatchProvider>? watchProviders;
  final List<RemoteMovie>? similarMovies;

  /// `matched`, `pending` or `unmatched`; absent on older backends.
  final String? matchStatus;

  const RemoteMovieDetail({
    required this.id,
    required this.title,
    this.localTitle,
    required this.overview,
    this.overviewLanguage,
    this.overviewTranslated = false,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.tagline,
    required this.runtime,
    required this.genres,
    this.director,
    this.directorId,
    this.cast,
    this.writers,
    this.trailerKey,
    this.watchProviders,
    this.similarMovies,
    this.matchStatus,
  });

  factory RemoteMovieDetail.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genres'] as List<dynamic>? ?? [];
    final genres = rawGenres.isEmpty
        ? <String>[]
        : rawGenres.first is String
        ? rawGenres.cast<String>()
        : rawGenres
              .cast<Map<String, dynamic>>()
              .map((g) => g['name'] as String)
              .toList();

    return RemoteMovieDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      localTitle: (json['localTitle'] ?? json['local_title']) as String?,
      overview: json['overview'] as String,
      overviewLanguage: json['overviewLanguage'] as String?,
      overviewTranslated: json['overviewTranslated'] as bool? ?? false,
      posterPath: (json['posterPath'] ?? json['poster_path']) as String? ?? '',
      backdropPath:
          (json['backdropPath'] ?? json['backdrop_path']) as String? ?? '',
      releaseDate:
          (json['releaseDate'] ?? json['release_date']) as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      runtime: json['runtime'] as int?,
      genres: genres,
      director: _parseDirector(json['director']),
      directorId: json['director'] is Map<String, dynamic>
          ? ((json['director'] as Map<String, dynamic>)['id'] as num?)?.toInt()
          : null,
      cast: _parseCast(json['cast']),
      writers: (json['writers'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(
            (person) => Person(
              id: (person['id'] as num?)?.toInt() ?? 0,
              tmdbPersonId: (person['tmdbPersonId'] as num?)?.toInt(),
              name: person['name'] as String? ?? '',
              profilePath: person['profilePath'] as String?,
            ),
          )
          .where((person) => person.name.isNotEmpty)
          .toList(),
      trailerKey: json['trailerKey'] as String?,
      watchProviders: (json['watchProviders'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(RemoteWatchProvider.fromJson)
          .toList(),
      matchStatus: json['matchStatus'] as String?,
      similarMovies: (json['similarMovies'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(RemoteMovie.fromJson)
          .toList(),
    );
  }

  static String? _parseDirector(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is Map<String, dynamic>) return raw['name'] as String?;
    return null;
  }

  static List<CastMember>? _parseCast(dynamic raw) {
    if (raw == null) return null;
    if (raw is! List) return null;
    if (raw.isEmpty) return [];
    if (raw.first is String) {
      return raw
          .cast<String>()
          .where((n) => n.isNotEmpty)
          .map((name) => CastMember(person: Person(id: 0, name: name)))
          .toList();
    }
    return raw
        .cast<Map<String, dynamic>>()
        .map((c) {
          final person = c['person'] as Map<String, dynamic>?;
          return CastMember(
            person: Person(
              id: (person?['id'] as num?)?.toInt() ?? 0,
              tmdbPersonId:
                  (person?['tmdbPersonId'] as num?)?.toInt() ??
                  (c['tmdbPersonId'] as num?)?.toInt(),
              name: person?['name'] as String? ?? c['name'] as String? ?? '',
              profilePath:
                  person?['profilePath'] as String? ??
                  c['profilePath'] as String? ??
                  c['profile_path'] as String?,
            ),
            character: c['character'] as String?,
            order: (c['order'] as num?)?.toInt(),
          );
        })
        .where((m) => m.person.name.isNotEmpty)
        .toList();
  }

  Movie toDomain() => Movie(
    id: id,
    title: title,
    localTitle: localTitle,
    posterPath: posterPath,
    info: MovieInfo(
      overview: overview,
      overviewLanguage: overviewLanguage,
      overviewTranslated: overviewTranslated,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
      tagline: tagline,
      runtime: runtime ?? 0,
      genres: genres,
      director: director ?? '',
      directorId: directorId,
      cast: cast ?? const [],
      writers: writers ?? const [],
      trailerKey: trailerKey,
      watchProviders:
          watchProviders?.map((provider) => provider.toDomain()).toList() ??
          const [],
      similarMovies:
          similarMovies?.map((movie) => movie.toDomain()).toList() ?? const [],
      isUnmatched: matchStatus == 'unmatched',
    ),
  );
}

class RemoteWatchProvider {
  final String name;
  final String logoPath;

  const RemoteWatchProvider({required this.name, required this.logoPath});

  factory RemoteWatchProvider.fromJson(Map<String, dynamic> json) =>
      RemoteWatchProvider(
        name: json['name'] as String,
        logoPath: (json['logoPath'] ?? json['logo_path']) as String? ?? '',
      );

  WatchProvider toDomain() => WatchProvider(name: name, logoPath: logoPath);
}
