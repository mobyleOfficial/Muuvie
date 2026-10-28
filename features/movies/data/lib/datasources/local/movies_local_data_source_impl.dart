import 'package:core/core.dart';
import 'package:movies_data/datasources/local/movies_local_data_source.dart';
import 'package:movies_data/models/local/local_recent_search.dart';
import 'package:movies_data/objectbox.g.dart';

class MoviesLocalDataSourceImpl implements MoviesLocalDataSource {
  final Box<LocalRecentSearch> _recentSearchBox;
  final LocalClient _localClient;

  static const _maxRecentSearches = 100;

  MoviesLocalDataSourceImpl(this._recentSearchBox, this._localClient);

  @override
  Result<void> addRecentSearch(String query) => _localClient.execute(() {
    final existing = _recentSearchBox
        .query(LocalRecentSearch_.query.equals(query))
        .build()
        .findFirst();

    final search = LocalRecentSearch(
      id: existing?.id ?? 0,
      query: query,
      searchedAt: DateTime.now(),
    );

    _recentSearchBox.put(search);

    final count = _recentSearchBox.count();
    if (count > _maxRecentSearches) {
      final oldest = _recentSearchBox
          .query()
          .order(LocalRecentSearch_.searchedAt)
          .build()
          .findFirst();
      if (oldest != null) {
        _recentSearchBox.remove(oldest.id);
      }
    }
  });

  @override
  Result<void> removeRecentSearches({int? id}) => _localClient.execute(() {
    if (id == null) {
      _recentSearchBox.removeAll();
    } else {
      _recentSearchBox.remove(id);
    }
  });

  @override
  Stream<List<LocalRecentSearch>> watchRecentSearches() => _localClient.watch(
    () => _recentSearchBox
        .query()
        .order(LocalRecentSearch_.searchedAt, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find()),
  );
}
