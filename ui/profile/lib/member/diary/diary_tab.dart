import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:watch_logs/watch_logs.dart';
import 'package:watch_logs_ui/widgets/watch_log_tile.dart';

/// The Registros tab (F5.2): every session the viewer can see, newest first,
/// each under the movie it belongs to.
class DiaryTab extends StatefulWidget {
  /// The owner, or `me` for the current user.
  final String userId;

  /// Also called by pull to refresh, e.g. to reload the profile counters.
  final Future<void> Function()? onRefresh;

  const DiaryTab({super.key, required this.userId, this.onRefresh});

  @override
  State<DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends State<DiaryTab> {
  final GetUserDiary _getUserDiary = GetIt.I<GetUserDiary>();
  bool _hasNext = true;

  late final PagingController<int, DiaryEntry> _pagingController =
      PagingController(
        getNextPageKey: (state) => _hasNext ? state.nextIntPageKey : null,
        fetchPage: _fetchPage,
      );

  Future<List<DiaryEntry>> _fetchPage(int page) async {
    final result = await _getUserDiary(
      GetUserDiaryParams(userId: widget.userId, page: page),
    );
    switch (result) {
      case Success(:final data):
        _hasNext = data.hasNext;
        return data.entries;
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
    final isOwn = widget.userId == 'me';

    return RefreshIndicator(
      onRefresh: () async {
        _hasNext = true;
        _pagingController.refresh();
        await widget.onRefresh?.call();
      },
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, DiaryEntry>(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: const EdgeInsets.only(bottom: 24),
              builderDelegate: PagedChildBuilderDelegate<DiaryEntry>(
                itemBuilder: (context, entry, index) =>
                    _DiaryItem(entry: entry),
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
                  message: isOwn
                      ? l10n?.diaryEmptyOwn ?? ''
                      : l10n?.diaryEmptyOther ?? '',
                ),
              ),
            ),
      ),
    );
  }
}

class _DiaryItem extends StatelessWidget {
  final DiaryEntry entry;

  const _DiaryItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final poster = entry.posterPath;
    final year = entry.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => context.router.push(
            MovieDetailRoute(movieId: entry.movieId, movieTitle: entry.title),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: MuuvieRadius.smallAll,
                  child: SizedBox(
                    width: 32,
                    height: 48,
                    child: poster == null
                        ? ColoredBox(color: colorScheme.surfaceContainerHighest)
                        : CachedNetworkImage(
                            imageUrl: TmdbImageUrl.buildPosterSmall(poster),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    year == null ? entry.title : '${entry.title} ($year)',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        WatchLogTile(log: entry.log),
      ],
    );
  }
}
