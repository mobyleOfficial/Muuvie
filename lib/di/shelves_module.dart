import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:shelves/shelves.dart';

@module
abstract class ShelvesModule {
  @lazySingleton
  ShelvesRemoteDataSource shelvesRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => ShelvesRemoteDataSourceImpl(httpClient);

  @lazySingleton
  ShelvesRepository shelvesRepository(
    ShelvesRemoteDataSource remoteDataSource,
  ) => ShelvesRepositoryImpl(remoteDataSource);

  @lazySingleton
  LocadorasRemoteDataSource locadorasRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => LocadorasRemoteDataSourceImpl(httpClient);

  @lazySingleton
  LocadorasRepository locadorasRepository(
    LocadorasRemoteDataSource remoteDataSource,
  ) => LocadorasRepositoryImpl(remoteDataSource);

  @injectable
  GetUserShelves getUserShelves(ShelvesRepository repository) =>
      GetUserShelves(repository);

  @injectable
  SearchMyShelves searchMyShelves(ShelvesRepository repository) =>
      SearchMyShelves(repository);

  @injectable
  GetShelf getShelf(ShelvesRepository repository) => GetShelf(repository);

  @injectable
  GetPublicShelvesWithMovie getPublicShelvesWithMovie(
    ShelvesRepository repository,
  ) => GetPublicShelvesWithMovie(repository);

  @injectable
  DiscoverShelves discoverShelves(ShelvesRepository repository) =>
      DiscoverShelves(repository);

  @injectable
  GetSavedShelves getSavedShelves(ShelvesRepository repository) =>
      GetSavedShelves(repository);

  @injectable
  SetShelfSaved setShelfSaved(ShelvesRepository repository) =>
      SetShelfSaved(repository);

  @injectable
  DiscoverLocadoras discoverLocadoras(LocadorasRepository repository) =>
      DiscoverLocadoras(repository);

  @injectable
  AddMovieToWatchlist addMovieToWatchlist(ShelvesRepository repository) =>
      AddMovieToWatchlist(repository);

  @injectable
  SaveShelf saveShelf(ShelvesRepository repository) => SaveShelf(repository);

  @injectable
  DeleteShelf deleteShelf(ShelvesRepository repository) =>
      DeleteShelf(repository);

  @injectable
  GetShelfMovies getShelfMovies(ShelvesRepository repository) =>
      GetShelfMovies(repository);

  @injectable
  AddMoviesToShelf addMoviesToShelf(ShelvesRepository repository) =>
      AddMoviesToShelf(repository);

  @injectable
  RemoveMovieFromShelf removeMovieFromShelf(ShelvesRepository repository) =>
      RemoveMovieFromShelf(repository);

  @injectable
  TransferShelfMovies transferShelfMovies(ShelvesRepository repository) =>
      TransferShelfMovies(repository);

  @injectable
  SortShelf sortShelf(ShelvesRepository repository) => SortShelf(repository);

  @injectable
  ReorderShelfMovies reorderShelfMovies(ShelvesRepository repository) =>
      ReorderShelfMovies(repository);

  @injectable
  ReorderShelves reorderShelves(ShelvesRepository repository) =>
      ReorderShelves(repository);

  @injectable
  GetMovieShelves getMovieShelves(ShelvesRepository repository) =>
      GetMovieShelves(repository);

  @injectable
  AddMovieToShelves addMovieToShelves(ShelvesRepository repository) =>
      AddMovieToShelves(repository);

  @injectable
  GetUserLocadoras getUserLocadoras(LocadorasRepository repository) =>
      GetUserLocadoras(repository);

  @injectable
  GetLocadora getLocadora(LocadorasRepository repository) =>
      GetLocadora(repository);

  @injectable
  SaveLocadora saveLocadora(LocadorasRepository repository) =>
      SaveLocadora(repository);

  @injectable
  DeleteLocadora deleteLocadora(LocadorasRepository repository) =>
      DeleteLocadora(repository);

  @injectable
  GetLocadoraShelves getLocadoraShelves(LocadorasRepository repository) =>
      GetLocadoraShelves(repository);

  @injectable
  SetLocadoraShelves setLocadoraShelves(LocadorasRepository repository) =>
      SetLocadoraShelves(repository);

  @injectable
  ReorderLocadoraShelves reorderLocadoraShelves(
    LocadorasRepository repository,
  ) => ReorderLocadoraShelves(repository);

  @injectable
  ReorderLocadoras reorderLocadoras(LocadorasRepository repository) =>
      ReorderLocadoras(repository);
}
