import 'dart:async';

import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/widgets/maratona_card.dart';
import 'package:programacao/maratonas/maratona_list_bloc.dart';

/// The Maratonas tab of Programação (F7.2): search, filters and the list.
/// With [participating], only the maratonas the user joined.
class MaratonaList extends StatefulWidget {
  final bool participating;
  final ValueChanged<MaratonaSummary> onOpen;
  final VoidCallback onCreate;

  const MaratonaList({
    super.key,
    required this.participating,
    required this.onOpen,
    required this.onCreate,
  });

  @override
  State<MaratonaList> createState() => MaratonaListViewState();
}

class MaratonaListViewState extends State<MaratonaList> {
  late final MaratonaListCubit _cubit = MaratonaListCubit(
    getMaratonas: GetIt.I<GetMaratonas>(),
  );
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cubit.setFilter(_withParticipating(const MaratonaFilter()));
  }

  @override
  void didUpdateWidget(MaratonaList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.participating != widget.participating) {
      _cubit.setFilter(_withParticipating(_cubit.state.filter));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cubit.close();
    super.dispose();
  }

  /// "Criadas por mim" needs an account: asks to log in first.
  Future<void> _setMine(bool mine) async {
    if (mine && !await AuthGate.check(context)) return;
    if (!mounted) return;
    _cubit.setFilter(_cubit.state.filter.copyWith(mine: mine));
  }

  /// Reloads, e.g. after creating a maratona.
  Future<void> reload() => _cubit.load();

  MaratonaFilter _withParticipating(MaratonaFilter filter) =>
      widget.participating
      ? filter.copyWith(participant: 'me')
      : filter.copyWith(clearParticipant: true);

  void _search(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _cubit.setFilter(_cubit.state.filter.copyWith(query: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<MaratonaListCubit, MaratonaListState>(
      bloc: _cubit,
      builder: (context, state) {
        final filter = state.filter;
        return Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 400) _cubit.loadMore();
                return false;
              },
              child: RefreshIndicator(
                onRefresh: _cubit.load,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: TextField(
                          onChanged: _search,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: l10n?.maratonaSearchHint,
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Row(
                          children: [
                            _Filter(
                              label: l10n?.maratonaFilterCurated ?? '',
                              selected: filter.trusted,
                              onSelected: (value) => _cubit.setFilter(
                                filter.copyWith(trusted: value),
                              ),
                            ),
                            _Filter(
                              label: l10n?.maratonaFilterOpen ?? '',
                              selected: filter.open,
                              onSelected: (value) => _cubit.setFilter(
                                filter.copyWith(open: value),
                              ),
                            ),
                            _Filter(
                              label: l10n?.maratonaFilterFinished ?? '',
                              selected: filter.includeFinished,
                              onSelected: (value) => _cubit.setFilter(
                                filter.copyWith(includeFinished: value),
                              ),
                            ),
                            _Filter(
                              label: l10n?.maratonaFilterMine ?? '',
                              selected: filter.mine,
                              onSelected: _setMine,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state.loading && state.maratonas.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: MuuvieActivityIndicator()),
                      )
                    else if (state.error != null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: MuuvieEmptyState(
                          illustration: MuuvieIllustration.error,
                          title: l10n?.emptyStateErrorTitle ?? '',
                          message: l10n?.emptyStateErrorMessage ?? '',
                          action: _cubit.load,
                          actionLabel: l10n?.emptyStateRetry ?? '',
                        ),
                      )
                    else if (state.maratonas.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: MuuvieEmptyState(
                          illustration: MuuvieIllustration.maratona,
                          title: l10n?.maratonaListEmptyTitle ?? '',
                          message: widget.participating
                              ? l10n?.maratonaParticipatingEmpty ?? ''
                              : l10n?.maratonaListEmptyMessage ?? '',
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: state.maratonas.length,
                        itemBuilder: (context, index) => MaratonaCard(
                          maratona: state.maratonas[index],
                          onTap: () => widget.onOpen(state.maratonas[index]),
                        ),
                      ),
                    if (state.loadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: MuuvieActivityIndicator()),
                        ),
                      ),
                    // Room for the create button over the last card.
                    const SliverToBoxAdapter(child: SizedBox(height: 88)),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                heroTag: 'maratona-create',
                onPressed: widget.onCreate,
                icon: const Icon(Icons.add),
                label: Text(l10n?.maratonaCreate ?? ''),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Filter extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _Filter({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    ),
  );
}
