import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:locadoras_ui/locadora_form/locadora_form_bottom_sheet.dart';
import 'package:locadoras_ui/locadoras_list/locadoras_list_bloc.dart';
import 'package:locadoras_ui/locadoras_list/locadoras_list_state.dart';
import 'package:locadoras_ui/widgets/confirm_locadora_delete.dart';
import 'package:locadoras_ui/widgets/locadora_count_chip.dart';
import 'package:locadoras_ui/widgets/locadora_poster.dart';

enum _LocadoraAction { edit, pin, delete }

class LocadorasListScreen extends StatelessWidget {
  final LocadorasListCubit cubit;
  final ValueChanged<Locadora> onOpenLocadora;

  /// Called with a locadora just created, to go fill it with shelves.
  final ValueChanged<Locadora> onCreated;

  const LocadorasListScreen({
    super.key,
    required this.cubit,
    required this.onOpenLocadora,
    required this.onCreated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<LocadorasListCubit, LocadorasListState>(
        builder: (context, state) => switch (state) {
          LocadorasListLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          LocadorasListError(:final message) => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          LocadorasListSuccess(:final locadoras, :final isReordering) =>
            Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: !cubit.isOwnList || isReordering
                  ? null
                  : FloatingActionButton(
                      tooltip: l10n?.locadoraNew,
                      onPressed: () => _create(context),
                      child: const Icon(Icons.add),
                    ),
              body: locadoras.isEmpty
                  ? MuuvieEmptyState(
                      title: l10n?.locadoraEmptyTitle ?? '',
                      message:
                          (cubit.isOwnList
                              ? l10n?.locadoraEmptyMessage
                              : l10n?.locadoraEmptyOtherMessage) ??
                          '',
                    )
                  : Column(
                      children: [
                        if (cubit.isOwnList && locadoras.length > 1)
                          _Toolbar(isReordering: isReordering, cubit: cubit),
                        Expanded(
                          child: isReordering
                              ? _ReorderList(locadoras: locadoras, cubit: cubit)
                              : RefreshIndicator(
                                  onRefresh: cubit.load,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      88,
                                    ),
                                    itemCount: locadoras.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 16),
                                    itemBuilder: (context, index) =>
                                        _LocadoraCard(
                                          locadora: locadoras[index],
                                          onTap: () =>
                                              onOpenLocadora(locadoras[index]),
                                          onAction: cubit.isOwnList
                                              ? (action) => _onAction(
                                                  context,
                                                  locadoras[index],
                                                  action,
                                                )
                                              : null,
                                        ),
                                  ),
                                ),
                        ),
                      ],
                    ),
            ),
        },
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final created = await LocadoraFormBottomSheet.show(
      context,
      onSave: (draft) => cubit.saveLocadora(draft: draft),
    );
    if (created != null) onCreated(created);
  }

  Future<void> _onAction(
    BuildContext context,
    Locadora locadora,
    _LocadoraAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    var succeeded = true;
    switch (action) {
      case _LocadoraAction.edit:
        await LocadoraFormBottomSheet.show(
          context,
          locadora: locadora,
          onSave: (draft) =>
              cubit.saveLocadora(locadoraId: locadora.id, draft: draft),
        );
      case _LocadoraAction.pin:
        succeeded = await cubit.togglePin(locadora);
      case _LocadoraAction.delete:
        final confirmed = await confirmLocadoraDelete(context, locadora);
        if (confirmed) succeeded = await cubit.deleteLocadora(locadora);
    }
    if (!succeeded) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n?.shelfActionError ?? '')),
      );
    }
  }
}

class _Toolbar extends StatelessWidget {
  final bool isReordering;
  final LocadorasListCubit cubit;

  const _Toolbar({required this.isReordering, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: isReordering
            ? TextButton(
                onPressed: cubit.finishReordering,
                child: Text(l10n?.shelfReorderDone ?? ''),
              )
            : TextButton.icon(
                onPressed: cubit.startReordering,
                icon: const Icon(Icons.swap_vert),
                label: Text(l10n?.locadoraReorder ?? ''),
              ),
      ),
    );
  }
}

class _ReorderList extends StatelessWidget {
  final List<Locadora> locadoras;
  final LocadorasListCubit cubit;

  const _ReorderList({required this.locadoras, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: locadoras.length,
      onReorderItem: cubit.moveLocadora,
      itemBuilder: (context, index) {
        final locadora = locadoras[index];
        return ListTile(
          key: ValueKey(locadora.id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: const Icon(Icons.storefront_outlined),
          title: Text(locadora.name),
          subtitle: locadora.pinned ? Text(l10n?.shelfPinned ?? '') : null,
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        );
      },
    );
  }
}

/// A locadora on the profile: name, counters and the first posters.
class _LocadoraCard extends StatelessWidget {
  final Locadora locadora;
  final VoidCallback onTap;

  /// Owner actions; null on someone else's profile.
  final ValueChanged<_LocadoraAction>? onAction;

  const _LocadoraCard({
    required this.locadora,
    required this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final description = locadora.description;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: MuuvieRadius.largeAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (locadora.pinned) ...[
                    Icon(
                      Icons.push_pin,
                      size: 18,
                      semanticLabel: l10n?.shelfPinned,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      locadora.name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onAction != null)
                    PopupMenuButton<_LocadoraAction>(
                      onSelected: onAction,
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: _LocadoraAction.edit,
                          child: Text(l10n?.locadoraEdit ?? ''),
                        ),
                        PopupMenuItem(
                          value: _LocadoraAction.pin,
                          child: Text(
                            (locadora.pinned
                                    ? l10n?.shelfUnpin
                                    : l10n?.shelfPin) ??
                                '',
                          ),
                        ),
                        PopupMenuItem(
                          value: _LocadoraAction.delete,
                          child: Text(l10n?.locadoraDelete ?? ''),
                        ),
                      ],
                    ),
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  LocadoraCountChip(
                    label:
                        l10n?.locadoraShelvesCount(locadora.totalShelves) ?? '',
                  ),
                  LocadoraCountChip(
                    label:
                        l10n?.shelfWatchedOfTotal(
                          locadora.totalWatched,
                          locadora.totalMovies,
                        ) ??
                        '',
                  ),
                  MuuvieVisibilityChip(visibility: locadora.visibility),
                ],
              ),
              if (locadora.posterPaths.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: LocadoraPoster.height,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: locadora.posterPaths.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, index) =>
                        LocadoraPoster(posterPath: locadora.posterPaths[index]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
