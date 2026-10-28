import 'package:core/core.dart';
import 'package:movies_data/datasources/remote/movie_community_remote_data_source.dart';
import 'package:movies_domain/models/movie_community.dart';
import 'package:movies_domain/repositories/movie_community_repository.dart';

class MovieCommunityRepositoryImpl implements MovieCommunityRepository {
  final MovieCommunityRemoteDataSource _remoteDataSource;

  MovieCommunityRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<MovieCommunity>> getCommunity(int movieId) =>
      _remoteDataSource.getCommunity(movieId);

  @override
  Future<Result<MovieEvents>> getEvents(int movieId) =>
      _remoteDataSource.getEvents(movieId);

  @override
  Future<Result<MovieEventPage>> getCineClubes(int movieId, {int page = 1}) =>
      _remoteDataSource.getCineClubes(movieId, page: page);

  @override
  Future<Result<MovieEventPage>> getMaratonas(int movieId, {int page = 1}) =>
      _remoteDataSource.getMaratonas(movieId, page: page);

  @override
  Future<Result<MovieTimeline>> getTimeline(int movieId, {int months = 12}) =>
      _remoteDataSource.getTimeline(movieId, months: months);
}
