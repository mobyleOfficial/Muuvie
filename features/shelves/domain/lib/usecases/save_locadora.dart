import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';

class SaveLocadoraParams {
  /// Null creates a new locadora.
  final int? locadoraId;
  final LocadoraDraft draft;

  const SaveLocadoraParams({this.locadoraId, required this.draft});
}

/// Creates or edits a locadora.
class SaveLocadora extends UseCase<SaveLocadoraParams, Result<Locadora>> {
  static const maxNameLength = 150;
  static const maxDescriptionLength = 150;

  final LocadorasRepository _repository;

  SaveLocadora(this._repository);

  @override
  Future<Result<Locadora>> call([SaveLocadoraParams? params]) async {
    final value = params!;
    final name = value.draft.name.trim();
    final description = value.draft.description?.trim();
    if (name.isEmpty ||
        name.length > maxNameLength ||
        (description?.length ?? 0) > maxDescriptionLength) {
      return const Failure(AppError.badRequest);
    }
    final draft = LocadoraDraft(
      name: name,
      description: description?.isEmpty ?? true ? null : description,
      visibility: value.draft.visibility,
      hideShelvesInProfile: value.draft.hideShelvesInProfile,
      hideShelvesInFilters: value.draft.hideShelvesInFilters,
    );
    final locadoraId = value.locadoraId;
    return locadoraId == null
        ? _repository.createLocadora(draft)
        : _repository.updateLocadora(locadoraId, draft);
  }
}
