/// A profile in the discovery hub of the Catálogo (F5.6).
class ProfileCard {
  final String id;
  final String username;
  final String? handle;
  final String? displayName;
  final String? avatarUrl;
  final String? accentColor;
  final String? bio;
  final bool featured;
  final int watched;
  final bool isFollowing;

  const ProfileCard({
    required this.id,
    required this.username,
    this.handle,
    this.displayName,
    this.avatarUrl,
    this.accentColor,
    this.bio,
    this.featured = false,
    this.watched = 0,
    this.isFollowing = false,
  });

  String get name =>
      (displayName?.isNotEmpty ?? false) ? displayName! : username;
}
