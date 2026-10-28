import 'package:core/core.dart';
import 'package:movies_domain/models/movie_info.dart';

class Movie {
  final int id;
  final String title;
  final String? localTitle;
  final String posterPath;
  final MovieInfo? info;

  /// The viewer's state, in the Catálogo lists (F14.2); null logged out or
  /// when the movie has none.
  final MovieListState? me;

  const Movie({
    required this.id,
    required this.title,
    this.localTitle,
    required this.posterPath,
    this.info,
    this.me,
  });

  String get displayTitle => localTitle ?? title;

  /// The year of the release date, when there is one.
  String? get year {
    final date = info?.releaseDate ?? '';
    return date.length >= 4 ? date.substring(0, 4) : null;
  }

  Movie copyWith({MovieInfo? info}) => Movie(
    id: id,
    title: title,
    localTitle: localTitle,
    posterPath: posterPath,
    info: info ?? this.info,
    me: me,
  );
}

/// Já assisti or Quero ver, and the rating label, of the viewer for a movie.
class MovieListState {
  final WatchStatus? status;
  final Rating? rating;

  const MovieListState({this.status, this.rating});
}
