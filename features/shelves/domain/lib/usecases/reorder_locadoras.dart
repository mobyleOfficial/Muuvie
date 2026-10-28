import 'package:core/core.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';

class ReorderLocadorasParams {
  final List<int> locadoraIds;

  /// When set, replaces the pinned locadoras.
  final List<int>? pinnedIds;

  const ReorderLocadorasParams({required this.locadoraIds, this.pinnedIds});
}

/// Orders the locadoras of the current user on the profile.
class ReorderLocadoras extends UseCase<ReorderLocadorasParams, Result<void>> {
  final LocadorasRepository _repository;

  ReorderLocadoras(this._repository);

  @override
  Future<Result<void>> call([ReorderLocadorasParams? params]) =>
      _repository.reorderLocadoras(
        locadoraIds: params!.locadoraIds,
        pinnedIds: params.pinnedIds,
      );
}
