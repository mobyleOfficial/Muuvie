import 'package:core/core.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class SortShelfParams {
  final int shelfId;
  final ShelfSort sortMode;

  /// Applies the order once and keeps it as the manual order.
  final bool applyOnce;

  const SortShelfParams({
    required this.shelfId,
    required this.sortMode,
    this.applyOnce = false,
  });
}

class SortShelf extends UseCase<SortShelfParams, Result<void>> {
  final ShelvesRepository _repository;

  SortShelf(this._repository);

  @override
  Future<Result<void>> call([SortShelfParams? params]) => _repository.sortShelf(
    shelfId: params!.shelfId,
    sortMode: params.sortMode,
    applyOnce: params.applyOnce,
  );
}
