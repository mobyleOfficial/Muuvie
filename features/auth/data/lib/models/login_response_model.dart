import 'package:auth_data/models/auth_token_model.dart';

class LoginResponseModel {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String? refreshToken;
  final LoginProfileModel profile;

  const LoginResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.refreshToken,
    required this.profile,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        accessToken: json['accessToken'] as String,
        tokenType: json['tokenType'] as String,
        expiresIn: json['expiresIn'] as int,
        refreshToken: json['refreshToken'] as String?,
        profile: LoginProfileModel.fromJson(
          json['profile'] as Map<String, dynamic>,
        ),
      );

  AuthTokenModel toAuthTokenModel() => AuthTokenModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      );
}

class LoginProfileModel {
  final String photoUrl;
  final String username;
  final String bio;

  const LoginProfileModel({
    required this.photoUrl,
    required this.username,
    required this.bio,
  });

  factory LoginProfileModel.fromJson(Map<String, dynamic> json) =>
      LoginProfileModel(
        photoUrl: json['photoUrl'] as String,
        username: json['username'] as String,
        bio: json['bio'] as String,
      );
}
