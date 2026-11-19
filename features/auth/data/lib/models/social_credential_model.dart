/// What a native Apple or Google sheet returned: the ID token the backend
/// verifies, the raw nonce (Apple carries its SHA-256 in the token) and the
/// name the provider gave, to suggest as nickname.
class SocialCredentialModel {
  final String provider;
  final String idToken;
  final String? nonce;
  final String? displayName;

  const SocialCredentialModel({
    required this.provider,
    required this.idToken,
    this.nonce,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'idToken': idToken,
    if (nonce != null) 'nonce': nonce,
  };
}
