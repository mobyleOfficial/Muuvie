import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:news_domain/models/article.dart';
import 'package:shelves_ui/shelves_router.dart';
import 'package:news_ui/article_detail/article_detail_bloc.dart';
import 'package:news_ui/article_detail/article_detail_state.dart';
import 'package:share_plus/share_plus.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleDetailCubit cubit;

  const ArticleDetailScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ArticleDetailCubit, ArticleDetailState>(
        builder: (context, state) => switch (state) {
          ArticleDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          ArticleDetailError(:final message) => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.reload,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          ArticleDetailSuccess(:final article) => _ArticleDetailBody(
            article: article,
            cubit: cubit,
          ),
        },
      ),
    );
  }
}

class _ArticleDetailBody extends StatelessWidget {
  final Article article;
  final ArticleDetailCubit cubit;

  const _ArticleDetailBody({required this.article, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _HeroAppBar(article: article),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ArticleInfoSection(article: article),
              if (article.movies.isNotEmpty)
                _MoviesSection(movies: article.movies, cubit: cubit),
              _ArticleContentSection(content: article.content),
              _ShareSection(article: article),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  final Article article;

  const _HeroAppBar({required this.article});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: article.imageUrl != null ? 260 : 0,
      pinned: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      flexibleSpace: article.imageUrl != null
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: colorScheme.surfaceContainerHighest),
                    errorWidget: (_, _, _) =>
                        Container(color: colorScheme.surfaceContainerHighest),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _ArticleInfoSection extends StatelessWidget {
  final Article article;

  const _ArticleInfoSection({required this.article});

  String get _formattedDate {
    final parsed = DateTime.tryParse(article.publishedAt);
    if (parsed == null) return article.publishedAt;
    return DateFormat.yMMMd(Intl.getCurrentLocale()).format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.source_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                article.source,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _Dot(color: colorScheme.onSurfaceVariant),
              Expanded(
                child: Text(
                  _formattedDate,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            article.summary,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleContentSection extends StatelessWidget {
  final String content;

  const _ArticleContentSection({required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Text(
        content,
        style: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          height: 1.7,
        ),
      ),
    );
  }
}

class _ShareSection extends StatelessWidget {
  final Article article;

  const _ShareSection({required this.article});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: OutlinedButton.icon(
        onPressed: () async {
          final payload =
              '${article.title}\n\n${article.summary}\n\n${article.sourceUrl}';
          await SharePlus.instance.share(ShareParams(text: payload));
        },
        icon: const Icon(Icons.share_rounded),
        label: Text(l10n?.articleDetailShare ?? 'Share article'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
        ),
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

/// The movies the article quotes (F5.8): open the movie, "Quero ver" in one
/// tap, or pick shelves. The article leads back to the movies.
class _MoviesSection extends StatelessWidget {
  final List<ArticleMovie> movies;
  final ArticleDetailCubit cubit;

  const _MoviesSection({required this.movies, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Semantics(
              header: true,
              child: Text(
                l10n?.newsMoviesTitle ?? '',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _MovieCard(movie: movies[index], cubit: cubit),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final ArticleMovie movie;
  final ArticleDetailCubit cubit;

  const _MovieCard({required this.movie, required this.cubit});

  Future<void> _addToWatchlist(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final added = await cubit.addToWatchlist(movie);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          (added
                  ? l10n?.newsAddedToWatchlist(movie.title)
                  : l10n?.newsWantToWatchError) ??
              '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final poster = movie.posterPath;
    final year = movie.year;

    return SizedBox(
      width: 280,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            InkWell(
              onTap: () => context.router.push(
                MovieDetailRoute(
                  movieId: movie.movieId,
                  movieTitle: movie.title,
                ),
              ),
              child: SizedBox(
                width: 84,
                height: 128,
                child: poster == null
                    ? ColoredBox(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.movie),
                      )
                    : CachedNetworkImage(
                        imageUrl: TmdbImageUrl.buildPosterSmall(poster),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      year == null ? movie.title : '${movie.title} ($year)',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (movie.watched)
                      Text(
                        l10n?.newsWatched ?? '',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: movie.inQueroVer
                            ? null
                            : () => _addToWatchlist(context),
                        icon: Icon(
                          movie.inQueroVer ? Icons.check : Icons.bookmark_add,
                          size: 18,
                        ),
                        label: Text(
                          (movie.inQueroVer
                                  ? l10n?.newsInWantToWatch
                                  : l10n?.newsWantToWatch) ??
                              '',
                        ),
                      ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => context.router.root.push(
                        AddToShelvesRoute(
                          movieId: movie.movieId,
                          movieTitle: movie.title,
                        ),
                      ),
                      icon: const Icon(Icons.playlist_add, size: 18),
                      label: Text(l10n?.newsAddToShelf ?? ''),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
