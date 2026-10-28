import 'package:core/core.dart';
import 'package:profile_domain/models/user_profile.dart';

abstract interface class ProfileRemoteDataSource {
  Future<Result<void>> updateUserProfile({required UserProfile profile});
  Future<Result<UserProfile>> getUserProfile();
}
