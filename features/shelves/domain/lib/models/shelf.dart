import 'package:core/core.dart';

/// A shelf. It only holds movies; the movie state lives with the user.
class Shelf {
  final int id;
  final String ownerId;
  final String name;
  final String? description;
  final String? color;
  final ContentVisibility visibility;

  /// Set for "Já assisti" and "Quero ver", which cannot be renamed or deleted.
  final SystemShelfType? systemType;
  final ShelfSort sortMode;
  final bool pinned;
  final int totalMovies;
  final int totalWatched;
  final List<String> posterPaths;

  /// True when the shelf belongs to the current user.
  final bool isSelf;

  /// The owner's name, avatar and accent color, when the API sends them (B14.4).
  final String? ownerName;
  final String? ownerAvatarUrl;
  final String? ownerAccentColor;

  /// True when the current user saved this shelf of someone else (B14.4).
  final bool isSaved;

  /// How many people saved the shelf.
  final int saves;

  const Shelf({
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
    required this.isSelf,
    this.ownerName,
    this.ownerAvatarUrl,
    this.ownerAccentColor,
    this.isSaved = false,
    this.saves = 0,
  });

  bool get isSystem => systemType != null;

  /// Only shelves of other people can be saved, and never "Já assisti" or "Quero ver".
  bool get canBeSaved => !isSelf && !isSystem;

  /// The same shelf with its saved state changed, and the counter with it.
  Shelf withSaved(bool saved) => saved == isSaved
      ? this
      : Shelf(
          id: id,
          ownerId: ownerId,
          name: name,
          description: description,
          color: color,
          visibility: visibility,
          systemType: systemType,
          sortMode: sortMode,
          pinned: pinned,
          totalMovies: totalMovies,
          totalWatched: totalWatched,
          posterPaths: posterPaths,
          isSelf: isSelf,
          ownerName: ownerName,
          ownerAvatarUrl: ownerAvatarUrl,
          ownerAccentColor: ownerAccentColor,
          isSaved: saved,
          saves: saved ? saves + 1 : (saves > 0 ? saves - 1 : 0),
        );
}
