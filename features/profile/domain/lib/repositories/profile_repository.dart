import 'package:core/core.dart';
import 'package:profile_domain/models/user_profile.dart';

abstract interface class ProfileRepository {
  Future<Result<void>> updateUserProfile({required UserProfile profile});
  Stream<UserProfile> watchProfile();
  Future<void> fetchProfile();
}
