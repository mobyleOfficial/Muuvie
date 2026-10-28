import 'package:core/core.dart';
import 'package:social_network_domain/models/activity_blocks.dart';
import 'package:social_network_domain/models/activity_type.dart';
import 'package:social_network_domain/models/social_user.dart';

/// One item of the feed (F6.1) as the current user sees it. The blocks are
/// a snapshot taken when it was published; which ones are set depends on
/// the [type] (a session has [movie] and [log], and [rating] when the movie
/// was rated in the same sitting).
class Activity {
  final int id;
  final ActivityType type;
  final SocialUser actor;
  final ContentVisibility visibility;
  final ActivityMovie? movie;
  final ActivityLog? log;
  final ActivityRating? rating;
  final ActivityShelf? shelf;
  final ActivityLocadora? locadora;
  final ActivityImport? import;

  /// Maratona activities (phase 7): the maratona, and the challenge or the
  /// level reached when there is one.
  final ActivityMaratona? maratona;
  final ActivityChallenge? challenge;
  final ActivityLevel? level;

  /// CineClube activities (phase 8).
  final ActivityCineClube? cineclube;

  /// Bichinho activities (phase 10).
  final ActivityBichinho? bichinho;

  /// How many "amei" it has, and whether the current user gave one.
  final int loves;
  final bool loved;

  /// The current user published it.
  final bool self;

  /// The actor and the current user follow each other.
  final bool mutual;

  /// Hidden from everyone else's feed by its author.
  final bool hidden;
  final DateTime createdAt;

  const Activity({
    required this.id,
    required this.type,
    required this.actor,
    required this.visibility,
    this.movie,
    this.log,
    this.rating,
    this.shelf,
    this.locadora,
    this.import,
    this.maratona,
    this.challenge,
    this.level,
    this.cineclube,
    this.bichinho,
    this.loves = 0,
    this.loved = false,
    this.self = false,
    this.mutual = false,
    this.hidden = false,
    required this.createdAt,
  });

  Activity copyWith({int? loves, bool? loved, bool? hidden}) => Activity(
    id: id,
    type: type,
    actor: actor,
    visibility: visibility,
    movie: movie,
    log: log,
    rating: rating,
    shelf: shelf,
    locadora: locadora,
    import: import,
    maratona: maratona,
    challenge: challenge,
    level: level,
    cineclube: cineclube,
    bichinho: bichinho,
    loves: loves ?? this.loves,
    loved: loved ?? this.loved,
    self: self,
    mutual: mutual,
    hidden: hidden ?? this.hidden,
    createdAt: createdAt,
  );
}

/// A page of the feed. [nextCursor] is null on the last page.
class ActivityPage {
  final List<Activity> activities;
  final String? nextCursor;

  const ActivityPage({required this.activities, this.nextCursor});
}

/// The "amei" of an activity after loving or unloving it.
class ActivityLoves {
  final int loves;
  final bool loved;

  const ActivityLoves({required this.loves, required this.loved});
}
