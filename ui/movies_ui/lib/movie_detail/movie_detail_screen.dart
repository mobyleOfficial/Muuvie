import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comments_ui/comments_screen.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_bloc.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:movies_ui/movie_detail/movie_detail_state.dart';
import 'package:reviews/review_details/review_details_router.dart';
import 'package:reviews/reviews_list/reviews_router.dart';

class MovieDetailScreen extends StatelessWidget {
  final MovieDetailCubit cubit;

  const MovieDetailScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<MovieDetailCubit, MovieDetailState>(
        builder: (context, state) => switch (state) {
          MovieDetailLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          MovieDetailError(:final message) => Scaffold(
              body: MuuvieEmptyState(
                title: l10n?.emptyStateErrorTitle ?? '',
                message: message,
                action: cubit.reload,
                actionLabel: l10n?.emptyStateRetry ?? '',
              ),
            ),
          MovieDetailSuccess(:final detail) => Scaffold(
              body: _MovieDetailBody(detail: detail),
            ),
        },
      ),
    );
  }
}

class _MovieDetailBody extends StatelessWidget {
  final Movie detail;

  const _MovieDetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          MuuvieTabBar(tabs: [
            l10n?.movieDetailAboutTab ?? '',
            l10n?.comments ?? '',
          ]),
          Expanded(
            child: TabBarView(
              children: [
                _AboutTab(detail: detail),
                _CommentsTab(movieId: detail.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

    return CustomScrollView(
      slivers: [
        _HeroAppBar(detail: detail),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MovieInfoSection(detail: detail),
              if (detail.info?.watchProviders.isNotEmpty ?? false)
                _WatchProvidersSection(
                    providers: detail.info!.watchProviders),
              if (detail.info != null)
                _SynopsisSection(overview: detail.info!.overview),
              _RatingSection(detail: detail),
              _StatsSection(detail: detail),
              if (detail.info?.popularReviews.isNotEmpty ?? false)
                _PopularReviewsSection(
                  reviews: detail.info!.popularReviews,
                  movieId: detail.id,
                  movieTitle: detail.title,
                ),
              if (detail.info?.similarMovies.isNotEmpty ?? false)
                _SimilarMoviesSection(movies: detail.info!.similarMovies),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentsTab extends StatefulWidget {
  final int movieId;

  const _CommentsTab({required this.movieId});

  @override
  State<_CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<_CommentsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CommentsScreen(contentId: widget.movieId.toString());
  }
}

class _HeroAppBar extends StatelessWidget {
  final Movie detail;

  const _HeroAppBar({required this.detail});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: (detail.info?.backdropPath.isNotEmpty ?? false)
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: TmdbImageUrl.buildBackdrop(detail.info!.backdropPath),
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(color: Colors.black),
      ),
    );
  }
}

class _MovieInfoSection extends StatelessWidget {
  final Movie detail;

  const _MovieInfoSection({required this.detail});

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.displayTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (detail.localTitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail.title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      releaseYear,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if ((info?.runtime ?? 0) > 0) ...[
                      _Dot(color: colorScheme.onSurfaceVariant),
                      Text(
                        l10n?.movieDetailMinutes(info!.runtime) ?? '',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                if (info?.genres.isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  Text(
                    info!.genres.join(', '),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (info?.director.isNotEmpty ?? false) ...[
                  const SizedBox(height: 10),
                  Text(
                    l10n?.movieDetailDirectedBy ?? '',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    info!.director,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 100,
              height: 150,
              child: detail.posterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: TmdbImageUrl.buildPosterMedium(detail.posterPath),
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.movie,
                            color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.movie,
                          color: colorScheme.onSurfaceVariant),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchProvidersSection extends StatelessWidget {
  final List<WatchProvider> providers;

  const _WatchProvidersSection({required this.providers});

  static const double _itemSize = 44;
  static const double _spacing = 12;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BlocSelector<MovieDetailCubit, MovieDetailState, bool>(
      selector: (state) =>
          state is MovieDetailSuccess && state.watchProvidersExpanded,
      builder: (context, expanded) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.movieDetailWhereToWatch ?? '',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxPerRow =
                    ((constraints.maxWidth + _spacing) / (_itemSize + _spacing))
                        .floor();
                final overflows = providers.length > maxPerRow;
                final visibleCount =
                    expanded || !overflows ? providers.length : maxPerRow - 1;
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
                          (provider) => _ProviderLogo(provider: provider)),
                      if (overflows)
                        GestureDetector(
                          onTap: () => context
                              .read<MovieDetailCubit>()
                              .toggleWatchProviders(),
                          child: Container(
                            width: _itemSize,
                            height: _itemSize,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: expanded
                                  ? Icon(Icons.expand_less,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant)
                                  : Text(
                                      '+${providers.length - visibleCount}',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
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
          ],
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

    return Tooltip(
      message: provider.name,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 44,
          height: 44,
          child: provider.logoPath.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: TmdbImageUrl.buildPosterSmall(provider.logoPath),
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Text(
                        provider.name[0],
                        style: textTheme.labelLarge,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Text(
                      provider.name[0],
                      style: textTheme.labelLarge,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _SynopsisSection extends StatelessWidget {
  final String overview;

  const _SynopsisSection({required this.overview});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.movieDetailSynopsis ?? '',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            overview,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final Movie detail;

  const _RatingSection({required this.detail});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        children: [
          Icon(Icons.star_rounded,
              color: colorScheme.onTertiaryContainer, size: 32),
          const SizedBox(width: 8),
          Text(
            (detail.info?.voteAverage ?? 0).toStringAsFixed(1),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            ' / 10',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final Movie detail;

  const _StatsSection({required this.detail});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final info = detail.info;
    final isLiked = info?.isLikedByCurrentUser ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final authenticated = await AuthGate.check(context);
              if (authenticated && context.mounted) {
                context.read<MovieDetailCubit>().toggleLike();
              }
            },
            child: _StatItem(
              icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              label: l10n?.movieDetailLikes(info?.likeCount ?? 0) ?? '',
              iconColor: colorScheme.error,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 24),
          _StatItem(
            icon: Icons.rate_review_rounded,
            label: l10n?.movieDetailReviewCount(info?.reviewCount ?? 0) ?? '',
            iconColor: colorScheme.primary,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 24),
          _StatItem(
            icon: Icons.list_rounded,
            label: l10n?.movieDetailListCount(info?.listCount ?? 0) ?? '',
            iconColor: colorScheme.tertiary,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}

class _PopularReviewsSection extends StatelessWidget {
  final List<MovieReview> reviews;
  final int movieId;
  final String movieTitle;

  const _PopularReviewsSection({
    required this.reviews,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n?.movieDetailReviews ?? '',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Semantics(
                label: l10n?.movieDetailSeeAll ?? 'See all',
                button: true,
                child: InkWell(
                  onTap: () => context.router.root.push(
                    ReviewsRoute(
                        movieId: movieId, movieTitle: movieTitle),
                  ),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    child: Text(
                      l10n?.movieDetailSeeAll ?? 'See all',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Semantics(
                label: '${review.author ?? ''}, ${review.date}',
                button: true,
                child: InkWell(
                  onTap: () => context.router.push(
                    ReviewDetailsRoute(
                      reviewId: review.id,
                      movieTitle: review.title,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                (review.author ?? '?')[0].toUpperCase(),
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                review.author ?? '',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Icon(Icons.star_rounded,
                                size: 16,
                                color: colorScheme.onTertiaryContainer),
                            const SizedBox(width: 2),
                            Text(
                              review.rating.toStringAsFixed(1),
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review.content ?? '',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          review.date,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
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

class _SimilarMoviesSection extends StatelessWidget {
  final List<Movie> movies;

  const _SimilarMoviesSection({required this.movies});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n?.movieDetailSimilar ?? '',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Semantics(
                  label: movie.title,
                  button: true,
                  child: InkWell(
                    onTap: () => context.router.push(
                      MovieDetailRoute(
                        movieId: movie.id,
                        movieTitle: movie.title,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 100,
                              height: 140,
                              child: movie.posterPath.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: TmdbImageUrl.buildPosterMedium(movie.posterPath),
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) => Container(
                                        color: colorScheme
                                            .surfaceContainerHighest,
                                      ),
                                      errorWidget: (_, _, _) => Container(
                                        color: colorScheme
                                            .surfaceContainerHighest,
                                        child: const Center(
                                            child: Icon(Icons.movie)),
                                      ),
                                    )
                                  : Container(
                                      color: colorScheme
                                          .surfaceContainerHighest,
                                      child: const Center(
                                          child: Icon(Icons.movie)),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ExcludeSemantics(
                            child: Text(
                              movie.title,
                              style: textTheme.labelSmall?.copyWith(
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
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      );
}
