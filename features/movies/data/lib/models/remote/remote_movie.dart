import 'package:movies_domain/domain.dart';

class RemoteMovie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;

  const RemoteMovie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory RemoteMovie.fromJson(Map<String, dynamic> json) => RemoteMovie(
        id: json['id'] as int,
        title: json['title'] as String,
        overview: json['overview'] as String,
        posterPath: (json['posterPath'] ?? json['poster_path']) as String? ?? '',
        backdropPath:
            (json['backdropPath'] ?? json['backdrop_path']) as String? ?? '',
        voteAverage:
            ((json['voteAverage'] ?? json['vote_average']) as num?)
                ?.toDouble() ??
            0.0,
        releaseDate:
            (json['releaseDate'] ?? json['release_date']) as String? ?? '',
      );

  Movie toDomain() => Movie(
        id: id,
        title: title,
        posterPath: posterPath,
        info: MovieInfo(
          overview: overview,
          backdropPath: backdropPath,
          voteAverage: voteAverage,
          releaseDate: releaseDate,
        ),
      );
}
