import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with [status] and [body], as the server's error envelope.
class _ErrorAdapter implements HttpClientAdapter {
  final int status;
  final String body;
  final String contentType;

  _ErrorAdapter(this.status, this.body, this.contentType);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [contentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  HttpClient clientAnswering(
    int status,
    String body, {
    String contentType = Headers.jsonContentType,
  }) => DioHttpClient(
    Dio()..httpClientAdapter = _ErrorAdapter(status, body, contentType),
  );

  test('a failure carries the error key of the envelope', () async {
    final result = await clientAnswering(
      400,
      '{"error":"ambiguous_file","message":"rename it"}',
    ).post<Map<String, dynamic>>('/api/v1/imports');

    expect(result, isA<Failure<Map<String, dynamic>>>());
    final failure = result as Failure<Map<String, dynamic>>;
    expect(failure.error, AppError.badRequest);
    expect(failure.code, 'ambiguous_file');
  });

  test('413 and a body without an envelope', () async {
    final result =
        await clientAnswering(
              413,
              'too big',
              contentType: Headers.textPlainContentType,
            ).post<Object>('/api/v1/imports')
            as Failure<Object>;

    expect(result.error, AppError.payloadTooLarge);
    expect(result.code, isNull);
  });
}
