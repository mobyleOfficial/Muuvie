import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';

/// The rankings of the Muuvie in the Catálogo (F14.1).
enum MuuvieRanking { trending, loved }

/// "Ver tudo" of "Em alta no Muuvie" and "Mais amados no Muuvie".
@RoutePage()
class MuuvieRankingPage extends StatefulWidget {
  final MuuvieRanking ranking;

  const MuuvieRankingPage({super.key, required this.ranking});

  @override
  State<MuuvieRankingPage> createState() => _MuuvieRankingPageState();
}

class _MuuvieRankingPageState extends State<MuuvieRankingPage> {
  int _totalPages = 1;

  late final PagingController<int, Movie> _pagingController = PagingController(
    getNextPageKey: (state) {
      final nextKey = state.nextIntPageKey;
      return nextKey > _totalPages ? null : nextKey;
    },
    fetchPage: _fetchPage,
  );

  Future<List<Movie>> _fetchPage(int page) async {
    final result = switch (widget.ranking) {
      MuuvieRanking.trending => await GetIt.I<GetTrendingOnMuuvie>()(page),
      MuuvieRanking.loved => await GetIt.I<GetMostLovedOnMuuvie>()(page),
    };
    switch (result) {
      case Success(:final data):
        _totalPages = data.totalPages;
        return data.movies;
      case Failure(:final error):
        throw Exception(error.message);
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => PagedGridView<int, Movie>(
          state: state,
          fetchNextPage: fetchNextPage,
          padding: const EdgeInsets.all(muuvieGridPadding),
          gridDelegate: muuvieGridDelegate,
          builderDelegate: PagedChildBuilderDelegate<Movie>(
            itemBuilder: (context, movie, index) => Semantics(
              label: movie.title,
              button: true,
              child: MuuvieMoviePosterCard(
                imageUrl: movie.posterPath.isNotEmpty
                    ? TmdbImageUrl.buildPosterLarge(movie.posterPath)
                    : null,
                onTap: () => context.router.push(
                  MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
                ),
              ),
            ),
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            firstPageErrorIndicatorBuilder: (_) => MuuvieEmptyState(
              title: l10n?.emptyStateErrorTitle ?? '',
              message: l10n?.emptyStateErrorMessage ?? '',
              action: fetchNextPage,
              actionLabel: l10n?.emptyStateRetry ?? '',
            ),
            noItemsFoundIndicatorBuilder: (_) => MuuvieEmptyState(
              title: l10n?.emptyStateNoItemsTitle ?? '',
              message: l10n?.discoverEmpty ?? '',
            ),
          ),
        ),
      ),
    );
  }
}
