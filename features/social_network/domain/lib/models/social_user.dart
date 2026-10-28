/// A user as the feed, the follow lists and the Sussurros show them.
class SocialUser {
  final String id;
  final String username;
  final String? handle;
  final String? displayName;
  final String? avatarUrl;
  final String? accentColor;

  const SocialUser({
    required this.id,
    required this.username,
    this.handle,
    this.displayName,
    this.avatarUrl,
    this.accentColor,
  });

  /// The display name, else the username.
  String get name {
    final display = displayName?.trim();
    return display == null || display.isEmpty ? username : display;
  }
}
