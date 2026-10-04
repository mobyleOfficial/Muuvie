import 'package:movies/movies.dart';

sealed class MovieDetailState {
  const MovieDetailState();
}

class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

class MovieDetailSuccess extends MovieDetailState {
  final Movie detail;
  final bool watchProvidersExpanded;
  final bool isLiking;

  const MovieDetailSuccess(
    this.detail, {
    this.watchProvidersExpanded = false,
    this.isLiking = false,
  });

  MovieDetailSuccess copyWith({
    Movie? detail,
    bool? watchProvidersExpanded,
    bool? isLiking,
  }) =>
      MovieDetailSuccess(
        detail ?? this.detail,
        watchProvidersExpanded: watchProvidersExpanded ?? this.watchProvidersExpanded,
        isLiking: isLiking ?? this.isLiking,
      );
}

class MovieDetailError extends MovieDetailState {
  final String message;

  const MovieDetailError(this.message);
}
