import 'package:shelves_data/models/remote_shelf.dart';
import 'package:shelves_data/models/remote_shelf_movie.dart';
import 'package:shelves_domain/models/locadora_shelf.dart';

/// A shelf of `/api/v1/locadoras/{id}/shelves`: `{ shelf, movies }`.
class RemoteLocadoraShelf {
  final RemoteShelf shelf;
  final List<RemoteShelfMovie> movies;

  const RemoteLocadoraShelf({required this.shelf, required this.movies});

  factory RemoteLocadoraShelf.fromJson(Map<String, dynamic> json) =>
      RemoteLocadoraShelf(
        shelf: RemoteShelf.fromJson(json['shelf'] as Map<String, dynamic>),
        movies: (json['movies'] as List<dynamic>? ?? const [])
            .map((e) => RemoteShelfMovie.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  LocadoraShelf toDomain() => LocadoraShelf(
    shelf: shelf.toDomain(),
    movies: movies.map((movie) => movie.toDomain()).toList(),
  );
}
