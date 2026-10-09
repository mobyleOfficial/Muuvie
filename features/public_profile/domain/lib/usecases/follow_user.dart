import 'package:core/core.dart';
import 'package:public_profile_domain/repositories/public_profile_repository.dart';

class FollowUser extends UseCase<String, Result<void>> {
  final PublicProfileRepository _repository;

  FollowUser(this._repository);

  @override
  Future<Result<void>> call([String? params]) async =>
      _repository.followUser(userId: params ?? '');
}
