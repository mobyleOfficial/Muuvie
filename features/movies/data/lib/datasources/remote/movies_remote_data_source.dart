import 'package:core/core.dart';

import 'package:movies_data/models/remote/remote_movie_detail.dart';
import 'package:movies_data/models/remote/remote_country.dart';
import 'package:movies_data/models/remote/remote_genre.dart';
import 'package:movies_data/models/remote/remote_language.dart';
import 'package:movies_data/models/remote/remote_movie_listing.dart';

abstract interface class MoviesRemoteDataSource {
  Future<Result<RemoteMovieDetail>> getMovieDetail({required int movieId});
  Future<Result<RemoteMovieListing>> searchMovies({
    required String query,
    required int page,
  });
  Future<Result<RemoteMovieListing>> discoverMovies({
    required int page,
    int? primaryReleaseYear,
    String? releaseDateGte,
    String? releaseDateLte,
    String? sortBy,
    String? withGenres,
    String? withOriginalLanguage,
    String? withOriginCountry,
    int? minimumVoteCount,
  });
  Future<Result<List<RemoteGenre>>> getGenres();
  Future<Result<List<RemoteCountry>>> getCountries();
  Future<Result<List<RemoteLanguage>>> getLanguages();

  /// "Em alta no Muuvie" (F14.1).
  Future<Result<RemoteMovieListing>> getTrendingOnMuuvie({required int page});

  /// "Mais amados no Muuvie" (F14.1).
  Future<Result<RemoteMovieListing>> getMostLovedOnMuuvie({required int page});
}
