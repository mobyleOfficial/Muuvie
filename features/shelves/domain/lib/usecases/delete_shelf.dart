import 'package:core/core.dart';
import 'package:shelves_domain/models/shelf.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

/// Deletes a shelf; its movies stay in the history. System shelves cannot be deleted.
class DeleteShelf extends UseCase<Shelf, Result<void>> {
  final ShelvesRepository _repository;

  DeleteShelf(this._repository);

  @override
  Future<Result<void>> call([Shelf? shelf]) async {
    if (shelf!.isSystem) return const Failure(AppError.forbidden);
    return _repository.deleteShelf(shelf.id);
  }
}
