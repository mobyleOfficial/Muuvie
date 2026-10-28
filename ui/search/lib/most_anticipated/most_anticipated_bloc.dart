import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';

import 'package:search/most_anticipated/most_anticipated_state.dart';

class MostAnticipatedCubit extends Cubit<MostAnticipatedState> {
  final DiscoverMovies _discoverMovies;

  int _totalPages = 1;

  late final PagingController<int, Movie> pagingController = PagingController(
    getNextPageKey: (state) {
      final nextKey = state.nextIntPageKey;
      if (nextKey > _totalPages) return null;
      return nextKey;
    },
    fetchPage: _fetchPage,
  );

  MostAnticipatedCubit(this._discoverMovies)
    : super(const MostAnticipatedSuccess());

  Future<List<Movie>> _fetchPage(int page) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final result = await _discoverMovies(
      DiscoverMoviesParams(
        page: page,
        releaseDateGte: today,
        sortBy: 'popularity.desc',
      ),
    );

    switch (result) {
      case Success(:final data):
        _totalPages = data.totalPages;
        return data.movies;
      case Failure(:final error):
        throw Exception(error.message);
    }
  }

  @override
  Future<void> close() {
    pagingController.dispose();
    return super.close();
  }
}
