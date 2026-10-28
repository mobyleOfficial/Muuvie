import 'package:shelves_data/models/remote_shelf.dart';
import 'package:shelves_domain/models/public_shelf.dart';

/// `{ shelf, owner }` of `GET /movies/{id}/shelves/public` (B13.2).
class RemotePublicShelf {
  final RemoteShelf shelf;
  final Map<String, dynamic> owner;

  const RemotePublicShelf({required this.shelf, required this.owner});

  factory RemotePublicShelf.fromJson(Map<String, dynamic> json) =>
      RemotePublicShelf(
        shelf: RemoteShelf.fromJson(json['shelf'] as Map<String, dynamic>),
        owner: json['owner'] as Map<String, dynamic>? ?? const {},
      );

  PublicShelf toDomain() => PublicShelf(
    shelf: shelf.toDomain(),
    ownerId: owner['id'] as String? ?? '',
    ownerName:
        owner['displayName'] as String? ?? owner['username'] as String? ?? '',
    ownerAvatarUrl: owner['avatarUrl'] as String?,
    ownerAccentColor: owner['accentColor'] as String?,
  );
}
