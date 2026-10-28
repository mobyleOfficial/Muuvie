class AuthTokenModel {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  const AuthTokenModel({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) => AuthTokenModel(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String?,
    expiresAt: DateTime.parse(json['expires_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_at': expiresAt.toIso8601String(),
  };
}
