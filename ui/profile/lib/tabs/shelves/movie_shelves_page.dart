import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shelves/shelves.dart';

import 'package:profile_ui/member/highlights/highlights_tab.dart';
import 'package:profile_ui/profile_router.dart';

/// "Estantes com este filme" (B13.2): public custom shelves of anyone that
/// hold the movie, with their owners, last updated first.
@RoutePage()
class MovieShelvesPage extends StatefulWidget {
  /// Database id of the movie.
  final int movieId;
  final String movieTitle;

  const MovieShelvesPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<MovieShelvesPage> createState() => _MovieShelvesPageState();
}

class _MovieShelvesPageState extends State<MovieShelvesPage> {
  final _getShelves = GetIt.I<GetPublicShelvesWithMovie>();
  final List<PublicShelf> _shelves = [];
  int _page = 0;
  bool _hasNext = true;
  bool _loading = false;
  AppError? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasNext) return;
    setState(() => _loading = true);
    final result = await _getShelves(
      PublicShelvesParams(movieId: widget.movieId, page: _page + 1),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _shelves.addAll(data.items);
          _page = data.page;
          _hasNext = data.hasNext;
          _error = null;
        case Failure(:final error):
          _error = error;
      }
    });
  }

  Future<void> _retry() async {
    setState(() => _error = null);
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // The title comes from the shell app bar (route_title_resolver).
    return Scaffold(body: _body(context, l10n));
  }

  Widget _body(BuildContext context, AppLocalizations? l10n) {
    if (_shelves.isEmpty) {
      if (_loading) return const Center(child: MuuvieActivityIndicator());
      return _error != null
          ? MuuvieEmptyState(
              illustration: MuuvieIllustration.error,
              title: l10n?.emptyStateErrorTitle ?? '',
              message: l10n?.emptyStateErrorMessage ?? '',
              action: _retry,
              actionLabel: l10n?.emptyStateRetry ?? '',
            )
          : MuuvieEmptyState(
              illustration: MuuvieIllustration.movies,
              title: widget.movieTitle,
              message: l10n?.movieShelvesEmpty ?? '',
            );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 400) _loadMore();
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _shelves.length + (_loading ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _shelves.length) {
            return const Center(child: MuuvieActivityIndicator());
          }
          final item = _shelves[index];
          final shelf = item.shelf;
          return HighlightCollectionCard(
            title: shelf.name,
            subtitle: [
              l10n?.movieShelvesBy(item.ownerName) ?? '',
              l10n?.shelfMoviesCount(shelf.totalMovies) ?? '',
            ].join(' · '),
            posterPaths: shelf.posterPaths,
            onTap: () => context.router.push(
              ShelfDetailRoute(
                shelfId: shelf.id,
                shelfName: shelf.name,
                shelfColor: shelf.color,
              ),
            ),
          );
        },
      ),
    );
  }
}
