import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:news/news.dart';
import 'package:news_ui/article_detail/article_detail_router.dart';
import 'package:news_ui/news_list/news_list_bloc.dart';
import 'package:news_ui/news_list/news_list_state.dart';

class NewsListScreen extends StatelessWidget {
  final NewsListCubit cubit;

  /// Shows the newest article as a large card on top (the Notícias tab).
  final bool highlightFirst;

  const NewsListScreen({
    super.key,
    required this.cubit,
    this.highlightFirst = false,
  });

  Future<void> _open(BuildContext context, Article article) async {
    cubit.markRead(article.id);
    await context.router.push(
      ArticleDetailRoute(articleId: article.id, articleTitle: article.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<NewsListCubit, NewsListState>(
      bloc: cubit,
      builder: (context, state) {
        final filters = state is NewsListSuccess
            ? state
            : const NewsListSuccess();
        return Column(
          children: [
            if (filters.sources.length > 1)
              _SourceFilter(
                sources: filters.sources,
                selected: filters.selectedSource,
                onSelected: cubit.selectSource,
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => cubit.refresh(),
                child: PagingListener(
                  controller: cubit.pagingController,
                  builder: (context, pagingState, fetchNextPage) =>
                      PagedListView<int, Article>(
                        state: pagingState,
                        fetchNextPage: fetchNextPage,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        builderDelegate: PagedChildBuilderDelegate<Article>(
                          itemBuilder: (context, article, index) =>
                              highlightFirst && index == 0
                              ? _FeaturedArticle(
                                  article: article,
                                  read: filters.readIds.contains(article.id),
                                  onTap: () => _open(context, article),
                                )
                              : _ArticleTile(
                                  article: article,
                                  read: filters.readIds.contains(article.id),
                                  onTap: () => _open(context, article),
                                ),
                          firstPageProgressIndicatorBuilder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                          firstPageErrorIndicatorBuilder: (_) =>
                              MuuvieEmptyState(
                                title: l10n?.emptyStateErrorTitle ?? '',
                                message: l10n?.emptyStateErrorMessage ?? '',
                                action: fetchNextPage,
                                actionLabel: l10n?.emptyStateRetry ?? '',
                              ),
                          noItemsFoundIndicatorBuilder: (_) => MuuvieEmptyState(
                            title: l10n?.emptyStateNoItemsTitle ?? '',
                            message: l10n?.emptyStateNoItemsMessage ?? '',
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatDate(String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  return DateFormat.yMMMd(Intl.getCurrentLocale()).format(parsed);
}

class _SourceFilter extends StatelessWidget {
  final List<String> sources;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _SourceFilter({
    required this.sources,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          for (final source in [null, ...sources])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(source ?? l10n?.newsAllSources ?? ''),
                selected: source == selected,
                onSelected: (_) => onSelected(source),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedArticle extends StatelessWidget {
  final Article article;
  final bool read;
  final VoidCallback onTap;

  const _FeaturedArticle({
    required this.article,
    required this.read,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final image = article.imageUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (image != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) =>
                        ColoredBox(color: colorScheme.surfaceContainerHighest),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: read
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _Meta(article: article, read: read),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final Article article;
  final bool read;
  final VoidCallback onTap;

  const _ArticleTile({
    required this.article,
    required this.read,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final image = article.imageUrl;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 64,
                height: 64,
                child: image == null
                    ? ColoredBox(color: colorScheme.tertiaryContainer)
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) =>
                            ColoredBox(color: colorScheme.tertiaryContainer),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: read ? FontWeight.normal : FontWeight.w600,
                      color: read
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Meta(article: article, read: read),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Source, date and the "lido" mark. The mark is text, not only a color.
class _Meta extends StatelessWidget {
  final Article article;
  final bool read;

  const _Meta({required this.article, required this.read});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    return Row(
      children: [
        Flexible(
          child: Text(
            '${article.source} · ${_formatDate(article.publishedAt)}',
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (read) ...[
          const SizedBox(width: 6),
          Icon(Icons.done_all, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 2),
          Text(l10n?.newsRead ?? '', style: style),
        ],
      ],
    );
  }
}
