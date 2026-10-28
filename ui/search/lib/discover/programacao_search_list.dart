import 'package:auto_route/auto_route.dart';
import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:cineclubes_ui/widgets/cineclube_card.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:maratonas_ui/widgets/maratona_card.dart';

/// What a Programação search tab finds.
enum ProgramacaoKind { cineclubes, maratonas }

/// The CineClubes and Maratonas tabs of the Catálogo search (F14.2): by
/// title, finished ones included.
class ProgramacaoSearchList extends StatefulWidget {
  final ProgramacaoKind kind;
  final String query;

  const ProgramacaoSearchList({
    super.key,
    required this.kind,
    required this.query,
  });

  @override
  State<ProgramacaoSearchList> createState() => _ProgramacaoSearchListState();
}

class _ProgramacaoSearchListState extends State<ProgramacaoSearchList> {
  bool _hasNext = true;

  late final PagingController<int, Object> _pagingController = PagingController(
    getNextPageKey: (state) => _hasNext ? state.nextIntPageKey : null,
    fetchPage: _fetchPage,
  );

  Future<List<Object>> _fetchPage(int page) async {
    final Result<Object> result = switch (widget.kind) {
      ProgramacaoKind.cineclubes => await GetIt.I<GetCineClubes>()(
        GetCineClubesParams(
          filter: CineClubeFilter(query: widget.query, includeFinished: true),
          page: page,
        ),
      ),
      ProgramacaoKind.maratonas => await GetIt.I<GetMaratonas>()(
        GetMaratonasParams(
          filter: MaratonaFilter(query: widget.query, includeFinished: true),
          page: page,
        ),
      ),
    };
    switch (result) {
      case Success(data: final CineClubePage data):
        _hasNext = data.hasNext;
        return data.cineclubes;
      case Success(data: final MaratonaPage data):
        _hasNext = data.hasNext;
        return data.maratonas;
      case Failure(:final error):
        throw Exception(error.message);
      case Success():
        return const [];
    }
  }

  @override
  void didUpdateWidget(ProgramacaoSearchList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _hasNext = true;
      _pagingController.refresh();
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

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => PagedListView<int, Object>(
        state: state,
        fetchNextPage: fetchNextPage,
        padding: const EdgeInsets.symmetric(vertical: 8),
        builderDelegate: PagedChildBuilderDelegate<Object>(
          itemBuilder: (context, item, index) => switch (item) {
            CineClubeSummary() => CineClubeCard(
              cineclube: item,
              onTap: () => context.router.push(
                CineClubeDetailRoute(slug: item.slug, title: item.title),
              ),
            ),
            MaratonaSummary() => MaratonaCard(
              maratona: item,
              onTap: () => context.router.push(
                MaratonaDetailRoute(slug: item.slug, title: item.title),
              ),
            ),
            _ => const SizedBox.shrink(),
          },
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
            message: l10n?.noResults ?? '',
          ),
        ),
      ),
    );
  }
}
