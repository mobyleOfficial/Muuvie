import 'package:core/core.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';

/// Deletes a locadora. Its shelves stay on the profile.
class DeleteLocadora extends UseCase<int, Result<void>> {
  final LocadorasRepository _repository;

  DeleteLocadora(this._repository);

  @override
  Future<Result<void>> call([int? locadoraId]) =>
      _repository.deleteLocadora(locadoraId!);
}
