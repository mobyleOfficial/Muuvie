import 'package:core/core.dart';
import 'package:movies_domain/models/person_detail.dart';
import 'package:movies_domain/repositories/persons_repository.dart';

class GetPersonDetailParams {
  /// Database id; 0 when only the TMDB id is known.
  final int personId;
  final int? tmdbPersonId;

  const GetPersonDetailParams({required this.personId, this.tmdbPersonId});
}

/// The page of an actor or director (F5.7). The cast of the movie detail comes
/// from TMDB without a database id, so the TMDB id is used then.
class GetPersonDetail
    extends UseCase<GetPersonDetailParams, Result<PersonDetail>> {
  final PersonsRepository _repository;

  GetPersonDetail(this._repository);

  @override
  Future<Result<PersonDetail>> call([GetPersonDetailParams? params]) {
    final value = params!;
    final tmdbId = value.tmdbPersonId;
    if (value.personId <= 0 && tmdbId != null) {
      return _repository.getPersonDetailByTmdbId(tmdbId);
    }
    return _repository.getPersonDetail(value.personId);
  }
}
