import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_state.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final GetMovieDetail _getMovieDetail;
  final LikeMovie _likeMovie;
  final UnlikeMovie _unlikeMovie;
  final int _movieId;

  MovieDetailCubit(
    this._getMovieDetail,
    this._likeMovie,
    this._unlikeMovie,
    this._movieId,
  ) : super(const MovieDetailLoading()) {
    _fetchMovieDetail();
  }

  void reload() {
    emit(const MovieDetailLoading());
    _fetchMovieDetail();
  }

  void toggleWatchProviders() {
    final current = state;
    if (current is MovieDetailSuccess) {
      emit(current.copyWith(watchProvidersExpanded: !current.watchProvidersExpanded));
    }
  }

  Future<void> toggleLike() async {
    final current = state;
    if (current is! MovieDetailSuccess || current.isLiking) return;

    final info = current.detail.info;
    if (info == null) return;

    final wasLiked = info.isLikedByCurrentUser;
    final optimisticInfo = info.copyWith(
      isLikedByCurrentUser: !wasLiked,
      likeCount: wasLiked ? (info.likeCount - 1).clamp(0, info.likeCount) : info.likeCount + 1,
    );
    final optimisticDetail = current.detail.copyWith(info: optimisticInfo);

    emit(current.copyWith(detail: optimisticDetail, isLiking: true));

    final result = wasLiked
        ? await _unlikeMovie(_movieId)
        : await _likeMovie(_movieId);

    if (result is Failure) {
      // Revert on failure
      emit(current.copyWith(detail: current.detail, isLiking: false));
    } else {
      final s = state;
      if (s is MovieDetailSuccess) {
        emit(s.copyWith(isLiking: false));
      }
    }
  }

  Future<void> _fetchMovieDetail() async {
    final result = await _getMovieDetail(
      GetMovieDetailParams(movieId: _movieId),
    );

    switch (result) {
      case Success(:final data):
        emit(MovieDetailSuccess(data));
      case Failure(:final error):
        emit(MovieDetailError(error.message));
    }
  }
}
