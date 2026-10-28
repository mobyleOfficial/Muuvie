import 'package:core/core.dart';
import 'package:shelves_domain/models/shelf_movie.dart';

class RemoteShelfMovie {
  final int movieId;
  final String title;
  final String? posterPath;
  final int? year;
  final String? director;
  final int? runtime;
  final bool watched;
  final Rating? rating;

  const RemoteShelfMovie({
    required this.movieId,
    required this.title,
    this.posterPath,
    this.year,
    this.director,
    this.runtime,
    required this.watched,
    this.rating,
  });

  factory RemoteShelfMovie.fromJson(Map<String, dynamic> json) =>
      RemoteShelfMovie(
        movieId: (json['movieId'] as num).toInt(),
        title: json['title'] as String? ?? '',
        posterPath: json['posterPath'] as String?,
        year: (json['year'] as num?)?.toInt(),
        director: json['director'] as String?,
        runtime: (json['runtime'] as num?)?.toInt(),
        watched: json['watched'] as bool? ?? false,
        rating: Rating.fromWireValue(json['rating'] as String?),
      );

  ShelfMovie toDomain() => ShelfMovie(
    movieId: movieId,
    title: title,
    posterPath: posterPath,
    year: year,
    director: director,
    runtime: runtime,
    watched: watched,
    rating: rating,
  );
}
