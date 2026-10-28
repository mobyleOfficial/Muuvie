import 'package:core/core.dart';
import 'package:shelves_domain/models/shelf.dart';

/// A shelf as served by `/api/v1/shelves`.
class RemoteShelf {
  final int id;
  final String ownerId;
  final String name;
  final String? description;
  final String? color;
  final String visibility;
  final String? systemType;
  final String sortMode;
  final bool pinned;
  final int totalMovies;
  final int totalWatched;
  final List<String> posterPaths;
  final bool self;

  /// `{id, username, handle, displayName, avatarUrl, accentColor}` (B14.4).
  final Map<String, dynamic>? owner;
  final bool saved;
  final int saves;

  const RemoteShelf({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.color,
    required this.visibility,
    this.systemType,
    required this.sortMode,
    required this.pinned,
    required this.totalMovies,
    required this.totalWatched,
    required this.posterPaths,
    required this.self,
    this.owner,
    this.saved = false,
    this.saves = 0,
  });

  factory RemoteShelf.fromJson(Map<String, dynamic> json) => RemoteShelf(
    id: (json['id'] as num).toInt(),
    ownerId: json['ownerId'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    color: json['color'] as String?,
    visibility: json['visibility'] as String? ?? 'public',
    systemType: json['systemType'] as String?,
    sortMode: json['sortMode'] as String? ?? 'manual',
    pinned: json['pinned'] as bool? ?? false,
    totalMovies: (json['totalMovies'] as num?)?.toInt() ?? 0,
    totalWatched: (json['totalWatched'] as num?)?.toInt() ?? 0,
    posterPaths:
        (json['posterPaths'] as List<dynamic>?)?.cast<String>() ?? const [],
    self: json['self'] as bool? ?? false,
    owner: json['owner'] as Map<String, dynamic>?,
    saved: json['saved'] as bool? ?? false,
    saves: (json['saves'] as num?)?.toInt() ?? 0,
  );

  Shelf toDomain() => Shelf(
    id: id,
    ownerId: ownerId,
    name: name,
    description: description,
    color: color,
    visibility:
        ContentVisibility.fromWireValue(visibility) ??
        ContentVisibility.defaultValue,
    systemType: SystemShelfType.fromWireValue(systemType),
    sortMode: ShelfSort.fromWireValue(sortMode) ?? ShelfSort.defaultValue,
    pinned: pinned,
    totalMovies: totalMovies,
    totalWatched: totalWatched,
    posterPaths: posterPaths,
    isSelf: self,
    ownerName:
        owner?['displayName'] as String? ?? owner?['username'] as String?,
    ownerAvatarUrl: owner?['avatarUrl'] as String?,
    ownerAccentColor: owner?['accentColor'] as String?,
    isSaved: saved,
    saves: saves,
  );
}
