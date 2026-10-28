import 'package:core/core.dart';
import 'package:shelves_domain/models/shelf.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class GetShelf extends UseCase<int, Result<Shelf>> {
  final ShelvesRepository _repository;

  GetShelf(this._repository);

  @override
  Future<Result<Shelf>> call([int? shelfId]) => _repository.getShelf(shelfId!);
}
