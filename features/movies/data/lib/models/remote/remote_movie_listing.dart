import 'package:movies_domain/domain.dart';

import 'package:movies_data/models/remote/remote_movie.dart';

class RemoteMovieListing {
  final int totalPages;
  final int totalResults;
  final List<RemoteMovie> movies;

  const RemoteMovieListing({
    required this.totalPages,
    required this.totalResults,
    required this.movies,
  });

  factory RemoteMovieListing.fromJson(Map<String, dynamic> json) =>
      RemoteMovieListing(
        totalPages: (json['totalPages'] ?? json['total_pages']) as int,
        totalResults: (json['totalResults'] ?? json['total_results']) as int,
        movies: ((json['movies'] ?? json['results']) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(RemoteMovie.fromJson)
            .toList(),
      );

  MovieListing toDomain() => MovieListing(
    totalPages: totalPages,
    totalResults: totalResults,
    movies: movies.map((movie) => movie.toDomain()).toList(),
  );
}
