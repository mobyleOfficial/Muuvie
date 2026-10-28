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

  const MovieDetailSuccess(this.detail, {this.watchProvidersExpanded = false});

  MovieDetailSuccess copyWith({Movie? detail, bool? watchProvidersExpanded}) =>
      MovieDetailSuccess(
        detail ?? this.detail,
        watchProvidersExpanded:
            watchProvidersExpanded ?? this.watchProvidersExpanded,
      );
}

class MovieDetailError extends MovieDetailState {
  final String message;

  const MovieDetailError(this.message);
}
