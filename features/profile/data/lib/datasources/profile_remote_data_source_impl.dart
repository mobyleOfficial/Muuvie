import 'package:core/core.dart';
import 'package:profile_data/datasources/profile_remote_data_source.dart';
import 'package:profile_data/models/user_profile_response_model.dart';
import 'package:profile_domain/models/user_profile.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final HttpClient _httpClient;

  ProfileRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<UserProfile>> getUserProfile() async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/api/v1/profile',
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        UserProfileResponseModel.fromJson(data).toDomain(),
      ),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> updateUserProfile({required UserProfile profile}) async {
    final result = await _httpClient.put<dynamic>(
      '/api/v1/profile',
      body: {
        'photoUrl': profile.photoUrl,
        'username': profile.username,
        'bio': profile.bio,
      },
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }
}
