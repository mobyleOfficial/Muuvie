/// Editable fields of the own profile (F5.3).
class ProfileDraft {
  final String? displayName;

  /// Without the @. Null keeps the current handle.
  final String? handle;
  final String? pronouns;
  final String? bio;
  final List<String> links;
  final String? accentColor;
  final String? avatarUrl;
  final String? bannerUrl;

  const ProfileDraft({
    this.displayName,
    this.handle,
    this.pronouns,
    this.bio,
    this.links = const [],
    this.accentColor,
    this.avatarUrl,
    this.bannerUrl,
  });
}
