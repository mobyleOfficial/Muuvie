import 'package:movies_domain/models/movie_info.dart';

class Movie {
  final int id;
  final String title;
  final String? localTitle;
  final String posterPath;
  final MovieInfo? info;

  const Movie({
    required this.id,
    required this.title,
    this.localTitle,
    required this.posterPath,
    this.info,
  });

  String get displayTitle => localTitle ?? title;

  Movie copyWith({MovieInfo? info}) => Movie(
        id: id,
        title: title,
        localTitle: localTitle,
        posterPath: posterPath,
        info: info ?? this.info,
      );
}
