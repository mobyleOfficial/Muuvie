import 'package:core/core.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';
import 'package:shelves_domain/usecases/set_locadora_shelves.dart';

/// Saves the order of the shelves inside a locadora.
class ReorderLocadoraShelves
    extends UseCase<LocadoraShelvesParams, Result<void>> {
  final LocadorasRepository _repository;

  ReorderLocadoraShelves(this._repository);

  @override
  Future<Result<void>> call([LocadoraShelvesParams? params]) async {
    final value = params!;
    if (value.shelfIds.isEmpty) return const Success(null);
    return _repository.reorderLocadoraShelves(
      locadoraId: value.locadoraId,
      shelfIds: value.shelfIds,
    );
  }
}
