import 'package:core/core.dart';
import 'package:movies_domain/models/models.dart';

/// `GET /api/v1/persons/{id}`: the person and the catalog movies they are in.
class PersonsRemoteDataSource {
  final HttpClient _httpClient;

  PersonsRemoteDataSource(this._httpClient);

  Future<Result<PersonDetail>> getPersonDetail(int personId) =>
      _get('/api/v1/persons/$personId');

  Future<Result<PersonDetail>> getPersonDetailByTmdbId(int tmdbPersonId) =>
      _get('/api/v1/persons/tmdb/$tmdbPersonId');

  Future<Result<PersonDetail>> _get(String path) async {
    final result = await _httpClient.get<Map<String, dynamic>>(path);
    return switch (result) {
      Success(:final data) => Success(_detail(data)),
      Failure(:final error) => Failure(error),
    };
  }

  static PersonDetail _detail(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>;
    return PersonDetail(
      person: Person(
        id: (person['id'] as num).toInt(),
        tmdbPersonId: (person['tmdbPersonId'] as num?)?.toInt(),
        name: person['name'] as String? ?? '',
        profilePath: person['profilePath'] as String?,
      ),
      credits: (json['credits'] as List<dynamic>? ?? const [])
          .map((e) => e as Map<String, dynamic>)
          .map((credit) {
            final movie = credit['movie'] as Map<String, dynamic>;
            return PersonCredit(
              movieId: (movie['id'] as num).toInt(),
              tmdbId: (movie['tmdbId'] as num?)?.toInt(),
              title: movie['localTitle'] as String? ?? movie['title'] as String,
              posterPath: movie['posterPath'] as String?,
              releaseDate: movie['releaseDate'] as String?,
              role: credit['role'] as String? ?? 'cast',
              character: credit['character'] as String?,
            );
          })
          .toList(),
    );
  }
}
