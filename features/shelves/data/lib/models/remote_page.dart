import 'package:shelves_domain/models/paged.dart';

/// The `Page` envelope of the v1 API: `{ results, page, totalPages, totalResults, hasNext }`.
class RemotePage<T> {
  final List<T> results;
  final int page;
  final int totalPages;
  final int totalResults;
  final bool hasNext;

  const RemotePage({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.hasNext,
  });

  factory RemotePage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) => RemotePage(
    results: (json['results'] as List<dynamic>? ?? const [])
        .map((e) => fromItem(e as Map<String, dynamic>))
        .toList(),
    page: (json['page'] as num?)?.toInt() ?? 1,
    totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    totalResults: (json['totalResults'] as num?)?.toInt() ?? 0,
    hasNext: json['hasNext'] as bool? ?? false,
  );

  Paged<R> toDomain<R>(R Function(T) map) => Paged(
    items: results.map(map).toList(),
    page: page,
    totalPages: totalPages,
    totalResults: totalResults,
    hasNext: hasNext,
  );
}
