import 'package:core/core.dart';
import 'package:shelves_data/datasources/locadoras_remote_data_source.dart';
import 'package:shelves_data/models/models.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';

class LocadorasRepositoryImpl implements LocadorasRepository {
  final LocadorasRemoteDataSource _remoteDataSource;

  LocadorasRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<Paged<Locadora>>> getUserLocadoras({
    required String userId,
    required int page,
  }) async => switch (await _remoteDataSource.getUserLocadoras(
    userId: userId,
    page: page,
  )) {
    Success(:final data) => Success(data.toDomain((l) => l.toDomain())),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<Paged<Locadora>>> discoverLocadoras({
    String? query,
    required int page,
  }) async => switch (await _remoteDataSource.discoverLocadoras(
    query: query,
    page: page,
  )) {
    Success(:final data) => Success(data.toDomain((l) => l.toDomain())),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<Locadora>> getLocadora(int locadoraId) async =>
      _locadora(await _remoteDataSource.getLocadora(locadoraId));

  @override
  Future<Result<Locadora>> createLocadora(LocadoraDraft draft) async =>
      _locadora(await _remoteDataSource.createLocadora(draft));

  @override
  Future<Result<Locadora>> updateLocadora(
    int locadoraId,
    LocadoraDraft draft,
  ) async =>
      _locadora(await _remoteDataSource.updateLocadora(locadoraId, draft));

  @override
  Future<Result<void>> deleteLocadora(int locadoraId) =>
      _remoteDataSource.deleteLocadora(locadoraId);

  @override
  Future<Result<Paged<LocadoraShelf>>> getLocadoraShelves({
    required int locadoraId,
    required int page,
  }) async => switch (await _remoteDataSource.getLocadoraShelves(
    locadoraId: locadoraId,
    page: page,
  )) {
    Success(:final data) => Success(data.toDomain((s) => s.toDomain())),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<void>> setLocadoraShelves({
    required int locadoraId,
    required List<int> shelfIds,
  }) => _remoteDataSource.setLocadoraShelves(
    locadoraId: locadoraId,
    shelfIds: shelfIds,
  );

  @override
  Future<Result<void>> reorderLocadoraShelves({
    required int locadoraId,
    required List<int> shelfIds,
  }) => _remoteDataSource.reorderLocadoraShelves(
    locadoraId: locadoraId,
    shelfIds: shelfIds,
  );

  @override
  Future<Result<void>> reorderLocadoras({
    required List<int> locadoraIds,
    List<int>? pinnedIds,
  }) => _remoteDataSource.reorderLocadoras(
    locadoraIds: locadoraIds,
    pinnedIds: pinnedIds,
  );

  Result<Locadora> _locadora(Result<RemoteLocadora> result) => switch (result) {
    Success(:final data) => Success(data.toDomain()),
    Failure(:final error) => Failure(error),
  };
}
