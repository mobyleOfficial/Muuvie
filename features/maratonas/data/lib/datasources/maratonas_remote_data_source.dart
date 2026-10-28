import 'package:core/core.dart';
import 'package:maratonas_data/models/remote_maratonas.dart';
import 'package:maratonas_domain/models/models.dart';

abstract interface class MaratonasRemoteDataSource {
  Future<Result<MaratonaPage>> getMaratonas(MaratonaFilter filter, int page);

  Future<Result<Maratona>> getMaratona(String slug);

  Future<Result<SlugAvailability>> checkSlug(String slug);

  Future<Result<Maratona>> create(MaratonaForm form);

  Future<Result<Maratona>> update(String slug, MaratonaForm form);

  Future<Result<Maratona>> cancel(String slug);

  Future<Result<Maratona>> join(
    String slug,
    int? levelId,
    int? teamId,
    String? password,
  );

  Future<Result<void>> leave(String slug);

  Future<Result<List<MaratonaCategory>>> getChallenges(String slug);

  Future<Result<SuggestionPage>> getSuggestions(
    String slug,
    int challengeId,
    int page,
  );

  Future<Result<MaratonaChallenge>> setLink(
    String slug,
    int challengeId,
    int movieId,
    bool linked,
  );

  Future<Result<RankingPage>> getRanking(String slug, int page);

  Future<Result<List<TeamRankingEntry>>> getTeamRanking(String slug);

  Future<Result<List<MaratonaTemplate>>> getTemplates();

  Future<Result<Maratona>> createFromTemplate(
    String templateId,
    String slug,
    DateTime startsOn,
    String? title,
  );
}

/// Maratona endpoints of the v1 API (`/api/v1`). See the backend README.
class MaratonasRemoteDataSourceImpl implements MaratonasRemoteDataSource {
  static const _base = '/api/v1';
  static const _pageSize = 20;

  final HttpClient _httpClient;

  MaratonasRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<MaratonaPage>> getMaratonas(
    MaratonaFilter filter,
    int page,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/maratonas',
      queryParams: {
        'q': ?filter.query?.trim().nullIfEmpty,
        if (filter.open) 'open': true,
        if (filter.includeFinished) 'includeFinished': true,
        if (filter.trusted) 'trusted': true,
        if (filter.mine) 'mine': true,
        'participant': ?filter.participant,
        'page': page,
        'limit': _pageSize,
      },
    ),
    RemoteMaratonas.page,
  );

  @override
  Future<Result<Maratona>> getMaratona(String slug) async => _map(
    await _httpClient.get<Map<String, dynamic>>(_path(slug)),
    RemoteMaratonas.maratona,
  );

  @override
  Future<Result<SlugAvailability>> checkSlug(String slug) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/maratonas/slug-available',
      queryParams: {'slug': slug},
    ),
    RemoteMaratonas.slug,
  );

  @override
  Future<Result<Maratona>> create(MaratonaForm form) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/maratonas',
      body: RemoteMaratonas.form(form),
    ),
    RemoteMaratonas.maratona,
  );

  @override
  Future<Result<Maratona>> update(String slug, MaratonaForm form) async => _map(
    await _httpClient.put<Map<String, dynamic>>(
      _path(slug),
      body: RemoteMaratonas.form(form),
    ),
    RemoteMaratonas.maratona,
  );

  @override
  Future<Result<Maratona>> cancel(String slug) async => _map(
    await _httpClient.post<Map<String, dynamic>>('${_path(slug)}/cancel'),
    RemoteMaratonas.maratona,
  );

  @override
  Future<Result<Maratona>> join(
    String slug,
    int? levelId,
    int? teamId,
    String? password,
  ) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '${_path(slug)}/participation',
      body: {'levelId': ?levelId, 'teamId': ?teamId, 'password': ?password},
    ),
    RemoteMaratonas.maratona,
  );

  @override
  Future<Result<void>> leave(String slug) async => _ignoreBody(
    await _httpClient.delete<dynamic>('${_path(slug)}/participation'),
  );

  @override
  Future<Result<List<MaratonaCategory>>> getChallenges(String slug) async =>
      switch (await _httpClient.get<List<dynamic>>(
        '${_path(slug)}/challenges',
      )) {
        Success(:final data) => Success(RemoteMaratonas.categories(data)),
        Failure(:final error) => Failure(error),
      };

  @override
  Future<Result<SuggestionPage>> getSuggestions(
    String slug,
    int challengeId,
    int page,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '${_path(slug)}/challenges/$challengeId/suggestions',
      queryParams: {'page': page},
    ),
    RemoteMaratonas.suggestions,
  );

  @override
  Future<Result<MaratonaChallenge>> setLink(
    String slug,
    int challengeId,
    int movieId,
    bool linked,
  ) async {
    final path = '${_path(slug)}/challenges/$challengeId/links/$movieId';
    return _map(
      linked
          ? await _httpClient.put<Map<String, dynamic>>(path)
          : await _httpClient.delete<Map<String, dynamic>>(path),
      RemoteMaratonas.challenge,
    );
  }

  @override
  Future<Result<RankingPage>> getRanking(String slug, int page) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '${_path(slug)}/ranking',
      queryParams: {'by': 'user', 'page': page, 'limit': _pageSize},
    ),
    RemoteMaratonas.ranking,
  );

  @override
  Future<Result<List<TeamRankingEntry>>> getTeamRanking(String slug) async =>
      _map(
        await _httpClient.get<Map<String, dynamic>>(
          '${_path(slug)}/ranking',
          queryParams: {'by': 'team'},
        ),
        RemoteMaratonas.teamRanking,
      );

  @override
  Future<Result<List<MaratonaTemplate>>> getTemplates() async =>
      switch (await _httpClient.get<List<dynamic>>(
        '$_base/maratona-templates',
      )) {
        Success(:final data) => Success(RemoteMaratonas.templates(data)),
        Failure(:final error) => Failure(error),
      };

  @override
  Future<Result<Maratona>> createFromTemplate(
    String templateId,
    String slug,
    DateTime startsOn,
    String? title,
  ) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/maratonas/from-template/${Uri.encodeComponent(templateId)}',
      body: {
        'slug': slug,
        'startsOn': RemoteMaratonas.day(startsOn),
        'title': ?title,
      },
    ),
    RemoteMaratonas.maratona,
  );

  String _path(String slug) => '$_base/maratonas/${Uri.encodeComponent(slug)}';

  Result<T> _map<T>(
    Result<Map<String, dynamic>> result,
    T Function(Map<String, dynamic>) fromJson,
  ) => switch (result) {
    Success(:final data) => Success(fromJson(data)),
    Failure(:final error) => Failure(error),
  };

  Result<void> _ignoreBody(Result<dynamic> result) => switch (result) {
    Success() => const Success(null),
    Failure(:final error) => Failure(error),
  };
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
