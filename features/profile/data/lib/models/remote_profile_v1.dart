import 'package:profile_domain/models/models.dart';
import 'package:shelves_data/models/models.dart';

/// A profile as served by `/api/v1/users/{id}`.
class RemoteProfileDetails {
  final Map<String, dynamic> _json;

  const RemoteProfileDetails(this._json);

  factory RemoteProfileDetails.fromJson(Map<String, dynamic> json) =>
      RemoteProfileDetails(json);

  ProfileDetails toDomain() {
    final stats = _json['stats'] as Map<String, dynamic>? ?? const {};
    int count(String key) => (stats[key] as num?)?.toInt() ?? 0;
    return ProfileDetails(
      id: _json['id'] as String,
      username: _json['username'] as String? ?? '',
      handle: _json['handle'] as String?,
      displayName: _json['displayName'] as String?,
      pronouns: _json['pronouns'] as String?,
      bio: _json['bio'] as String?,
      avatarUrl: _json['avatarUrl'] as String?,
      bannerUrl: _json['bannerUrl'] as String?,
      accentColor: _json['accentColor'] as String?,
      links: (_json['links'] as List<dynamic>?)?.cast<String>() ?? const [],
      featured: _json['featured'] as bool? ?? false,
      stats: ProfileStats(
        shelves: count('shelves'),
        locadoras: count('locadoras'),
        watchLogs: count('watchLogs'),
        watched: count('watched'),
        maratonas: count('maratonas'),
        cineclubes: count('cineclubes'),
        participations: count('participations'),
        followers: count('followers'),
        following: count('following'),
      ),
      isFollowing: _json['isFollowing'] as bool? ?? false,
      followsMe: _json['followsMe'] as bool? ?? false,
      mutual: _json['mutual'] as bool? ?? false,
      isSelf: _json['self'] as bool? ?? false,
      isScraping: _json['isScraping'] as bool? ?? false,
    );
  }
}

class RemoteHandleAvailability {
  final String handle;
  final bool available;
  final String? reason;

  const RemoteHandleAvailability({
    required this.handle,
    required this.available,
    this.reason,
  });

  factory RemoteHandleAvailability.fromJson(Map<String, dynamic> json) =>
      RemoteHandleAvailability(
        handle: json['handle'] as String? ?? '',
        available: json['available'] as bool? ?? false,
        reason: json['reason'] as String?,
      );

  HandleAvailability toDomain() => HandleAvailability(
    handle: handle,
    available: available,
    problem: switch (reason) {
      'taken' => HandleProblem.taken,
      'invalid' => HandleProblem.invalid,
      _ => null,
    },
  );
}

class RemoteProfileHighlight {
  final Map<String, dynamic> _json;

  const RemoteProfileHighlight(this._json);

  factory RemoteProfileHighlight.fromJson(Map<String, dynamic> json) =>
      RemoteProfileHighlight(json);

  /// Null for a type this version of the app does not know.
  ProfileHighlight? toDomain() {
    final type = HighlightType.fromWireValue(_json['type'] as String?);
    if (type == null) return null;
    final shelf = _json['shelf'] as Map<String, dynamic>?;
    final locadora = _json['locadora'] as Map<String, dynamic>?;
    return ProfileHighlight(
      type: type,
      enabled: _json['enabled'] as bool? ?? true,
      movieIds:
          (_json['movieIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      shelfId: (_json['shelfId'] as num?)?.toInt(),
      locadoraId: (_json['locadoraId'] as num?)?.toInt(),
      soundtrackUrl: _json['soundtrackUrl'] as String?,
      movies:
          (_json['movies'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .map(
                (movie) => HighlightMovie(
                  movieId: (movie['movieId'] as num).toInt(),
                  tmdbId: (movie['tmdbId'] as num?)?.toInt(),
                  title: movie['title'] as String? ?? '',
                  posterPath: movie['posterPath'] as String?,
                  year: (movie['year'] as num?)?.toInt(),
                ),
              )
              .toList() ??
          const [],
      shelf: shelf == null ? null : RemoteShelf.fromJson(shelf).toDomain(),
      locadora: locadora == null
          ? null
          : RemoteLocadora.fromJson(locadora).toDomain(),
    );
  }
}

class RemoteProfileCard {
  final Map<String, dynamic> _json;

  const RemoteProfileCard(this._json);

  factory RemoteProfileCard.fromJson(Map<String, dynamic> json) =>
      RemoteProfileCard(json);

  ProfileCard toDomain() => ProfileCard(
    id: _json['id'] as String,
    username: _json['username'] as String? ?? '',
    handle: _json['handle'] as String?,
    displayName: _json['displayName'] as String?,
    avatarUrl: _json['avatarUrl'] as String?,
    accentColor: _json['accentColor'] as String?,
    bio: _json['bio'] as String?,
    featured: _json['featured'] as bool? ?? false,
    watched: (_json['watched'] as num?)?.toInt() ?? 0,
    isFollowing: _json['isFollowing'] as bool? ?? false,
  );
}
