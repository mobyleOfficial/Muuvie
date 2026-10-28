import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:locadoras_ui/pick_shelves/pick_shelves_bloc.dart';
import 'package:locadoras_ui/pick_shelves/pick_shelves_state.dart';

class PickShelvesScreen extends StatelessWidget {
  final PickShelvesCubit cubit;
  final VoidCallback onSave;

  const PickShelvesScreen({
    super.key,
    required this.cubit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return MuuvieModalScreen(
      title: l10n?.locadoraPickShelvesTitle ?? '',
      body: BlocProvider.value(
        value: cubit,
        child: BlocBuilder<PickShelvesCubit, PickShelvesState>(
          builder: (context, state) => switch (state) {
            PickShelvesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PickShelvesError(:final message) => MuuvieEmptyState(
              title: l10n?.emptyStateErrorTitle ?? '',
              message: message,
              action: cubit.load,
              actionLabel: l10n?.emptyStateRetry ?? '',
            ),
            PickShelvesSuccess(:final shelves, :final selectedIds) =>
              shelves.isEmpty
                  ? MuuvieEmptyState(
                      title: l10n?.emptyStateNoItemsTitle ?? '',
                      message: l10n?.locadoraPickShelvesEmpty ?? '',
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              for (final shelf in shelves)
                                CheckboxListTile(
                                  value: selectedIds.contains(shelf.id),
                                  onChanged: (_) => cubit.toggle(shelf.id),
                                  secondary: CircleAvatar(
                                    radius: 8,
                                    backgroundColor:
                                        MuuvieColorPicker.fromHex(
                                          shelf.color,
                                        ) ??
                                        colorScheme.outlineVariant,
                                  ),
                                  title: Text(
                                    l10n?.shelfName(
                                          shelf.systemType,
                                          shelf.name,
                                        ) ??
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
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: MuuvieButton(
                                onPressed: onSave,
                                child: Text(l10n?.shelfSave ?? ''),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          },
        ),
      ),
    );
  }
}
