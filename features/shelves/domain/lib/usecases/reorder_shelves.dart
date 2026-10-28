import 'package:core/core.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class ReorderShelvesParams {
  final List<int> shelfIds;

  /// When set, replaces the pinned shelves.
  final List<int>? pinnedIds;

  const ReorderShelvesParams({required this.shelfIds, this.pinnedIds});
}

/// Orders the current user's shelves on the profile.
class ReorderShelves extends UseCase<ReorderShelvesParams, Result<void>> {
  final ShelvesRepository _repository;

  ReorderShelves(this._repository);

  @override
  Future<Result<void>> call([ReorderShelvesParams? params]) => _repository
      .reorderShelves(shelfIds: params!.shelfIds, pinnedIds: params.pinnedIds);
}
