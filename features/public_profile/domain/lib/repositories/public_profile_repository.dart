import 'package:core/core.dart';
import 'package:public_profile_domain/models/following_user.dart';
import 'package:public_profile_domain/models/public_profile.dart';

abstract interface class PublicProfileRepository {
  Future<Result<PublicProfile>> getPublicProfile({required String userId});
  Future<Result<void>> followUser({required String userId});
  Future<Result<void>> unfollowUser({required String userId});
  Future<Result<List<FollowingUser>>> getMyFollowing();
}
