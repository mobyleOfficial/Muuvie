import 'package:core/core.dart';
import 'package:movies_domain/models/person_detail.dart';

abstract interface class PersonsRepository {
  /// [personId] is the database id of the person (the `id` in the cast).
  Future<Result<PersonDetail>> getPersonDetail(int personId);

  /// The movie detail lists the cast straight from TMDB, with only the TMDB id.
  Future<Result<PersonDetail>> getPersonDetailByTmdbId(int tmdbPersonId);
}
