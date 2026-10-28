import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:profile/profile.dart';
import 'package:shelves/shelves.dart';

/// Picks the top 4 among the movies on "Já assisti", in the order tapped.
class TopMoviesPicker extends StatefulWidget {
  static const maxMovies = 4;

  final List<HighlightMovie> initial;

  const TopMoviesPicker({super.key, required this.initial});

  static Future<List<HighlightMovie>?> show(
    BuildContext context,
    List<HighlightMovie> initial,
  ) => Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => TopMoviesPicker(initial: initial),
    ),
  );

  @override
  State<TopMoviesPicker> createState() => _TopMoviesPickerState();
}

class _TopMoviesPickerState extends State<TopMoviesPicker> {
  final GetUserShelves _getUserShelves = GetIt.I<GetUserShelves>();
  final GetShelfMovies _getShelfMovies = GetIt.I<GetShelfMovies>();
  late final List<HighlightMovie> _selected = [...widget.initial];
  int? _watchedShelfId;
  bool _hasNext = true;

  late final PagingController<int, ShelfMovie> _pagingController =
      PagingController(
        getNextPageKey: (state) => _hasNext ? state.nextIntPageKey : null,
        fetchPage: _fetchPage,
      );

  Future<int> _watchedShelf() async {
    final known = _watchedShelfId;
    if (known != null) return known;
    // The system shelves sit at the top of the profile order.
    for (var page = 1; page <= 3; page++) {
      final result = await _getUserShelves(GetUserShelvesParams(page: page));
      if (result case Success(:final data)) {
        for (final shelf in data.items) {
          if (shelf.systemType == SystemShelfType.watched) {
            return _watchedShelfId = shelf.id;
          }
        }
        if (!data.hasNext) break;
      } else {
        throw Exception(AppError.network.message);
      }
    }
    throw Exception(AppError.notFound.message);
  }

  Future<List<ShelfMovie>> _fetchPage(int page) async {
    final shelfId = await _watchedShelf();
    final result = await _getShelfMovies(
      GetShelfMoviesParams(shelfId: shelfId, page: page),
    );
    switch (result) {
      case Success(:final data):
        _hasNext = data.hasNext;
        return data.items;
      case Failure(:final error):
        throw Exception(error.message);
    }
  }

  void _toggle(ShelfMovie movie) => setState(() {
    final index = _selected.indexWhere((m) => m.movieId == movie.movieId);
    if (index >= 0) {
      _selected.removeAt(index);
    } else if (_selected.length < TopMoviesPicker.maxMovies) {
      _selected.add(
        HighlightMovie(
          movieId: movie.movieId,
          title: movie.title,
          posterPath: movie.posterPath,
          year: movie.year,
        ),
      );
    }
  });

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.highlightTop4Count(_selected.length) ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: Text(l10n?.shelfReorderDone ?? ''),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n?.highlightTop4Pick ?? ''),
          ),
          Expanded(
            child: PagingListener(
              controller: _pagingController,
              builder: (context, state, fetchNextPage) =>
                  PagedGridView<int, ShelfMovie>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2 / 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    builderDelegate: PagedChildBuilderDelegate<ShelfMovie>(
                      itemBuilder: (context, movie, index) {
                        final position = _selected.indexWhere(
                          (m) => m.movieId == movie.movieId,
                        );
                        final path = movie.posterPath;
                        return Semantics(
                          label: movie.title,
                          selected: position >= 0,
                          button: true,
                          child: InkWell(
                            onTap: () => _toggle(movie),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: MuuvieRadius.smallAll,
                                  child: path == null
                                      ? ColoredBox(
                                          color: colorScheme
                                              .surfaceContainerHighest,
                                          child: Center(
                                            child: Text(
                                              movie.title,
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                            ),
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl:
                                              TmdbImageUrl.buildPosterSmall(
                                                path,
                                              ),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                if (position >= 0)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: colorScheme.primary,
                                        child: Text(
                                          '${position + 1}',
                                          style: TextStyle(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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
                        message: l10n?.highlightTop4Empty ?? '',
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
