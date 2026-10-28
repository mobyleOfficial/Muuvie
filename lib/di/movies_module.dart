import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:movies/movies.dart';

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
  ) => MoviesLocalDataSourceImpl(store.box<LocalRecentSearch>(), localClient);

  @lazySingleton
  MoviesRepository moviesRepository(
    MoviesRemoteDataSource remoteDataSource,
    MoviesLocalDataSource localDataSource,
  ) => MoviesRepositoryImpl(remoteDataSource, localDataSource);

  @lazySingleton
  PersonsRepository personsRepository(
    @Named('backend') HttpClient httpClient,
  ) => PersonsRepositoryImpl(PersonsRemoteDataSource(httpClient));

  @injectable
  GetPersonDetail getPersonDetail(PersonsRepository repository) =>
      GetPersonDetail(repository);

  @lazySingleton
  MovieCommunityRepository movieCommunityRepository(
    @Named('backend') HttpClient httpClient,
  ) => MovieCommunityRepositoryImpl(MovieCommunityRemoteDataSource(httpClient));

  @injectable
  GetMovieCommunity getMovieCommunity(MovieCommunityRepository repository) =>
      GetMovieCommunity(repository);

  @injectable
  GetMovieEvents getMovieEvents(MovieCommunityRepository repository) =>
      GetMovieEvents(repository);

  @injectable
  GetMovieCineClubes getMovieCineClubes(MovieCommunityRepository repository) =>
      GetMovieCineClubes(repository);

  @injectable
  GetMovieMaratonas getMovieMaratonas(MovieCommunityRepository repository) =>
      GetMovieMaratonas(repository);

  @injectable
  GetMovieTimeline getMovieTimeline(MovieCommunityRepository repository) =>
      GetMovieTimeline(repository);

  @injectable
  GetMovieDetail getMovieDetail(MoviesRepository repository) =>
      GetMovieDetail(repository);

  @injectable
  DiscoverMovies discoverMovies(MoviesRepository repository) =>
      DiscoverMovies(repository);

  @injectable
  GetTrendingOnMuuvie getTrendingOnMuuvie(MoviesRepository repository) =>
      GetTrendingOnMuuvie(repository);

  @injectable
  GetMostLovedOnMuuvie getMostLovedOnMuuvie(MoviesRepository repository) =>
      GetMostLovedOnMuuvie(repository);

  @injectable
  GetGenres getGenres(MoviesRepository repository) => GetGenres(repository);

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
  RemoveRecentSearches removeRecentSearches(MoviesRepository repository) =>
      RemoveRecentSearches(repository);

  @injectable
  ObserveRecentSearches observeRecentSearches(MoviesRepository repository) =>
      ObserveRecentSearches(repository);
}
