import 'package:core/core.dart';
import 'package:profile_data/datasources/profiles_remote_data_source.dart';
import 'package:profile_data/models/remote_profile_v1.dart';
import 'package:profile_domain/models/models.dart';
import 'package:shelves_data/models/remote_page.dart';

class ProfilesRemoteDataSourceImpl implements ProfilesRemoteDataSource {
  static const _base = '/api/v1';
  static const _pageSize = 20;

  final HttpClient _httpClient;

  ProfilesRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<RemoteProfileDetails>> getProfile(String userId) async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_base/users/$userId'),
    RemoteProfileDetails.fromJson,
  );

  @override
  Future<Result<RemoteProfileDetails>> updateMyProfile(
    ProfileDraft draft,
  ) async => _map(
    await _httpClient.put<Map<String, dynamic>>(
      '$_base/users/me',
      body: {
        'displayName': draft.displayName,
        'handle': draft.handle,
        'pronouns': draft.pronouns,
        'bio': draft.bio,
        'links': draft.links,
        'accentColor': draft.accentColor,
        'avatarUrl': draft.avatarUrl,
        'bannerUrl': draft.bannerUrl,
      },
    ),
    RemoteProfileDetails.fromJson,
  );

  @override
  Future<Result<RemoteHandleAvailability>> checkHandle(String handle) async =>
      _map(
        await _httpClient.get<Map<String, dynamic>>(
          '$_base/handles/$handle/available',
        ),
        RemoteHandleAvailability.fromJson,
      );

  @override
  Future<Result<List<RemoteProfileHighlight>>> getHighlights(
    String userId,
  ) async => _list(
    await _httpClient.get<List<dynamic>>('$_base/users/$userId/highlights'),
  );

  @override
  Future<Result<List<RemoteProfileHighlight>>> saveHighlights(
    List<ProfileHighlight> highlights,
  ) async => _list(
    await _httpClient.put<List<dynamic>>(
      '$_base/users/me/highlights',
      body: {
        'highlights': [
          for (final highlight in highlights)
            {
              'type': highlight.type.wireValue,
              'enabled': highlight.enabled,
              'movieIds': highlight.movieIds,
              'shelfId': highlight.shelfId,
              'locadoraId': highlight.locadoraId,
              'soundtrackUrl': highlight.soundtrackUrl,
            },
        ],
      },
    ),
  );

  @override
  Future<Result<RemotePage<RemoteProfileCard>>> discoverProfiles({
    String? query,
    required int page,
  }) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/discover/profiles',
      queryParams: {
        if (query != null && query.isNotEmpty) 'q': query,
        'page': page,
        'limit': _pageSize,
      },
    ),
    (json) => RemotePage.fromJson(json, RemoteProfileCard.fromJson),
  );

  Result<T> _map<T>(
    Result<Map<String, dynamic>> result,
    T Function(Map<String, dynamic>) fromJson,
  ) => switch (result) {
    Success(:final data) => Success(fromJson(data)),
    Failure(:final error) => Failure(error),
  };

  Result<List<RemoteProfileHighlight>> _list(Result<List<dynamic>> result) =>
      switch (result) {
        Success(:final data) => Success(
          data
              .map(
                (e) =>
                    RemoteProfileHighlight.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
        Failure(:final error) => Failure(error),
      };
}
