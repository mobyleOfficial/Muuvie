import 'package:shelves_domain/models/shelf.dart';
import 'package:shelves_domain/models/shelf_movie.dart';

/// A shelf inside a locadora, with its first movies.
class LocadoraShelf {
  final Shelf shelf;
  final List<ShelfMovie> movies;

  const LocadoraShelf({required this.shelf, required this.movies});
}
