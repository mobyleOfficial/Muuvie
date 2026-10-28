import 'package:core/core.dart';
import 'package:shelves_domain/models/shelf.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class SetShelfSavedParams {
  final Shelf shelf;
  final bool saved;

  const SetShelfSavedParams({required this.shelf, required this.saved});
}

/// Saves or unsaves a shelf of someone else (F14.5). My own shelves and
/// "Já assisti" or "Quero ver" cannot be saved.
class SetShelfSaved extends UseCase<SetShelfSavedParams, Result<void>> {
  final ShelvesRepository _repository;

  SetShelfSaved(this._repository);

  @override
  Future<Result<void>> call([SetShelfSavedParams? params]) async {
    final value = params!;
    if (!value.shelf.canBeSaved) return const Failure(AppError.forbidden);
    return _repository.setShelfSaved(
      shelfId: value.shelf.id,
      saved: value.saved,
    );
  }
}
