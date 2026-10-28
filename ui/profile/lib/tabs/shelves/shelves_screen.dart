import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:profile_ui/tabs/shelves/shelf_form_bottom_sheet.dart';
import 'package:profile_ui/tabs/shelves/shelves_bloc.dart';
import 'package:profile_ui/tabs/shelves/shelves_state.dart';

enum _ShelfAction { edit, pin, delete }

class ShelvesScreen extends StatelessWidget {
  final ShelvesCubit cubit;
  final ValueChanged<Shelf> onOpenShelf;
  final ValueChanged<Shelf> onAddMovies;

  /// Opens the shelves of other people I saved (F14.5); null hides it.
  final VoidCallback? onOpenSaved;

  /// Shelves of another user: no creation, reordering or card actions.
  final bool readOnly;

  const ShelvesScreen({
    super.key,
    required this.cubit,
    required this.onOpenShelf,
    required this.onAddMovies,
    this.onOpenSaved,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ShelvesCubit, ShelvesState>(
        builder: (context, state) => switch (state) {
          ShelvesLoading() => const Center(child: CircularProgressIndicator()),
          ShelvesError(:final message) => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          ShelvesSuccess(:final shelves, :final isReordering) => Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: isReordering || readOnly
                ? null
                : FloatingActionButton(
                    tooltip: l10n?.shelfNew,
                    onPressed: () => ShelfFormBottomSheet.show(
                      context,
                      onSave: (draft) => cubit.saveShelf(draft: draft),
                    ),
                    child: const Icon(Icons.add),
                  ),
            body: Column(
              children: [
                if (!readOnly)
                  _Toolbar(
                    isReordering: isReordering,
                    cubit: cubit,
                    onOpenSaved: onOpenSaved,
                  ),
                Expanded(
                  child: isReordering
                      ? _ReorderList(shelves: shelves, cubit: cubit)
                      : RefreshIndicator(
                          onRefresh: cubit.load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                            itemCount: shelves.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) => _ShelfCard(
                              shelf: shelves[index],
                              onTap: () => onOpenShelf(shelves[index]),
                              onAddMovies: readOnly
                                  ? null
                                  : () => onAddMovies(shelves[index]),
                              onAction: readOnly
                                  ? null
                                  : (action) => _onAction(
                                      context,
                                      shelves[index],
                                      action,
                                    ),
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

  Future<void> _onAction(
    BuildContext context,
    Shelf shelf,
    _ShelfAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    var succeeded = true;
    switch (action) {
      case _ShelfAction.edit:
        await ShelfFormBottomSheet.show(
          context,
          shelf: shelf,
          onSave: (draft) => cubit.saveShelf(shelfId: shelf.id, draft: draft),
        );
      case _ShelfAction.pin:
        succeeded = await cubit.togglePin(shelf);
      case _ShelfAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n?.shelfDeleteConfirmTitle(shelf.name) ?? ''),
            content: Text(l10n?.shelfDeleteConfirmMessage ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n?.cancel ?? ''),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n?.delete ?? ''),
              ),
            ],
          ),
        );
        if (confirmed ?? false) succeeded = await cubit.deleteShelf(shelf);
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
  final ShelvesCubit cubit;
  final VoidCallback? onOpenSaved;

  const _Toolbar({
    required this.isReordering,
    required this.cubit,
    this.onOpenSaved,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onOpenSaved = this.onOpenSaved;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: isReordering
            ? [
                TextButton(
                  onPressed: cubit.finishReordering,
                  child: Text(l10n?.shelfReorderDone ?? ''),
                ),
              ]
            : [
                if (onOpenSaved != null)
                  TextButton.icon(
                    onPressed: onOpenSaved,
                    icon: const Icon(Icons.bookmark_border),
                    label: Text(l10n?.savedShelvesAction ?? ''),
                  ),
                TextButton.icon(
                  onPressed: cubit.startReordering,
                  icon: const Icon(Icons.swap_vert),
                  label: Text(l10n?.shelfReorder ?? ''),
                ),
              ],
      ),
    );
  }
}

class _ReorderList extends StatelessWidget {
  final List<Shelf> shelves;
  final ShelvesCubit cubit;

  const _ReorderList({required this.shelves, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: shelves.length,
      onReorderItem: cubit.moveShelf,
      itemBuilder: (context, index) {
        final shelf = shelves[index];
        return ListTile(
          key: ValueKey(shelf.id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: CircleAvatar(
            radius: 8,
            backgroundColor:
                MuuvieColorPicker.fromHex(shelf.color) ??
                colorScheme.outlineVariant,
          ),
          title: Text(
            l10n?.shelfName(shelf.systemType, shelf.name) ?? shelf.name,
          ),
          subtitle: shelf.pinned ? Text(l10n?.shelfPinned ?? '') : null,
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        );
      },
    );
  }
}

class _ShelfCard extends StatelessWidget {
  final Shelf shelf;
  final VoidCallback onTap;

  /// Null on shelves of other users, like [onAction].
  final VoidCallback? onAddMovies;
  final ValueChanged<_ShelfAction>? onAction;

  const _ShelfCard({
    required this.shelf,
    required this.onTap,
    this.onAddMovies,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final shelfColor = MuuvieColorPicker.fromHex(shelf.color);
    final accentColor = shelfColor ?? colorScheme.secondary;
    final name = l10n?.shelfName(shelf.systemType, shelf.name) ?? shelf.name;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: MuuvieRadius.largeAll,
        side: shelfColor != null
            ? BorderSide(color: shelfColor, width: 2)
            : BorderSide(color: colorScheme.outlineVariant),
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
                  if (shelf.pinned) ...[
                    Icon(
                      Icons.push_pin,
                      size: 18,
                      semanticLabel: l10n?.shelfPinned,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onAddMovies != null)
                    IconButton.filled(
                      tooltip: l10n?.shelfAddMovies,
                      style: IconButton.styleFrom(backgroundColor: accentColor),
                      icon: Icon(
                        Icons.add,
                        color: accentColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                      onPressed: onAddMovies,
                    ),
                  if (onAction != null)
                    PopupMenuButton<_ShelfAction>(
                      onSelected: onAction,
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: _ShelfAction.edit,
                          child: Text(l10n?.shelfEdit ?? ''),
                        ),
                        PopupMenuItem(
                          value: _ShelfAction.pin,
                          child: Text(
                            (shelf.pinned
                                    ? l10n?.shelfUnpin
                                    : l10n?.shelfPin) ??
                                '',
                          ),
                        ),
                        // System shelves cannot be deleted, so the action is not offered.
                        if (!shelf.isSystem)
                          PopupMenuItem(
                            value: _ShelfAction.delete,
                            child: Text(l10n?.shelfDelete ?? ''),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CountChip(
                    label:
                        l10n?.shelfWatchedOfTotal(
                          shelf.totalWatched,
                          shelf.totalMovies,
                        ) ??
                        '',
                    color: shelfColor,
                  ),
                  MuuvieVisibilityChip(visibility: shelf.visibility),
                ],
              ),
              if (shelf.posterPaths.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: shelf.posterPaths.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: MuuvieRadius.smallAll,
                      child: CachedNetworkImage(
                        imageUrl: TmdbImageUrl.buildPosterMedium(
                          shelf.posterPaths[index],
                        ),
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.movie,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
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

class _CountChip extends StatelessWidget {
  final String label;
  final Color? color;

  const _CountChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MuuvieRadius.pill),
        border: Border.all(color: color ?? colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
