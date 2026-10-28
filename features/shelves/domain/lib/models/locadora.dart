import 'package:core/core.dart';

/// A locadora groups shelves, like the aisles of a video store.
///
/// The counters only cover the shelves the caller can see.
class Locadora {
  final int id;
  final String ownerId;
  final String ownerUsername;
  final String? ownerAvatarUrl;
  final String name;
  final String? description;
  final ContentVisibility visibility;
  final bool hideShelvesInProfile;
  final bool hideShelvesInFilters;
  final bool pinned;
  final int totalShelves;

  /// Distinct movies across the shelves, and how many of them the owner watched.
  final int totalMovies;
  final int totalWatched;
  final List<String> posterPaths;

  /// True when the locadora belongs to the current user.
  final bool isSelf;

  const Locadora({
    required this.id,
    required this.ownerId,
    required this.ownerUsername,
    this.ownerAvatarUrl,
    required this.name,
    this.description,
    required this.visibility,
    required this.hideShelvesInProfile,
    required this.hideShelvesInFilters,
    required this.pinned,
    required this.totalShelves,
    required this.totalMovies,
    required this.totalWatched,
    required this.posterPaths,
    required this.isSelf,
  });
}
