import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/locadoras_repository.dart';

class GetUserLocadorasParams {
  /// The owner, or `me` for the current user.
  final String userId;
  final int page;

  const GetUserLocadorasParams({this.userId = 'me', this.page = 1});
}

/// Locadoras the caller can see, pinned first, then in profile order.
class GetUserLocadoras
    extends UseCase<GetUserLocadorasParams, Result<Paged<Locadora>>> {
  final LocadorasRepository _repository;

  GetUserLocadoras(this._repository);

  @override
  Future<Result<Paged<Locadora>>> call([GetUserLocadorasParams? params]) {
    final value = params ?? const GetUserLocadorasParams();
    return _repository.getUserLocadoras(userId: value.userId, page: value.page);
  }
}
