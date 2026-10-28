import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:locadoras_ui/locadora_detail/locadora_detail_bloc.dart';
import 'package:locadoras_ui/locadora_detail/locadora_detail_state.dart';
import 'package:locadoras_ui/widgets/locadora_count_chip.dart';
import 'package:locadoras_ui/widgets/locadora_poster.dart';

class LocadoraDetailScreen extends StatelessWidget {
  final LocadoraDetailCubit cubit;
  final ValueChanged<ShelfMovie> onMovieTap;

  /// Null hides the "open shelf" action.
  final ValueChanged<Shelf>? onOpenShelf;

  /// Opens the owner's profile (F14.6); null keeps the owner line static.
  final ValueChanged<Locadora>? onOpenOwner;
  final ValueChanged<Locadora> onEdit;
  final ValueChanged<Locadora> onDelete;
  final VoidCallback onChooseShelves;
  final ValueChanged<bool> onReorderSaved;

  const LocadoraDetailScreen({
    super.key,
    required this.cubit,
    required this.onMovieTap,
    this.onOpenShelf,
    this.onOpenOwner,
    required this.onEdit,
    required this.onDelete,
    required this.onChooseShelves,
    required this.onReorderSaved,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<LocadoraDetailCubit, LocadoraDetailState>(
        builder: (context, state) => switch (state) {
          LocadoraDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          LocadoraDetailError(:final message) => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          LocadoraDetailSuccess(
            :final locadora,
            :final shelves,
            :final isReordering,
          ) =>
            Scaffold(
              backgroundColor: Colors.transparent,
              body: isReordering
                  ? _ReorderShelves(
                      shelves: shelves,
                      cubit: cubit,
                      onSaved: onReorderSaved,
                    )
                  : RefreshIndicator(
                      onRefresh: cubit.load,
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 32),
                        children: [
                          _Header(
                            locadora: locadora,
                            onEdit: () => onEdit(locadora),
                            onDelete: () => onDelete(locadora),
                            onOpenOwner: onOpenOwner == null || locadora.isSelf
                                ? null
                                : () => onOpenOwner!(locadora),
                          ),
                          if (locadora.isSelf)
                            _OwnerActions(
                              canReorder: shelves.length > 1,
                              onChooseShelves: onChooseShelves,
                              onReorder: cubit.startReordering,
                            ),
                          if (shelves.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                l10n?.locadoraNoShelves ?? '',
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            for (final shelf in shelves)
                              _Corridor(
                                shelf: shelf,
                                onMovieTap: onMovieTap,
                                onOpenShelf: onOpenShelf,
                              ),
                        ],
                      ),
                    ),
            ),
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Locadora locadora;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpenOwner;

  const _Header({
    required this.locadora,
    required this.onEdit,
    required this.onDelete,
    this.onOpenOwner,
  });

  /// The owner line, tappable when the locadora is someone else's (F14.6).
  Widget _ownerLine(BuildContext context, Widget child) {
    final onTap = onOpenOwner;
    if (onTap == null) return child;
    return Semantics(
      button: true,
      hint: AppLocalizations.of(
        context,
      )?.shelfOpenOwnerProfile('@${locadora.ownerUsername}'),
      child: InkWell(
        borderRadius: MuuvieRadius.smallAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final description = locadora.description;
    final avatarUrl = locadora.ownerAvatarUrl;
    final progress = locadora.totalMovies == 0
        ? 0.0
        : locadora.totalWatched / locadora.totalMovies;
    final progressLabel =
        l10n?.locadoraProgress(locadora.totalWatched, locadora.totalMovies) ??
        '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  locadora.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (locadora.isSelf) ...[
                IconButton(
                  tooltip: l10n?.locadoraEdit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: l10n?.locadoraDelete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          _ownerLine(
            context,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: avatarUrl == null
                      ? null
                      : CachedNetworkImageProvider(avatarUrl),
                  child: avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.locadoraByOwner(locadora.ownerUsername) ?? '',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(description, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LocadoraCountChip(
                label: l10n?.locadoraShelvesCount(locadora.totalShelves) ?? '',
              ),
              LocadoraCountChip(
                label: l10n?.locadoraMoviesCount(locadora.totalMovies) ?? '',
              ),
              MuuvieVisibilityChip(visibility: locadora.visibility),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              label: progressLabel,
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(MuuvieRadius.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(progressLabel, style: textTheme.labelMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerActions extends StatelessWidget {
  final bool canReorder;
  final VoidCallback onChooseShelves;
  final VoidCallback onReorder;

  const _OwnerActions({
    required this.canReorder,
    required this.onChooseShelves,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 4,
        children: [
          TextButton.icon(
            onPressed: onChooseShelves,
            icon: const Icon(Icons.library_add_outlined),
            label: Text(l10n?.locadoraChooseShelves ?? ''),
          ),
          if (canReorder)
            TextButton.icon(
              onPressed: onReorder,
              icon: const Icon(Icons.swap_vert),
              label: Text(l10n?.shelfReorder ?? ''),
            ),
        ],
      ),
    );
  }
}

/// A shelf as a video store aisle: its name, then a horizontal row of posters.
class _Corridor extends StatelessWidget {
  final LocadoraShelf shelf;
  final ValueChanged<ShelfMovie> onMovieTap;
  final ValueChanged<Shelf>? onOpenShelf;

  const _Corridor({
    required this.shelf,
    required this.onMovieTap,
    this.onOpenShelf,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final value = shelf.shelf;
    final name = l10n?.shelfName(value.systemType, value.name) ?? value.name;
    final openShelf = onOpenShelf;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color:
                        MuuvieColorPicker.fromHex(value.color) ??
                        colorScheme.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  l10n?.shelfWatchedOfTotal(
                        value.totalWatched,
                        value.totalMovies,
                      ) ??
                      '',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (openShelf != null)
                  IconButton(
                    tooltip: l10n?.locadoraOpenShelf,
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => openShelf(value),
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
          ),
          if (shelf.movies.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n?.locadoraShelfEmpty ?? '',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            SizedBox(
              height: LocadoraPoster.height,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: shelf.movies.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final movie = shelf.movies[index];
                  return Semantics(
                    button: true,
                    label: movie.title,
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: MuuvieRadius.smallAll,
                      onTap: () => onMovieTap(movie),
                      child: LocadoraPoster(posterPath: movie.posterPath),
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

class _ReorderShelves extends StatelessWidget {
  final List<LocadoraShelf> shelves;
  final LocadoraDetailCubit cubit;
  final ValueChanged<bool> onSaved;

  const _ReorderShelves({
    required this.shelves,
    required this.cubit,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async => onSaved(await cubit.finishReordering()),
              child: Text(l10n?.shelfReorderDone ?? ''),
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: shelves.length,
            onReorderItem: cubit.moveShelf,
            itemBuilder: (context, index) {
              final shelf = shelves[index].shelf;
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
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
