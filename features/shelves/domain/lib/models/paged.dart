/// One page of a paginated list (the `Page` envelope of the v1 API).
class Paged<T> {
  final List<T> items;
  final int page;
  final int totalPages;
  final int totalResults;
  final bool hasNext;

  const Paged({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.hasNext,
  });
}
