import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_bloc.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:movies_ui/movie_detail/movie_detail_state.dart';
import 'package:movies_ui/movie_detail/movie_section.dart';
import 'package:movies_ui/movie_detail/movie_community_tab.dart';
import 'package:movies_ui/movie_detail/movie_detail_links.dart';
import 'package:social_network/social_network.dart' show MovieActivityKind;
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_logs_ui/watch_logs_ui.dart';

void _showActionsSheet(
  BuildContext context,
  Movie detail,
  void Function(int, String)? onAddToShelves,
  MovieDetailLinks? links,
) {
  Widget action(IconData icon, String label, VoidCallback onSelected) =>
      Builder(
        builder: (sheetContext) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          onTap: () async {
            Navigator.of(sheetContext).pop();
            final authenticated = await AuthGate.check(context);
            if (authenticated && context.mounted) onSelected();
          },
        ),
      );

  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final l10n = AppLocalizations.of(context);

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              detail.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (onAddToShelves != null)
            action(
              Icons.library_add_outlined,
              l10n?.addToShelvesAction ?? '',
              () => onAddToShelves(detail.id, detail.title),
            ),
          if (links != null) ...[
            action(
              Icons.groups_outlined,
              l10n?.movieDetailCreateCineClube ?? '',
              () => links.createCineClube(context, detail),
            ),
            action(
              Icons.connected_tv_outlined,
              l10n?.movieDetailWatchParty ?? '',
              () => links.startWatchParty(context, detail),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class MovieDetailScreen extends StatelessWidget {
  final MovieDetailCubit cubit;
  final void Function(int movieId, String movieTitle)? onAddToShelves;

  const MovieDetailScreen({
    super.key,
    required this.cubit,
    this.onAddToShelves,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<MovieDetailCubit, MovieDetailState>(
        builder: (context, state) => switch (state) {
          MovieDetailLoading() => const Scaffold(
            body: Center(child: MuuvieActivityIndicator()),
          ),
          MovieDetailError(:final message) => Scaffold(
            body: MuuvieEmptyState(
              illustration: MuuvieIllustration.error,
              title: l10n?.emptyStateErrorTitle ?? '',
              message: message,
              action: cubit.reload,
              actionLabel: l10n?.emptyStateRetry ?? '',
            ),
          ),
          MovieDetailSuccess(:final detail) => Scaffold(
            body: _MovieDetailBody(
              detail: detail,
              onAddToShelves: onAddToShelves,
            ),
          ),
        },
      ),
    );
  }
}

/// The movie (backdrop, poster, credits) and the user's panel scroll away;
/// the Sobre and Comunidade tabs stay pinned under them.
class _MovieDetailBody extends StatefulWidget {
  final Movie detail;
  final void Function(int movieId, String movieTitle)? onAddToShelves;

  const _MovieDetailBody({required this.detail, this.onAddToShelves});

  @override
  State<_MovieDetailBody> createState() => _MovieDetailBodyState();
}

class _MovieDetailBodyState extends State<_MovieDetailBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  final _kindRequests = _KindRequests();

  /// Bumped when the user rates or logs, to reload the community sections.
  int _version = 0;

  @override
  void dispose() {
    _tabs.dispose();
    _kindRequests.dispose();
    super.dispose();
  }

  /// "Ver todas" of the recent ratings: the Atividade tab on Avaliações.
  void _seeAllRatings() {
    _kindRequests.request(MovieActivityKind.ratings);
    _tabs.animateTo(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final links = MovieDetailLinks.current;
    final detail = widget.detail;
    final onAddToShelves = widget.onAddToShelves;

    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        SliverToBoxAdapter(child: _Header(detail: detail)),
        SliverToBoxAdapter(
          child: MovieWatchPanel(
            movieId: detail.id,
            movieTitle: detail.displayTitle,
            runtime: detail.info?.runtime,
            onChanged: () => setState(() => _version++),
            onMore: onAddToShelves == null && links == null
                ? null
                : () =>
                      _showActionsSheet(context, detail, onAddToShelves, links),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              background: colorScheme.surface,
              tabBar: MuuvieTabBar(
                controller: _tabs,
                tabs: [
                  l10n?.movieDetailAboutTab ?? '',
                  l10n?.movieCommunityTitle ?? '',
                  l10n?.movieDetailRecordsTab ?? '',
                ],
              ),
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabs,
        children: [
          _AboutTab(detail: detail),
          // The movie in Muuvie: numbers, charts, shelves, events (B13.5).
          MovieCommunityTab(
            detail: detail,
            links: links,
            version: _version,
            onSeeAllRatings: _seeAllRatings,
          ),
          // Everything people did with the movie (B13.3).
          MuuvieKeepAliveTab(
            child: _BelowPinnedTabs(
              child:
                  links?.activities(detail.id, kindRequests: _kindRequests) ??
                  const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Notifies on every request, even of the kind already asked for: the user
/// may have changed the filter on the tab since.
class _KindRequests extends ValueNotifier<MovieActivityKind?> {
  _KindRequests() : super(null);

  void request(MovieActivityKind kind) {
    if (value == kind) {
      notifyListeners();
    } else {
      value = kind;
    }
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;
  final Color background;

  const _TabBarDelegate({required this.tabBar, required this.background});

  static const double _height = 48;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(color: background, child: tabBar);

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar || oldDelegate.background != background;
}

/// Places a tab that is not a sliver list below the pinned tab bar.
///
/// The body of a NestedScrollView only gets the height left on screen, which
/// is little while the header is open; the tab keeps a minimum height and is
/// clipped instead of overflowing.
class _BelowPinnedTabs extends StatelessWidget {
  final Widget child;

  const _BelowPinnedTabs({required this.child});

  static const double _minHeight = 360;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = math.max(constraints.maxHeight, _minHeight);

      return ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: height,
          maxHeight: height,
          // The absorbed overlap is the pinned tab bar, always this tall.
          child: Padding(
            padding: const EdgeInsets.only(top: _TabBarDelegate._height),
            child: child,
          ),
        ),
      );
    },
  );
}

class _AboutTab extends StatefulWidget {
  final Movie detail;

  const _AboutTab({required this.detail});

  @override
  State<_AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<_AboutTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final detail = widget.detail;
    final info = detail.info;

    // What the movie is, where to watch it, who is in it, then where to go
    // next. What people did with it lives in Comunidade.
    return CustomScrollView(
      key: const PageStorageKey('about'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info?.isUnmatched ?? false) const _UnmatchedNotice(),
              if (info != null && info.overview.trim().isNotEmpty)
                _SynopsisSection(
                  overview: info.overview.trim(),
                  language: info.overviewLanguage,
                  translated: info.overviewTranslated,
                ),
              if (info?.watchProviders.isNotEmpty ?? false)
                _WatchProvidersSection(providers: info!.watchProviders),
              if (info?.cast.isNotEmpty ?? false)
                _CastSection(cast: info!.cast),
              if (info?.similarMovies.isNotEmpty ?? false)
                _SimilarMoviesSection(movies: info!.similarMovies),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

/// An imported movie the catalog could not link to TMDB: only the source's
/// data is shown.
class _UnmatchedNotice extends StatelessWidget {
  const _UnmatchedNotice();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Semantics(
        container: true,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.info_outline,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)?.movieDetailUnmatched ?? '',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backdrop fading into the page, the poster over its edge, the title and
/// facts beside it, then genres and credits.
class _Header extends StatelessWidget {
  final Movie detail;

  const _Header({required this.detail});

  static const double _posterWidth = 112;
  static const double _posterHeight = 168;

  /// How much of the poster sits over the backdrop.
  static const double _posterOverlap = 88;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final info = detail.info;
    final releaseDate = info?.releaseDate ?? '';
    final releaseYear = releaseDate.length >= 4
        ? releaseDate.substring(0, 4)
        : releaseDate;
    final facts = [
      if (releaseYear.isNotEmpty) releaseYear,
      if ((info?.runtime ?? 0) > 0) l10n?.movieDetailMinutes(info!.runtime),
    ].whereType<String>().join('  ·  ');

    return LayoutBuilder(
      builder: (context, constraints) {
        final backdropHeight = math.min(constraints.maxWidth * 9 / 16, 280.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _Backdrop(
                  backdropPath: info?.backdropPath ?? '',
                  height: backdropHeight,
                  trailerKey: info?.trailerKey,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    backdropHeight - _posterOverlap,
                    16,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Poster(
                        posterPath: detail.posterPath,
                        width: _posterWidth,
                        height: _posterHeight,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: _posterOverlap + 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.displayTitle,
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              if (detail.localTitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  detail.title,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              if (facts.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  facts,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (info?.genres.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final genre in info!.genres) _GenrePill(label: genre),
                  ],
                ),
              ),
            if ((info?.director.isNotEmpty ?? false) ||
                (info?.writers.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (info!.director.isNotEmpty)
                      _CreditLine(
                        label: l10n?.movieDetailDirectedBy ?? '',
                        people: [info.director],
                      ),
                    if (info.writers.isNotEmpty)
                      _CreditLine(
                        label: l10n?.movieDetailWrittenBy ?? '',
                        people: [
                          for (final writer in info.writers) writer.name,
                        ],
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Backdrop extends StatelessWidget {
  final String backdropPath;
  final double height;
  final String? trailerKey;

  const _Backdrop({
    required this.backdropPath,
    required this.height,
    this.trailerKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trailerKey = this.trailerKey;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primaryContainer, colorScheme.surface],
        ),
      ),
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: backdropPath.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: TmdbImageUrl.buildBackdrop(backdropPath),
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: colorScheme.surfaceContainerHighest),
                    errorWidget: (_, _, _) => fallback,
                  )
                : fallback,
          ),
          // Fades into the page so the poster and the title sit on it.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.45, 0.85, 1],
                colors: [
                  colorScheme.surface.withValues(alpha: 0),
                  colorScheme.surface.withValues(alpha: 0),
                  colorScheme.surface.withValues(alpha: 0.75),
                  colorScheme.surface,
                ],
              ),
            ),
          ),
          if (trailerKey != null)
            Align(
              alignment: const Alignment(0, -0.25),
              child: _TrailerButton(trailerKey: trailerKey),
            ),
        ],
      ),
    );
  }
}

/// A play button over the backdrop, as on a video.
class _TrailerButton extends StatelessWidget {
  final String trailerKey;

  const _TrailerButton({required this.trailerKey});

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)?.movieDetailTrailer ?? '';
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.black.withValues(alpha: 0.55),
          shape: const StadiumBorder(side: BorderSide(color: Colors.white54)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => launchUrl(
              Uri.https('www.youtube.com', '/watch', {'v': trailerKey}),
              mode: LaunchMode.externalApplication,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 18, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String posterPath;
  final double width;
  final double height;

  const _Poster({
    required this.posterPath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final empty = Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.movie, color: colorScheme.onSurfaceVariant),
    );

    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: MuuvieRadius.mediumAll,
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: MuuvieRadius.mediumAll,
          child: posterPath.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: TmdbImageUrl.buildPosterMedium(posterPath),
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: colorScheme.surfaceContainerHighest),
                  errorWidget: (_, _, _) => empty,
                )
              : empty,
        ),
      ),
    );
  }
}

class _GenrePill extends StatelessWidget {
  final String label;

  const _GenrePill({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: MuuvieRadius.pillAll,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// "Dirigido por" or "Roteiro de" and the names.
class _CreditLine extends StatelessWidget {
  final String label;
  final List<String> people;

  const _CreditLine({required this.label, required this.people});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            children: [
              for (final (index, name) in people.indexed)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 36),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      index < people.length - 1 ? '$name, ' : name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The overview cut at a few lines, with "Ler mais" when it is longer, and a
/// note when it came in English because TMDB had none in Portuguese.
class _SynopsisSection extends StatefulWidget {
  final String overview;

  /// ISO 639-1 of [overview] when it is not Portuguese.
  final String? language;

  /// Machine translated into Portuguese.
  final bool translated;

  const _SynopsisSection({
    required this.overview,
    this.language,
    this.translated = false,
  });

  @override
  State<_SynopsisSection> createState() => _SynopsisSectionState();
}

class _SynopsisSectionState extends State<_SynopsisSection> {
  static const _collapsedLines = 4;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final style = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
      height: 1.55,
    );
    final language = widget.language;
    // Nothing to say when the app already reads in that language.
    final showsEnglishNote =
        language == 'en' &&
        Localizations.localeOf(context).languageCode != language;
    final note = widget.translated
        ? l10n?.movieDetailSynopsisTranslated
        : showsEnglishNote
        ? l10n?.movieDetailSynopsisInEnglish
        : null;

    return MovieSection(
      title: l10n?.movieDetailSynopsis ?? '',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final painter = TextPainter(
            text: TextSpan(text: widget.overview, style: style),
            maxLines: _collapsedLines,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: constraints.maxWidth);
          final overflows = painter.didExceedMaxLines;
          painter.dispose();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.translate,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          note,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: Text.rich(
                  TextSpan(
                    text: widget.overview,
                    // Screen readers pronounce it in its own language.
                    locale: language == null ? null : Locale(language),
                  ),
                  style: style,
                  maxLines: _expanded ? null : _collapsedLines,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
              if (overflows)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded
                        ? l10n?.movieDetailReadLess ?? ''
                        : l10n?.movieDetailReadMore ?? '',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WatchProvidersSection extends StatelessWidget {
  final List<WatchProvider> providers;

  const _WatchProvidersSection({required this.providers});

  static const double _itemSize = 48;
  static const double _spacing = 12;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BlocSelector<MovieDetailCubit, MovieDetailState, bool>(
      selector: (state) =>
          state is MovieDetailSuccess && state.watchProvidersExpanded,
      builder: (context, expanded) => MovieSection(
        title: l10n?.movieDetailWhereToWatch ?? '',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxPerRow =
                ((constraints.maxWidth + _spacing) / (_itemSize + _spacing))
                    .floor();
            final overflows = providers.length > maxPerRow;
            final visibleCount = expanded || !overflows
                ? providers.length
                : maxPerRow - 1;
            final visible = providers.take(visibleCount).toList();

            return AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Wrap(
                spacing: _spacing,
                runSpacing: _spacing,
                children: [
                  ...visible.map(
                    (provider) => _ProviderLogo(provider: provider),
                  ),
                  if (overflows)
                    Semantics(
                      button: true,
                      label: expanded
                          ? l10n?.movieDetailReadLess
                          : '+${providers.length - visibleCount}',
                      child: ExcludeSemantics(
                        child: InkWell(
                          borderRadius: MuuvieRadius.mediumAll,
                          onTap: () => context
                              .read<MovieDetailCubit>()
                              .toggleWatchProviders(),
                          child: Container(
                            width: _itemSize,
                            height: _itemSize,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: MuuvieRadius.mediumAll,
                            ),
                            child: Center(
                              child: expanded
                                  ? Icon(
                                      Icons.expand_less,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant,
                                    )
                                  : Text(
                                      '+${providers.length - visibleCount}',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  final WatchProvider provider;

  const _ProviderLogo({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initial = Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(child: Text(provider.name[0], style: textTheme.labelLarge)),
    );

    return Tooltip(
      message: provider.name,
      child: Container(
        width: _WatchProvidersSection._itemSize,
        height: _WatchProvidersSection._itemSize,
        decoration: BoxDecoration(
          borderRadius: MuuvieRadius.mediumAll,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: MuuvieRadius.mediumAll,
          child: provider.logoPath.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: TmdbImageUrl.buildPosterSmall(provider.logoPath),
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: colorScheme.surfaceContainerHighest),
                  errorWidget: (_, _, _) => initial,
                )
              : initial,
        ),
      ),
    );
  }
}

class _CastSection extends StatelessWidget {
  final List<CastMember> cast;

  const _CastSection({required this.cast});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MovieSection(
      title: l10n?.movieDetailCast ?? 'Cast',
      padContent: false,
      child: SizedBox(
        height: 200,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: cast.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) => _CastMemberCard(member: cast[index]),
        ),
      ),
    );
  }
}

class _CastMemberCard extends StatelessWidget {
  final CastMember member;

  const _CastMemberCard({required this.member});

  static const double _width = 96;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final person = member.person;
    final profilePath = person.profilePath;
    final character = member.character;
    final empty = Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person, size: 36, color: colorScheme.onSurfaceVariant),
    );

    return SizedBox(
      width: _width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: MuuvieRadius.mediumAll,
              child: SizedBox(
                width: _width,
                height: 128,
                child: (profilePath != null && profilePath.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: TmdbImageUrl.buildPosterSmall(profilePath),
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (_, _, _) => empty,
                      )
                    : empty,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            person.name,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (character != null && character.isNotEmpty)
            Text(
              character,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _SimilarMoviesSection extends StatelessWidget {
  final List<Movie> movies;

  const _SimilarMoviesSection({required this.movies});

  static const double _width = 112;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return MovieSection(
      title: l10n?.movieDetailSimilar ?? '',
      padContent: false,
      child: SizedBox(
        height: 214,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: movies.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final movie = movies[index];
            final empty = Container(
              color: colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.movie)),
            );
            return Semantics(
              label: movie.title,
              button: true,
              child: InkWell(
                onTap: () => context.router.push(
                  MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
                ),
                borderRadius: MuuvieRadius.mediumAll,
                child: SizedBox(
                  width: _width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: MuuvieRadius.mediumAll,
                        child: SizedBox(
                          width: _width,
                          height: 168,
                          child: movie.posterPath.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: TmdbImageUrl.buildPosterMedium(
                                    movie.posterPath,
                                  ),
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => Container(
                                    color: colorScheme.surfaceContainerHighest,
                                  ),
                                  errorWidget: (_, _, _) => empty,
                                )
                              : empty,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ExcludeSemantics(
                        child: Text(
                          movie.title,
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
