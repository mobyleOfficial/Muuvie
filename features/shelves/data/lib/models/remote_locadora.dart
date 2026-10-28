import 'package:core/core.dart';
import 'package:shelves_domain/models/locadora.dart';

/// A locadora as served by `/api/v1/locadoras`.
class RemoteLocadora {
  final int id;
  final String ownerId;
  final String ownerUsername;
  final String? ownerAvatarUrl;
  final String name;
  final String? description;
  final String visibility;
  final bool hideShelvesInProfile;
  final bool hideShelvesInFilters;
  final bool pinned;
  final int totalShelves;
  final int totalMovies;
  final int totalWatched;
  final List<String> posterPaths;
  final bool self;

  const RemoteLocadora({
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
    required this.self,
  });

  factory RemoteLocadora.fromJson(Map<String, dynamic> json) => RemoteLocadora(
    id: (json['id'] as num).toInt(),
    ownerId: json['ownerId'] as String,
    ownerUsername: json['ownerUsername'] as String? ?? '',
    ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    visibility: json['visibility'] as String? ?? 'public',
    hideShelvesInProfile: json['hideShelvesInProfile'] as bool? ?? false,
    hideShelvesInFilters: json['hideShelvesInFilters'] as bool? ?? false,
    pinned: json['pinned'] as bool? ?? false,
    totalShelves: (json['totalShelves'] as num?)?.toInt() ?? 0,
    totalMovies: (json['totalMovies'] as num?)?.toInt() ?? 0,
    totalWatched: (json['totalWatched'] as num?)?.toInt() ?? 0,
    posterPaths:
        (json['posterPaths'] as List<dynamic>?)?.cast<String>() ?? const [],
    self: json['self'] as bool? ?? false,
  );

  Locadora toDomain() => Locadora(
    id: id,
    ownerId: ownerId,
    ownerUsername: ownerUsername,
    ownerAvatarUrl: ownerAvatarUrl,
    name: name,
    description: description,
    visibility:
        ContentVisibility.fromWireValue(visibility) ??
        ContentVisibility.defaultValue,
    hideShelvesInProfile: hideShelvesInProfile,
    hideShelvesInFilters: hideShelvesInFilters,
    pinned: pinned,
    totalShelves: totalShelves,
    totalMovies: totalMovies,
    totalWatched: totalWatched,
    posterPaths: posterPaths,
    isSelf: self,
  );
}
