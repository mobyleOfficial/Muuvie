sealed class NewsListState {
  const NewsListState();
}

class NewsListLoading extends NewsListState {
  const NewsListLoading();
}

/// The filters and marks around the paged list of articles.
class NewsListSuccess extends NewsListState {
  /// Outlets of the source filter; empty hides it.
  final List<String> sources;

  /// Null shows every source.
  final String? selectedSource;

  /// Articles already opened on this device.
  final Set<int> readIds;

  const NewsListSuccess({
    this.sources = const [],
    this.selectedSource,
    this.readIds = const {},
  });

  NewsListSuccess copyWith({
    List<String>? sources,
    String? Function()? selectedSource,
    Set<int>? readIds,
  }) => NewsListSuccess(
    sources: sources ?? this.sources,
    selectedSource: selectedSource != null
        ? selectedSource()
        : this.selectedSource,
    readIds: readIds ?? this.readIds,
  );
}

class NewsListError extends NewsListState {
  final String message;

  const NewsListError(this.message);
}
