import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:core/core.dart';
import 'package:movies_data/datasources/remote/movies_remote_data_source.dart';
import 'package:movies_domain/models/movie.dart';
import 'package:movies_domain/models/movie_listing.dart';
import 'package:movies_domain/models/movie_review_listing.dart';
import 'package:profile_data/datasources/profile_remote_data_source.dart';
import 'package:profile_data/models/user_profile_response_model.dart';
import 'package:profile_domain/models/user_profile.dart';
import 'package:profile_domain/repositories/profile_repository.dart';
import 'package:rxdart/rxdart.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final MoviesRemoteDataSource _moviesRemoteDataSource;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final WebSocketClient _webSocketClient;

  final _profileSubject = BehaviorSubject<UserProfile>();

  ProfileRepositoryImpl(
    this._moviesRemoteDataSource,
    this._profileRemoteDataSource,
    this._webSocketClient,
  ) {
    fetchProfile();
    _listenToWebSocket();
  }

  @override
  Stream<UserProfile> watchProfile() {
    return _profileSubject.stream;
  }

  @override
  Future<void> fetchProfile() async {
    final result = await _profileRemoteDataSource.getUserProfile();

    switch (result) {
      case Success(:final data):
        _profileSubject.add(data);
      case Failure(:final error):
        _profileSubject.addError(error);
    }
  }

  @override
  Future<Result<void>> startScrape({
    required String source,
    required String username,
    required String cookies,
  }) async {
    return _profileRemoteDataSource.startScrape(
      source: source,
      username: username,
      cookies: cookies,
    );
  }

  void _listenToWebSocket() {
    _webSocketClient.messages.listen(
      (message) {
        dev.log('[ProfileWS] WS message received: ${message.type}');
        _handleWsMessage(message);
      },
      onError: (e) {
        dev.log('[ProfileWS] WS stream error: $e');
      },
    );
  }

  void _handleWsMessage(WsMessage message) {
    switch (message.type) {
      case WsMessageType.scrapeStarted:
        dev.log('[ProfileWS] Scrape started');
        if (_profileSubject.hasValue) {
          _profileSubject.add(_profileSubject.value.copyWith(isScraping: true));
        }
      case WsMessageType.scrapeFinished:
        final payload = message.data;
        final watched = int.tryParse(payload?['watched'] as String? ?? '');
        final recentMovies = _parseRecentMovies(
          payload?['recentlyWatched'] as String?,
        );
        dev.log(
          '[ProfileWS] Scrape finished, watched=$watched, recentMovies=${recentMovies.length}',
        );
        if (_profileSubject.hasValue) {
          _profileSubject.add(
            _profileSubject.value.copyWith(
              isScraping: false,
              moviesWatchedCount: watched,
              recentMovies: recentMovies.isNotEmpty ? recentMovies : null,
            ),
          );
        }
      default:
    }
  }

  List<Movie> _parseRecentMovies(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map(
            (e) =>
                RecentMovieModel.fromJson(e as Map<String, dynamic>).toDomain(),
          )
          .toList();
    } catch (e) {
      dev.log('[ProfileWS] Failed to parse recentlyWatched: $e');
      return [];
    }
  }

  @override
  Future<Result<MovieReviewListing>> getUserReviews({required int page}) async {
    final result = await _moviesRemoteDataSource.getMovieReviews(page: page);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<MovieListing>> getUserFavoriteMovies({
    required String userId,
    required int page,
  }) async {
    final result = await _moviesRemoteDataSource.getUserFavoriteMovies(
      userId: userId,
      page: page,
    );

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> updateUserProfile({
    required UserProfile profile,
  }) async => _profileRemoteDataSource.updateUserProfile(profile: profile);
}
