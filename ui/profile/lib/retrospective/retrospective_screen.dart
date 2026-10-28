import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:profile_ui/retrospective/retrospective_bloc.dart';
import 'package:profile_ui/retrospective/retrospective_state.dart';
import 'package:stats/stats.dart';

/// The stories of the year (F9.3): totals, top genres, directors and actors,
/// the emotion of the year, the favorite movie, the best month, maratonas
/// and CineClubes, and the goal. Tapping the right side goes forward, the
/// left side back.
class RetrospectiveScreen extends StatefulWidget {
  final RetrospectiveCubit cubit;
  final VoidCallback onClose;

  /// Shares the story inside the boundary of the key.
  final ValueChanged<GlobalKey> onShare;

  const RetrospectiveScreen({
    super.key,
    required this.cubit,
    required this.onClose,
    required this.onShare,
  });

  @override
  State<RetrospectiveScreen> createState() => _RetrospectiveScreenState();
}

class _RetrospectiveScreenState extends State<RetrospectiveScreen> {
  final _controller = PageController();
  final _keys = <int, GlobalKey>{};
  var _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GlobalKey _keyOf(int index) => _keys.putIfAbsent(index, GlobalKey.new);

  void _go(int delta, int count) {
    final next = (_page + delta).clamp(0, count - 1);
    if (next == _page) return;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<RetrospectiveCubit, RetrospectiveState>(
          bloc: widget.cubit,
          builder: (context, state) => switch (state) {
            RetrospectiveLoading() => const Center(
              child: MuuvieActivityIndicator(),
            ),
            RetrospectiveError(:final error) => Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: MuuvieCloseButton(onPressed: widget.onClose),
                ),
                Expanded(
                  child: MuuvieEmptyState(
                    illustration: MuuvieIllustration.error,
                    title: error == AppError.notFound
                        ? l10n?.retrospectiveEmpty ?? ''
                        : l10n?.emptyStateErrorTitle ?? '',
                    message: error == AppError.notFound
                        ? ''
                        : l10n?.emptyStateErrorMessage ?? '',
                  ),
                ),
              ],
            ),
            RetrospectiveSuccess(:final retrospective) => _stories(
              context,
              _slides(context, retrospective),
            ),
          },
        ),
      ),
    );
  }

  Widget _stories(BuildContext context, List<Widget> slides) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              for (var i = 0; i < slides.length; i++)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _page ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: l10n?.retrospectiveShare,
              color: Colors.white,
              icon: const Icon(Icons.ios_share),
              onPressed: () => widget.onShare(_keyOf(_page)),
            ),
            MuuvieCloseButton(onPressed: widget.onClose),
          ],
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final width = MediaQuery.sizeOf(context).width;
              _go(details.localPosition.dx > width / 3 ? 1 : -1, slides.length);
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) =>
                  RepaintBoundary(key: _keyOf(index), child: slides[index]),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _slides(BuildContext context, Retrospective r) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final emotion = Emotion.fromWireValue(r.emotion);
    final favorite = r.favorite;
    final best = r.bestMonth;
    final goal = r.goal;
    final locale = Intl.getCurrentLocale();

    return [
      _Story(
        color: colorScheme.primary,
        lines: [_Big('${r.year}'), _Line(l10n?.retrospectiveIntro ?? '')],
      ),
      _Story(
        color: const Color(0xFF6A1B9A),
        lines: [
          _Big('${r.movies}'),
          _Line(l10n?.retrospectiveMovies(r.movies) ?? ''),
          const SizedBox(height: 24),
          _Big('${r.minutes ~/ 60}'),
          _Line(l10n?.retrospectiveHours(r.minutes ~/ 60) ?? ''),
          if (r.rewatches > 0) ...[
            const SizedBox(height: 24),
            _Line(l10n?.retrospectiveRewatches(r.rewatches) ?? ''),
          ],
        ],
      ),
      if (r.topGenres.isNotEmpty)
        _Story(
          color: const Color(0xFF00695C),
          lines: [
            _Line(l10n?.retrospectiveTopGenres ?? ''),
            const SizedBox(height: 16),
            for (final (index, genre) in r.topGenres.indexed)
              _Rank(index + 1, genre.label ?? genre.key, genre.movies, l10n),
          ],
        ),
      if (r.topDirectors.isNotEmpty || r.topActors.isNotEmpty)
        _Story(
          color: const Color(0xFF283593),
          lines: [
            if (r.topDirectors.isNotEmpty) ...[
              _Line(l10n?.retrospectiveTopDirectors ?? ''),
              const SizedBox(height: 8),
              for (final (index, person) in r.topDirectors.take(3).indexed)
                _Rank(index + 1, person.name, person.movies, l10n),
              const SizedBox(height: 24),
            ],
            if (r.topActors.isNotEmpty) ...[
              _Line(l10n?.retrospectiveTopActors ?? ''),
              const SizedBox(height: 8),
              for (final (index, person) in r.topActors.take(3).indexed)
                _Rank(index + 1, person.name, person.movies, l10n),
            ],
          ],
        ),
      if (emotion != null && l10n != null)
        _Story(
          color: const Color(0xFFAD1457),
          lines: [
            _Line(l10n.retrospectiveEmotion),
            const SizedBox(height: 16),
            _Big(l10n.emotion(emotion)),
          ],
        ),
      if (favorite != null)
        _Story(
          color: const Color(0xFFE65100),
          lines: [
            _Line(l10n?.retrospectiveFavorite ?? ''),
            const SizedBox(height: 16),
            if (favorite.posterPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(MuuvieRadius.medium),
                child: CachedNetworkImage(
                  imageUrl: TmdbImageUrl.buildPosterLarge(favorite.posterPath!),
                  height: 260,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            _Line(
              favorite.year == null
                  ? favorite.title
                  : '${favorite.title} (${favorite.year})',
              bold: true,
            ),
            if (r.favoriteRating case final rating?)
              _Line(l10n?.rating(rating) ?? ''),
          ],
        ),
      _Story(
        color: const Color(0xFF37474F),
        lines: [
          if (best != null) ...[
            _Line(l10n?.retrospectiveBestMonth ?? ''),
            _Big(DateFormat.MMMM(locale).format(DateTime(r.year, best.month))),
            _Line(
              '${best.movies} ${l10n?.retrospectiveMovies(best.movies) ?? ''}',
            ),
            const SizedBox(height: 24),
          ],
          if (r.maratonasFinished > 0)
            _Line(l10n?.retrospectiveMaratonas(r.maratonasFinished) ?? ''),
          if (r.cineclubes > 0)
            _Line(l10n?.retrospectiveCineclubes(r.cineclubes) ?? ''),
          if (goal != null) ...[
            const SizedBox(height: 24),
            _Line(
              goal.reached
                  ? l10n?.retrospectiveGoalReached(goal.targetMovies) ?? ''
                  : l10n?.retrospectiveGoalProgress(
                          goal.watched,
                          goal.targetMovies,
                        ) ??
                        '',
              bold: true,
            ),
          ],
          const SizedBox(height: 32),
          _Line(l10n?.retrospectiveOutro ?? ''),
        ],
      ),
    ];
  }
}

class _Story extends StatelessWidget {
  final Color color;
  final List<Widget> lines;

  const _Story({required this.color, required this.lines});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, Color.lerp(color, Colors.black, 0.55)!],
      ),
      borderRadius: BorderRadius.circular(MuuvieRadius.large),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...lines,
        const SizedBox(height: 32),
        const Text(
          'Muuvie',
          style: TextStyle(color: Colors.white70, letterSpacing: 2),
        ),
      ],
    ),
  );
}

class _Big extends StatelessWidget {
  final String text;

  const _Big(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.displayMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );
}

class _Line extends StatelessWidget {
  final String text;
  final bool bold;

  const _Line(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: bold ? FontWeight.bold : null,
      ),
    ),
  );
}

class _Rank extends StatelessWidget {
  final int position;
  final String name;
  final int movies;
  final AppLocalizations? l10n;

  const _Rank(this.position, this.name, this.movies, this.l10n);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      '$position. $name · $movies ${l10n?.retrospectiveMovies(movies) ?? ''}',
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: Colors.white),
    ),
  );
}
