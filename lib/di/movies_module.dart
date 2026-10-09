import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:movies/movies.dart';
import 'package:objectbox/objectbox.dart';

@module
abstract class MoviesModule {
  @lazySingleton
  MoviesRemoteDataSource moviesDataSource(
    @Named('backend') HttpClient httpClient,
  ) => MoviesRemoteDataSourceImpl(httpClient);

  @lazySingleton
  MoviesLocalDataSource moviesLocalDataSource(
    Store store,
    LocalClient localClient,
  ) =>
      MoviesLocalDataSourceImpl(
        store.box<LocalRecentSearch>(),
        localClient,
      );

  @lazySingleton
  MoviesRepository moviesRepository(
    MoviesRemoteDataSource remoteDataSource,
    MoviesLocalDataSource localDataSource,
  ) =>
      MoviesRepositoryImpl(remoteDataSource, localDataSource);

  @injectable
  GetTrendingMovies getTrendingMovies(MoviesRepository repository) =>
      GetTrendingMovies(repository);

  @injectable
  GetMovieDetail getMovieDetail(MoviesRepository repository) =>
      GetMovieDetail(repository);

  @injectable
  GetMovieReviews getMovieReviews(MoviesRepository repository) =>
      GetMovieReviews(repository);

  @injectable
  GetReviewDetails getReviewDetails(MoviesRepository repository) =>
      GetReviewDetails(repository);

  @injectable
  LikeReview likeReview(MoviesRepository repository) =>
      LikeReview(repository);

  @injectable
  UnlikeReview unlikeReview(MoviesRepository repository) =>
      UnlikeReview(repository);

  @injectable
  GetMovieLists getMovieLists(MoviesRepository repository) =>
      GetMovieLists(repository);

  @injectable
  GetMovieListDetail getMovieListDetail(MoviesRepository repository) =>
      GetMovieListDetail(repository);

  @injectable
  DiscoverMovies discoverMovies(MoviesRepository repository) =>
      DiscoverMovies(repository);

  @injectable
  GetGenres getGenres(MoviesRepository repository) =>
      GetGenres(repository);

  @injectable
  GetCountries getCountries(MoviesRepository repository) =>
      GetCountries(repository);

  @injectable
  GetLanguages getLanguages(MoviesRepository repository) =>
      GetLanguages(repository);

  @injectable
  SearchMovies searchMovies(MoviesRepository repository) =>
      SearchMovies(repository);

  @injectable
  AddRecentSearch addRecentSearch(MoviesRepository repository) =>
      AddRecentSearch(repository);

  @injectable
  ObserveRecentSearches observeRecentSearches(MoviesRepository repository) =>
      ObserveRecentSearches(repository);

  @injectable
  GetUserWatchList getUserWatchList(MoviesRepository repository) =>
      GetUserWatchList(repository);

  @injectable
  GetFeaturedLists getFeaturedLists(MoviesRepository repository) =>
      GetFeaturedLists(repository);

  @injectable
  LikeMovie likeMovie(MoviesRepository repository) =>
      LikeMovie(repository);

  @injectable
  UnlikeMovie unlikeMovie(MoviesRepository repository) =>
      UnlikeMovie(repository);

  @injectable
  CreateMovieList createMovieList(MoviesRepository repository) =>
      CreateMovieList(repository);

  @injectable
  DeleteMovieList deleteMovieList(MoviesRepository repository) =>
      DeleteMovieList(repository);

  @injectable
  AddMovieToList addMovieToList(MoviesRepository repository) =>
      AddMovieToList(repository);

  @injectable
  RemoveMovieFromList removeMovieFromList(MoviesRepository repository) =>
      RemoveMovieFromList(repository);
}
