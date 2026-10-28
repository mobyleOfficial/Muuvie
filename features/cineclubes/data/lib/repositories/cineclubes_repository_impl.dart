import 'package:cineclubes_data/datasources/cineclubes_remote_data_source.dart';
import 'package:cineclubes_domain/models/models.dart';
import 'package:cineclubes_domain/repositories/cineclubes_repository.dart';
import 'package:core/core.dart';

class CineClubesRepositoryImpl implements CineClubesRepository {
  final CineClubesRemoteDataSource _remoteDataSource;

  CineClubesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<CineClubePage>> getCineClubes(
    CineClubeFilter filter, {
    int page = 1,
  }) => _remoteDataSource.getCineClubes(filter, page);

  @override
  Future<Result<CineClube>> getCineClube(String slug) =>
      _remoteDataSource.getCineClube(slug);

  @override
  Future<Result<CineClubeSlug>> checkSlug(String slug) =>
      _remoteDataSource.checkSlug(slug);

  @override
  Future<Result<CineClube>> create(CineClubeForm form) =>
      _remoteDataSource.create(form);

  @override
  Future<Result<CineClube>> update(String slug, CineClubeForm form) =>
      _remoteDataSource.update(slug, form);

  @override
  Future<Result<CineClube>> cancel(String slug) =>
      _remoteDataSource.cancel(slug);

  @override
  Future<Result<CineClube>> join(String slug, {String? password}) =>
      _remoteDataSource.join(slug, password);

  @override
  Future<Result<void>> leave(String slug) => _remoteDataSource.leave(slug);

  @override
  Future<Result<CineClubeLogPage>> getProgress(
    String slug, {
    int? sessionId,
    int page = 1,
  }) => _remoteDataSource.getProgress(slug, sessionId, page);

  @override
  Future<Result<ParticipantPage>> getParticipants(
    String slug, {
    int? sessionId,
    SessionProgress? progress,
    int page = 1,
  }) => _remoteDataSource.getParticipants(slug, sessionId, progress, page);
}
