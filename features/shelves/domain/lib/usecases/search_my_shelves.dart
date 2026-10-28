import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class SearchMyShelvesParams {
  final String query;
  final int page;

  const SearchMyShelvesParams({required this.query, this.page = 1});
}

/// Searches the current user's shelves by name. A blank query lists them all.
class SearchMyShelves
    extends UseCase<SearchMyShelvesParams, Result<Paged<Shelf>>> {
  final ShelvesRepository _repository;

  SearchMyShelves(this._repository);

  @override
  Future<Result<Paged<Shelf>>> call([SearchMyShelvesParams? params]) =>
      _repository.searchShelves(query: params!.query.trim(), page: params.page);
}
