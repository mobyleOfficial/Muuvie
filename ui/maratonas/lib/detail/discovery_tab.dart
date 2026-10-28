import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maratonas/maratonas.dart';
import 'package:shelves/shelves.dart';

/// "Descoberta" (F7.3): movies that fit the criteria of a challenge, from
/// TMDB. A participant adds them to the maratona queue with a long press.
class MaratonaDiscoveryTab extends StatefulWidget {
  final Maratona maratona;
  final List<MaratonaCategory> categories;
  final ValueChanged<SuggestedMovie> onOpenMovie;

  const MaratonaDiscoveryTab({
    super.key,
    required this.maratona,
    required this.categories,
    required this.onOpenMovie,
  });

  @override
  State<MaratonaDiscoveryTab> createState() => _MaratonaDiscoveryTabState();
}

class _MaratonaDiscoveryTabState extends State<MaratonaDiscoveryTab> {
  final _getSuggestions = GetIt.I<GetChallengeSuggestions>();
  final _addMovieToShelves = GetIt.I<AddMovieToShelves>();

  late final List<MaratonaChallenge> _challenges = widget.categories
      .expand((category) => category.challenges)
      .where((challenge) => challenge.criteria != null)
      .toList();
  MaratonaChallenge? _selected;
  List<SuggestedMovie> _movies = const [];
  int _page = 1;
  bool _hasNext = false;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // Start with the first challenge still open, if any.
    _selected =
        _challenges.where((challenge) => !challenge.completed).firstOrNull ??
        _challenges.firstOrNull;
    if (_selected != null) _load();
  }

  Future<void> _load({bool more = false}) async {
    final challenge = _selected;
    if (challenge == null || _loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    final page = more ? _page + 1 : 1;
    final result = await _getSuggestions(
      GetChallengeSuggestionsParams(
        slug: widget.maratona.slug,
        challengeId: challenge.id,
        page: page,
      ),
    );
    if (!mounted || _selected?.id != challenge.id) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _movies = more ? [..._movies, ...data.movies] : data.movies;
          _page = page;
          _hasNext = data.hasNext;
        case Failure():
          _failed = !more;
      }
    });
  }

  void _select(MaratonaChallenge challenge) {
    if (_selected?.id == challenge.id) return;
    setState(() {
      _selected = challenge;
      _movies = const [];
    });
    _load();
  }

  Future<void> _addToQueue(SuggestedMovie movie) async {
    final shelfId = widget.maratona.me?.queueShelfId;
    if (shelfId == null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await _addMovieToShelves(
      AddMovieToShelvesParams(movieId: movie.id, shelfIds: [shelfId]),
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result is Success
              ? l10n?.maratonaAddedToQueue ?? ''
              : l10n?.maratonaActionError ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selected;
    final canQueue = widget.maratona.me?.queueShelfId != null;

    if (selected == null) {
      return MuuvieEmptyState(
        illustration: MuuvieIllustration.maratona,
        title: l10n?.maratonaTabDiscovery ?? '',
        message: l10n?.maratonaDiscoveryNone ?? '',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_hasNext && notification.metrics.extentAfter < 400) {
          _load(more: true);
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DropdownButtonFormField<int>(
                initialValue: selected.id,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n?.maratonaDiscoveryPick,
                ),
                items: [
                  for (final challenge in _challenges)
                    DropdownMenuItem(
                      value: challenge.id,
                      child: Text(
                        challenge.description,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) => _select(
                  _challenges.firstWhere((challenge) => challenge.id == id),
                ),
              ),
            ),
          ),
          if (_failed)
            SliverFillRemaining(
              hasScrollBody: false,
              child: MuuvieEmptyState(
                illustration: MuuvieIllustration.error,
                title: l10n?.emptyStateErrorTitle ?? '',
                message: l10n?.emptyStateErrorMessage ?? '',
                action: _load,
                actionLabel: l10n?.emptyStateRetry ?? '',
              ),
            )
          else if (_movies.isEmpty && _loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: MuuvieActivityIndicator()),
            )
          else if (_movies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: MuuvieEmptyState(
                illustration: MuuvieIllustration.maratona,
                title: l10n?.maratonaTabDiscovery ?? '',
                message: l10n?.maratonaPickerEmpty ?? '',
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
                    onLongPressHint: canQueue ? l10n?.maratonaAddToQueue : null,
                    child: GestureDetector(
                      onLongPress: canQueue ? () => _addToQueue(movie) : null,
                      child: MuuvieMoviePosterCard(
                        imageUrl: poster == null
                            ? null
                            : TmdbImageUrl.buildPosterMedium(poster),
                        onTap: () => widget.onOpenMovie(movie),
                      ),
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
