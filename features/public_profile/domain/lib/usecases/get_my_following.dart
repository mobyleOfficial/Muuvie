import 'package:core/core.dart';
import 'package:public_profile_domain/models/following_user.dart';
import 'package:public_profile_domain/repositories/public_profile_repository.dart';

class GetMyFollowing extends UseCase<void, Result<List<FollowingUser>>> {
  final PublicProfileRepository _repository;

  GetMyFollowing(this._repository);

  @override
  Future<Result<List<FollowingUser>>> call([void params]) async =>
      _repository.getMyFollowing();
}
