import 'package:shelves_domain/models/shelf.dart';

/// A public custom shelf that holds a movie, with its owner (B13.2).
class PublicShelf {
  final Shelf shelf;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final String? ownerAccentColor;

  const PublicShelf({
    required this.shelf,
    required this.ownerId,
    required this.ownerName,
    this.ownerAvatarUrl,
    this.ownerAccentColor,
  });
}
