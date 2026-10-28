import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shelves/shelves.dart';

import 'package:profile_ui/member/highlights/highlights_tab.dart';
import 'package:profile_ui/profile_router.dart';

/// "Estantes salvas" (F14.5): shelves of other people I saved, the latest
/// first, opened from my Estantes tab.
@RoutePage()
class SavedShelvesPage extends StatefulWidget {
  const SavedShelvesPage({super.key});

  @override
  State<SavedShelvesPage> createState() => _SavedShelvesPageState();
}

class _SavedShelvesPageState extends State<SavedShelvesPage> {
  final _getShelves = GetIt.I<GetSavedShelves>();
  final List<Shelf> _shelves = [];
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
    final result = await _getShelves(_page + 1);
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

  Future<void> _reload() async {
    setState(() {
      _shelves.clear();
      _page = 0;
      _hasNext = true;
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _open(Shelf shelf) async {
    await context.router.push(
      ShelfDetailRoute(
        shelfId: shelf.id,
        shelfName: shelf.name,
        shelfColor: shelf.color,
      ),
    );
    // The shelf may have been unsaved inside.
    if (mounted) await _reload();
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
              action: _reload,
              actionLabel: l10n?.emptyStateRetry ?? '',
            )
          : MuuvieEmptyState(
              illustration: MuuvieIllustration.movies,
              title: l10n?.savedShelvesTitle ?? '',
              message: l10n?.savedShelvesEmpty ?? '',
            );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 400) _loadMore();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _reload,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _shelves.length + (_loading ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == _shelves.length) {
              return const Center(child: MuuvieActivityIndicator());
            }
            final shelf = _shelves[index];
            final owner = shelf.ownerName;
            return HighlightCollectionCard(
              title: shelf.name,
              subtitle: [
                if (owner != null) l10n?.shelfByOwner(owner) ?? owner,
                l10n?.shelfMoviesCount(shelf.totalMovies) ?? '',
              ].join(' · '),
              posterPaths: shelf.posterPaths,
              onTap: () => _open(shelf),
            );
          },
        ),
      ),
    );
  }
}
