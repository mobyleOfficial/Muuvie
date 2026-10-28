import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';

class GetLocadoraShelvesParams {
  final int locadoraId;
  final int page;

  const GetLocadoraShelvesParams({required this.locadoraId, this.page = 1});
}

/// Shelves of a locadora in its order, each with its first movies.
class GetLocadoraShelves
    extends UseCase<GetLocadoraShelvesParams, Result<Paged<LocadoraShelf>>> {
  final LocadorasRepository _repository;

  GetLocadoraShelves(this._repository);

  @override
  Future<Result<Paged<LocadoraShelf>>> call([
    GetLocadoraShelvesParams? params,
  ]) => _repository.getLocadoraShelves(
    locadoraId: params!.locadoraId,
    page: params.page,
  );
}
