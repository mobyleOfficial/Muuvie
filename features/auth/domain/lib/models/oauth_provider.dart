/// The accounts Muuvie signs in with. There is no e-mail and password login.
enum OAuthProvider {
  apple('apple'),
  google('google');

  /// The name the backend takes in `POST /api/v1/auth/social`.
  final String wire;

  const OAuthProvider(this.wire);
}
