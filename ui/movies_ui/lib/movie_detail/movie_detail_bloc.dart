import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_state.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final GetMovieDetail _getMovieDetail;
  final int _movieId;

  MovieDetailCubit(this._getMovieDetail, this._movieId)
      : super(const MovieDetailLoading()) {
    _fetchMovieDetail();
  }

  void reload() {
    emit(const MovieDetailLoading());
    _fetchMovieDetail();
  }

  void toggleWatchProviders() {
    final current = state;
    if (current is MovieDetailSuccess) {
      emit(MovieDetailSuccess(
        current.detail,
        watchProvidersExpanded: !current.watchProvidersExpanded,
      ));
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
