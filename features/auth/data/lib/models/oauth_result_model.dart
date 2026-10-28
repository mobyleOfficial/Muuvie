class OAuthResultModel {
  final String provider;
  final String providerToken;

  const OAuthResultModel({required this.provider, required this.providerToken});

  factory OAuthResultModel.fromJson(Map<String, dynamic> json) =>
      OAuthResultModel(
        provider: json['provider'] as String,
        providerToken: json['provider_token'] as String,
      );

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'provider_token': providerToken,
  };
}
