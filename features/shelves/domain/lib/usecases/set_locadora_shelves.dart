import 'package:core/core.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';

class LocadoraShelvesParams {
  final int locadoraId;
  final List<int> shelfIds;

  const LocadoraShelvesParams({
    required this.locadoraId,
    required this.shelfIds,
  });
}

/// Replaces the shelves of a locadora. Only shelves of the current user can go in.
class SetLocadoraShelves extends UseCase<LocadoraShelvesParams, Result<void>> {
  final LocadorasRepository _repository;

  SetLocadoraShelves(this._repository);

  @override
  Future<Result<void>> call([LocadoraShelvesParams? params]) =>
      _repository.setLocadoraShelves(
        locadoraId: params!.locadoraId,
        shelfIds: params.shelfIds.toSet().toList(),
      );
}
