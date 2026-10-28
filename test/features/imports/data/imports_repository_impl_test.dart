import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imports/imports.dart';

class _Call {
  final String method;
  final String path;
  final Map<String, dynamic>? query;
  final Object? body;

  const _Call(this.method, this.path, this.query, this.body);
}

/// Records every request and answers with [response].
class _FakeHttpClient implements HttpClient {
  final calls = <_Call>[];
  Result<dynamic> response = const Success(null);

  Future<Result<T>> _record<T>(
    String method,
    String path,
    Map<String, dynamic>? query,
    Object? body,
  ) async {
    calls.add(_Call(method, path, query, body));
    return switch (response) {
      Success(:final data) => Success(data as T),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<T>> get<T>(String path, {Map<String, dynamic>? queryParams}) =>
      _record('GET', path, queryParams, null);

  @override
  Future<Result<T>> post<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _record('POST', path, queryParams, body);

  @override
  Future<Result<T>> put<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _record('PUT', path, queryParams, body);

  @override
  Future<Result<T>> patch<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _record('PATCH', path, queryParams, body);

  @override
  Future<Result<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParams,
  }) => _record('DELETE', path, queryParams, null);
}

class _FakeWebSocketClient implements WebSocketClient {
  final controller = StreamController<WsMessage>.broadcast();

  @override
  Stream<WsMessage> get messages => controller.stream;

  @override
  Future<void> dispose() => controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _jobJson = {
  'id': 7,
  'source': 'filmow',
  'status': 'preview',
  'inputRef': 'ana',
  'processed': 0,
  'total': 0,
  'preview': {
    'watched': 412,
    'watchlist': 87,
    'favorites': 3,
    'logs': 120,
    'lists': [
      {'externalId': 'L1', 'title': 'Noir', 'movieCount': 12, 'coverUrl': null},
    ],
  },
  'counts': null,
  'error': null,
  'createdAt': '2026-10-26T12:00:00Z',
  'updatedAt': '2026-10-26T12:00:00Z',
  'finishedAt': null,
};

void main() {
  late _FakeHttpClient http;
  late _FakeWebSocketClient socket;
  late ImportsRepositoryImpl repository;

  setUp(() {
    http = _FakeHttpClient();
    socket = _FakeWebSocketClient();
    repository = ImportsRepositoryImpl(
      ImportsRemoteDataSourceImpl(http),
      socket,
    );
  });
  tearDown(() => socket.dispose());

  test('start posts the source, username and cookies to v1', () async {
    http.response = const Success(_jobJson);

    final result = await repository.startImport(
      source: ImportSource.filmow,
      username: 'ana',
      cookies: 'session=1',
    );

    expect(http.calls.single.method, 'POST');
    expect(http.calls.single.path, '/api/v1/imports');
    expect(http.calls.single.body, {
      'source': 'filmow',
      'username': 'ana',
      'cookies': 'session=1',
    });
    final job = (result as Success<ImportJob>).data;
    expect(job.status, ImportStatus.preview);
    expect(job.preview?.watched, 412);
    expect(job.preview?.lists.single.externalId, 'L1');
  });

  test('confirm sends the chosen lists and the visibility', () async {
    http.response = const Success(_jobJson);

    await repository.confirmImport(
      7,
      listsToImport: ['L1'],
      visibility: ContentVisibility.secret,
    );

    expect(http.calls.single.path, '/api/v1/imports/7/confirm');
    expect(http.calls.single.body, {
      'listsToImport': ['L1'],
      'defaultVisibility': 'secret',
    });
  });

  test('confirming every list omits listsToImport', () async {
    http.response = const Success(_jobJson);

    await repository.confirmImport(7, visibility: ContentVisibility.public);

    expect(http.calls.single.body, {'defaultVisibility': 'public'});
  });

  test('resolving sends the candidate or skip', () async {
    http.response = const Success({
      'id': 3,
      'jobId': 7,
      'movie': {'externalId': 'f-4', 'title': 'Filme Raro', 'year': 1971},
      'candidates': [
        {'tmdbId': 300, 'title': 'Rare Movie', 'year': 1972, 'score': 0.8},
      ],
      'resolution': 'matched',
      'movieId': 70,
    });

    final matched = await repository.matchUnmatched(
      7,
      3,
      const MovieCandidate(tmdbId: 300, title: 'Rare Movie'),
    );
    await repository.skipUnmatched(7, 3);

    expect(http.calls[0].path, '/api/v1/imports/7/unmatched/3');
    expect(http.calls[0].body, {'tmdbId': 300, 'title': 'Rare Movie'});
    expect(http.calls[1].body, {'skip': true});
    final item = (matched as Success<UnmatchedItem>).data;
    expect(item.resolution, UnmatchedResolution.matched);
    expect(item.candidates.single.year, 1972);
  });

  test('a running import from the same source maps to a conflict', () async {
    http.response = const Failure(AppError.conflict);

    final result = await repository.startImport(
      source: ImportSource.filmow,
      username: 'ana',
      cookies: '',
    );

    expect((result as Failure).error, AppError.conflict);
  });

  test('progress keeps only import messages with a job and a status', () async {
    final events = <ImportProgress>[];
    final subscription = repository.watchProgress().listen(events.add);

    socket.controller
      ..add(const WsMessage(type: WsMessageType.unknown))
      ..add(
        const WsMessage(
          type: WsMessageType.importProgress,
          data: {'jobId': '7', 'status': 'done'},
        ),
      )
      ..add(
        const WsMessage(
          type: WsMessageType.importProgress,
          data: {'jobId': 'x'},
        ),
      );
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(events.single.jobId, 7);
    expect(events.single.status, ImportStatus.done);
  });
}
