import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';

class GetLocadora extends UseCase<int, Result<Locadora>> {
  final LocadorasRepository _repository;

  GetLocadora(this._repository);

  @override
  Future<Result<Locadora>> call([int? locadoraId]) =>
      _repository.getLocadora(locadoraId!);
}
