/// A profile of the v1 API (F5.1): the "vitrine" of the cinéfilo.
///
/// The relation flags are about the caller: [isFollowing] (caller → owner),
/// [followsMe] (owner → caller) and [mutual] (both).
class ProfileDetails {
  final String id;
  final String username;
  final String? handle;
  final String? displayName;
  final String? pronouns;
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;

  /// `#RRGGBB`, or null for the app's accent color.
  final String? accentColor;
  final List<String> links;
  final bool featured;
  final ProfileStats stats;
  final bool isFollowing;
  final bool followsMe;
  final bool mutual;

  /// True on the caller's own profile.
  final bool isSelf;

  /// A Filmow import is running (own profile only).
  final bool isScraping;

  const ProfileDetails({
    required this.id,
    required this.username,
    this.handle,
    this.displayName,
    this.pronouns,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    this.accentColor,
    this.links = const [],
    this.featured = false,
    required this.stats,
    this.isFollowing = false,
    this.followsMe = false,
    this.mutual = false,
    this.isSelf = false,
    this.isScraping = false,
  });

  /// The public name: the display name, or the username until one is set.
  String get name =>
      (displayName?.isNotEmpty ?? false) ? displayName! : username;

  ProfileDetails copyWith({
    bool? isFollowing,
    bool? followsMe,
    bool? mutual,
    bool? isScraping,
    ProfileStats? stats,
  }) => ProfileDetails(
    id: id,
    username: username,
    handle: handle,
    displayName: displayName,
    pronouns: pronouns,
    bio: bio,
    avatarUrl: avatarUrl,
    bannerUrl: bannerUrl,
    accentColor: accentColor,
    links: links,
    featured: featured,
    stats: stats ?? this.stats,
    isFollowing: isFollowing ?? this.isFollowing,
    followsMe: followsMe ?? this.followsMe,
    mutual: mutual ?? this.mutual,
    isSelf: isSelf,
    isScraping: isScraping ?? this.isScraping,
  );
}

/// Counters of the profile header. Only what the caller can see is counted.
/// Maratonas, CineClubes and participations arrive with phases 7 and 8.
class ProfileStats {
  final int shelves;
  final int locadoras;
  final int watchLogs;
  final int watched;
  final int maratonas;
  final int cineclubes;
  final int participations;
  final int followers;
  final int following;

  const ProfileStats({
    this.shelves = 0,
    this.locadoras = 0,
    this.watchLogs = 0,
    this.watched = 0,
    this.maratonas = 0,
    this.cineclubes = 0,
    this.participations = 0,
    this.followers = 0,
    this.following = 0,
  });

  ProfileStats copyWith({int? followers}) => ProfileStats(
    shelves: shelves,
    locadoras: locadoras,
    watchLogs: watchLogs,
    watched: watched,
    maratonas: maratonas,
    cineclubes: cineclubes,
    participations: participations,
    followers: followers ?? this.followers,
    following: following,
  );
}
