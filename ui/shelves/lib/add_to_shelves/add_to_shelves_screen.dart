import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shelves_ui/add_to_shelves/add_to_shelves_bloc.dart';
import 'package:shelves_ui/add_to_shelves/add_to_shelves_state.dart';

class AddToShelvesScreen extends StatelessWidget {
  final AddToShelvesCubit cubit;
  final String movieTitle;

  /// Saves and closes; returns false when saving failed.
  final Future<bool> Function() onSave;

  const AddToShelvesScreen({
    super.key,
    required this.cubit,
    required this.movieTitle,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MuuvieModalScreen(
      title: l10n?.addToShelvesTitle ?? '',
      body: BlocProvider.value(
        value: cubit,
        child: BlocBuilder<AddToShelvesCubit, AddToShelvesState>(
          builder: (context, state) => switch (state) {
            AddToShelvesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            AddToShelvesError(:final message) => MuuvieEmptyState(
              title: l10n?.emptyStateErrorTitle ?? '',
              message: message,
              action: cubit.load,
              actionLabel: l10n?.emptyStateRetry ?? '',
            ),
            AddToShelvesSuccess() => _Content(
              state: state,
              cubit: cubit,
              movieTitle: movieTitle,
              onSave: onSave,
            ),
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final AddToShelvesSuccess state;
  final AddToShelvesCubit cubit;
  final String movieTitle;
  final Future<bool> Function() onSave;

  const _Content({
    required this.state,
    required this.cubit,
    required this.movieTitle,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            movieTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          // The modal body is a ColoredBox; the tiles need their own Material
          // to paint ink.
          child: Material(
            type: MaterialType.transparency,
            child: ListView(
              children: [
                for (final shelf in state.shelves)
                  CheckboxListTile(
                    value:
                        state.currentShelfIds.contains(shelf.id) ||
                        state.selectedShelfIds.contains(shelf.id),
                    // Already there: shown checked, managed from the shelf itself.
                    onChanged:
                        state.currentShelfIds.contains(shelf.id) ||
                            state.isSaving
                        ? null
                        : (_) => cubit.toggle(shelf.id),
                    secondary: CircleAvatar(
                      radius: 8,
                      backgroundColor:
                          MuuvieColorPicker.fromHex(shelf.color) ??
                          colorScheme.outlineVariant,
                    ),
                    title: Text(
                      l10n?.shelfName(shelf.systemType, shelf.name) ??
                          shelf.name,
                    ),
                    subtitle: Text(
                      l10n?.shelfWatchedOfTotal(
                            shelf.totalWatched,
                            shelf.totalMovies,
                          ) ??
                          '',
                    ),
                  ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: MuuvieButton(
                onPressed: state.selectedShelfIds.isEmpty || state.isSaving
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final message = l10n?.shelfActionError ?? '';
                        if (!await onSave()) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                child: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n?.addToShelvesSave ?? ''),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
