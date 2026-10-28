import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

/// The shelves of other people the current user saved, the latest first (F14.5).
class GetSavedShelves extends UseCase<int, Result<Paged<Shelf>>> {
  final ShelvesRepository _repository;

  GetSavedShelves(this._repository);

  @override
  Future<Result<Paged<Shelf>>> call([int? page]) =>
      _repository.getSavedShelves(page: page ?? 1);
}
