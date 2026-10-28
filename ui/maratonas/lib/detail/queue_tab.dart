import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maratonas/maratonas.dart';
import 'package:shelves/shelves.dart';

/// "Minha Fila" (F7.3): the shelf created on joining, to plan what to watch.
class MaratonaQueueTab extends StatefulWidget {
  final Maratona maratona;
  final ValueChanged<ShelfMovie> onOpenMovie;
  final VoidCallback onOpenShelf;

  const MaratonaQueueTab({
    super.key,
    required this.maratona,
    required this.onOpenMovie,
    required this.onOpenShelf,
  });

  @override
  State<MaratonaQueueTab> createState() => _MaratonaQueueTabState();
}

class _MaratonaQueueTabState extends State<MaratonaQueueTab> {
  final _getShelfMovies = GetIt.I<GetShelfMovies>();
  List<ShelfMovie> _movies = const [];
  bool _loading = true;
  bool _failed = false;

  int? get _shelfId => widget.maratona.me?.queueShelfId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MaratonaQueueTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maratona.me?.queueShelfId != _shelfId) _load();
  }

  Future<void> _load() async {
    final shelfId = _shelfId;
    if (shelfId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final result = await _getShelfMovies(
      GetShelfMoviesParams(shelfId: shelfId),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _failed = result is Failure;
      if (result case Success(:final data)) _movies = data.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_shelfId == null) {
      return MuuvieEmptyState(
        illustration: MuuvieIllustration.maratona,
        title: l10n?.maratonaTabQueue ?? '',
        message: l10n?.maratonaQueueJoin ?? '',
      );
    }
    if (_loading) return const Center(child: MuuvieActivityIndicator());
    if (_failed) {
      return MuuvieEmptyState(
        illustration: MuuvieIllustration.error,
        title: l10n?.emptyStateErrorTitle ?? '',
        message: l10n?.emptyStateErrorMessage ?? '',
        action: _load,
        actionLabel: l10n?.emptyStateRetry ?? '',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: widget.onOpenShelf,
                  icon: const Icon(Icons.collections_bookmark_outlined),
                  label: Text(l10n?.maratonaQueueOpen ?? ''),
                ),
              ),
            ),
          ),
          if (_movies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: MuuvieEmptyState(
                illustration: MuuvieIllustration.maratona,
                title: l10n?.maratonaTabQueue ?? '',
                message: l10n?.maratonaQueueEmpty ?? '',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(muuvieGridPadding),
              sliver: SliverGrid.builder(
                gridDelegate: muuvieGridDelegate,
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  final poster = movie.posterPath;
                  return Semantics(
                    label: movie.title,
                    button: true,
                    child: MuuvieMoviePosterCard(
                      imageUrl: poster == null
                          ? null
                          : TmdbImageUrl.buildPosterMedium(poster),
                      onTap: () => widget.onOpenMovie(movie),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
