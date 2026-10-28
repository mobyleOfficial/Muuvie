import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class DiscoverParams {
  /// Filters by name; null or empty lists everything.
  final String? query;
  final int page;

  const DiscoverParams({this.query, this.page = 1});
}

/// Public shelves of other users, the most popular first (F5.6, B14.4).
class DiscoverShelves extends UseCase<DiscoverParams, Result<Paged<Shelf>>> {
  final ShelvesRepository _repository;

  DiscoverShelves(this._repository);

  @override
  Future<Result<Paged<Shelf>>> call([DiscoverParams? params]) {
    final value = params ?? const DiscoverParams();
    return _repository.discoverShelves(
      query: value.query?.trim(),
      page: value.page,
    );
  }
}

/// Public locadoras of other users, curated first, then the most active (F5.6).
class DiscoverLocadoras
    extends UseCase<DiscoverParams, Result<Paged<Locadora>>> {
  final LocadorasRepository _repository;

  DiscoverLocadoras(this._repository);

  @override
  Future<Result<Paged<Locadora>>> call([DiscoverParams? params]) {
    final value = params ?? const DiscoverParams();
    return _repository.discoverLocadoras(
      query: value.query?.trim(),
      page: value.page,
    );
  }
}
