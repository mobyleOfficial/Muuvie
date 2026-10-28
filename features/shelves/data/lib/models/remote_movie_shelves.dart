import 'package:shelves_domain/models/movie_shelves.dart';

class RemoteMovieShelves {
  final int? movieId;
  final List<int> shelfIds;

  const RemoteMovieShelves({required this.movieId, required this.shelfIds});

  factory RemoteMovieShelves.fromJson(Map<String, dynamic> json) =>
      RemoteMovieShelves(
        movieId: (json['movieId'] as num?)?.toInt(),
        shelfIds: (json['shelfIds'] as List<dynamic>? ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
      );

  MovieShelves toDomain() =>
      MovieShelves(movieId: movieId, shelfIds: shelfIds.toSet());
}
