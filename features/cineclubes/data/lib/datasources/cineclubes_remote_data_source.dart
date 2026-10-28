import 'package:cineclubes_data/models/remote_cineclubes.dart';
import 'package:cineclubes_domain/models/models.dart';
import 'package:core/core.dart';

abstract interface class CineClubesRemoteDataSource {
  Future<Result<CineClubePage>> getCineClubes(CineClubeFilter filter, int page);

  Future<Result<CineClube>> getCineClube(String slug);

  Future<Result<CineClubeSlug>> checkSlug(String slug);

  Future<Result<CineClube>> create(CineClubeForm form);

  Future<Result<CineClube>> update(String slug, CineClubeForm form);

  Future<Result<CineClube>> cancel(String slug);

  Future<Result<CineClube>> join(String slug, String? password);

  Future<Result<void>> leave(String slug);

  Future<Result<CineClubeLogPage>> getProgress(
    String slug,
    int? sessionId,
    int page,
  );

  Future<Result<ParticipantPage>> getParticipants(
    String slug,
    int? sessionId,
    SessionProgress? progress,
    int page,
  );
}

/// CineClube endpoints of the v1 API (`/api/v1`). See the backend README.
class CineClubesRemoteDataSourceImpl implements CineClubesRemoteDataSource {
  static const _base = '/api/v1';
  static const _pageSize = 20;

  final HttpClient _httpClient;

  CineClubesRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<CineClubePage>> getCineClubes(
    CineClubeFilter filter,
    int page,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/cineclubes',
      queryParams: {
        'q': ?filter.query?.trim().nullIfEmpty,
        if (filter.open) 'open': true,
        if (filter.includeFinished) 'includeFinished': true,
        if (filter.mine) 'mine': true,
        'participant': ?filter.participant,
        'page': page,
        'limit': _pageSize,
      },
    ),
    RemoteCineClubes.page,
  );

  @override
  Future<Result<CineClube>> getCineClube(String slug) async => _map(
    await _httpClient.get<Map<String, dynamic>>(_path(slug)),
    RemoteCineClubes.cineclube,
  );

  @override
  Future<Result<CineClubeSlug>> checkSlug(String slug) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/cineclubes/slug-available',
      queryParams: {'slug': slug},
    ),
    RemoteCineClubes.slug,
  );

  @override
  Future<Result<CineClube>> create(CineClubeForm form) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/cineclubes',
      body: RemoteCineClubes.form(form),
    ),
    RemoteCineClubes.cineclube,
  );

  @override
  Future<Result<CineClube>> update(String slug, CineClubeForm form) async =>
      _map(
        await _httpClient.put<Map<String, dynamic>>(
          _path(slug),
          body: RemoteCineClubes.form(form),
        ),
        RemoteCineClubes.cineclube,
      );

  @override
  Future<Result<CineClube>> cancel(String slug) async => _map(
    await _httpClient.post<Map<String, dynamic>>('${_path(slug)}/cancel'),
    RemoteCineClubes.cineclube,
  );

  @override
  Future<Result<CineClube>> join(String slug, String? password) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '${_path(slug)}/participation',
      body: {'password': ?password},
    ),
    RemoteCineClubes.cineclube,
  );

  @override
  Future<Result<void>> leave(String slug) async => switch (await _httpClient
      .delete<dynamic>('${_path(slug)}/participation')) {
    Success() => const Success(null),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<CineClubeLogPage>> getProgress(
    String slug,
    int? sessionId,
    int page,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '${_path(slug)}/progress',
      queryParams: {'session': ?sessionId, 'page': page, 'limit': _pageSize},
    ),
    RemoteCineClubes.logs,
  );

  @override
  Future<Result<ParticipantPage>> getParticipants(
    String slug,
    int? sessionId,
    SessionProgress? progress,
    int page,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '${_path(slug)}/participants',
      queryParams: {
        'session': ?sessionId,
        'status': ?progress?.wireValue,
        'page': page,
        'limit': _pageSize,
      },
    ),
    RemoteCineClubes.participants,
  );

  String _path(String slug) => '$_base/cineclubes/${Uri.encodeComponent(slug)}';

  Result<T> _map<T>(
    Result<Map<String, dynamic>> result,
    T Function(Map<String, dynamic>) fromJson,
  ) => switch (result) {
    Success(:final data) => Success(fromJson(data)),
    Failure(:final error) => Failure(error),
  };
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
