import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class GetUserShelvesParams {
  /// Owner's user id, or `me` for the current user.
  final String userId;
  final int page;

  /// The profile Estantes tab: leaves out the shelves a locadora hides there.
  final bool profile;

  const GetUserShelvesParams({
    this.userId = 'me',
    this.page = 1,
    this.profile = false,
  });
}

/// Shelves the caller can see, pinned first, then in profile order.
class GetUserShelves
    extends UseCase<GetUserShelvesParams, Result<Paged<Shelf>>> {
  final ShelvesRepository _repository;

  GetUserShelves(this._repository);

  @override
  Future<Result<Paged<Shelf>>> call([GetUserShelvesParams? params]) {
    final value = params ?? const GetUserShelvesParams();
    return _repository.getUserShelves(
      userId: value.userId,
      page: value.page,
      profile: value.profile,
    );
  }
}
