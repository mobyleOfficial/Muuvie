import 'package:core/core.dart';
import 'package:movies_data/models/local/local_recent_search.dart';

abstract interface class MoviesLocalDataSource {
  Result<void> addRecentSearch(String query);
  Stream<List<LocalRecentSearch>> watchRecentSearches();

  /// One search by id, or all of them when [id] is null.
  Result<void> removeRecentSearches({int? id});
}
