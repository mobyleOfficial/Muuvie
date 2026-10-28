import 'package:core/core.dart';
import 'package:profile_data/datasources/profiles_remote_data_source.dart';
import 'package:profile_data/models/remote_profile_v1.dart';
import 'package:profile_domain/models/models.dart';
import 'package:profile_domain/repositories/profiles_repository.dart';
import 'package:shelves_domain/models/paged.dart';

class ProfilesRepositoryImpl implements ProfilesRepository {
  final ProfilesRemoteDataSource _remoteDataSource;

  ProfilesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<ProfileDetails>> getProfile(String userId) async =>
      _profile(await _remoteDataSource.getProfile(userId));

  @override
  Future<Result<ProfileDetails>> updateMyProfile(ProfileDraft draft) async =>
      _profile(await _remoteDataSource.updateMyProfile(draft));

  @override
  Future<Result<HandleAvailability>> checkHandle(String handle) async =>
      switch (await _remoteDataSource.checkHandle(handle)) {
        Success(:final data) => Success(data.toDomain()),
        Failure(:final error) => Failure(error),
      };

  @override
  Future<Result<List<ProfileHighlight>>> getHighlights(String userId) async =>
      _highlights(await _remoteDataSource.getHighlights(userId));

  @override
  Future<Result<List<ProfileHighlight>>> saveHighlights(
    List<ProfileHighlight> highlights,
  ) async => _highlights(await _remoteDataSource.saveHighlights(highlights));

  @override
  Future<Result<Paged<ProfileCard>>> discoverProfiles({
    String? query,
    required int page,
  }) async => switch (await _remoteDataSource.discoverProfiles(
    query: query,
    page: page,
  )) {
    Success(:final data) => Success(data.toDomain((card) => card.toDomain())),
    Failure(:final error) => Failure(error),
  };

  Result<ProfileDetails> _profile(Result<RemoteProfileDetails> result) =>
      switch (result) {
        Success(:final data) => Success(data.toDomain()),
        Failure(:final error) => Failure(error),
      };

  Result<List<ProfileHighlight>> _highlights(
    Result<List<RemoteProfileHighlight>> result,
  ) => switch (result) {
    Success(:final data) => Success(
      data.map((e) => e.toDomain()).whereType<ProfileHighlight>().toList(),
    ),
    Failure(:final error) => Failure(error),
  };
}
