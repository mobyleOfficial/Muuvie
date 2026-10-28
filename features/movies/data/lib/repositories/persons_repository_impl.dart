import 'package:core/core.dart';
import 'package:movies_data/datasources/remote/persons_remote_data_source.dart';
import 'package:movies_domain/models/person_detail.dart';
import 'package:movies_domain/repositories/persons_repository.dart';

class PersonsRepositoryImpl implements PersonsRepository {
  final PersonsRemoteDataSource _remoteDataSource;

  PersonsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<PersonDetail>> getPersonDetail(int personId) =>
      _remoteDataSource.getPersonDetail(personId);

  @override
  Future<Result<PersonDetail>> getPersonDetailByTmdbId(int tmdbPersonId) =>
      _remoteDataSource.getPersonDetailByTmdbId(tmdbPersonId);
}
