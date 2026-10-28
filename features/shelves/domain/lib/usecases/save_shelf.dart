import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class SaveShelfParams {
  /// Null creates a new shelf.
  final int? shelfId;
  final ShelfDraft draft;

  const SaveShelfParams({this.shelfId, required this.draft});
}

/// Creates or edits a shelf. The backend keeps the name of system shelves.
class SaveShelf extends UseCase<SaveShelfParams, Result<Shelf>> {
  static const maxNameLength = 150;
  static const maxDescriptionLength = 150;

  final ShelvesRepository _repository;

  SaveShelf(this._repository);

  @override
  Future<Result<Shelf>> call([SaveShelfParams? params]) async {
    final value = params!;
    final name = value.draft.name.trim();
    final description = value.draft.description?.trim();
    if (name.isEmpty ||
        name.length > maxNameLength ||
        (description?.length ?? 0) > maxDescriptionLength) {
      return const Failure(AppError.badRequest);
    }
    final draft = ShelfDraft(
      name: name,
      description: description?.isEmpty ?? true ? null : description,
      color: value.draft.color,
      visibility: value.draft.visibility,
    );
    final shelfId = value.shelfId;
    return shelfId == null
        ? _repository.createShelf(draft)
        : _repository.updateShelf(shelfId, draft);
  }
}
