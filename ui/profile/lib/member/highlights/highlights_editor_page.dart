import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:profile/profile.dart';
import 'package:shelves/shelves.dart';

import 'package:profile_ui/member/highlights/highlights_editor_bloc.dart';
import 'package:profile_ui/member/highlights/top_movies_picker.dart';
import 'package:profile_ui/tabs/shelves/shelf_picker_bottom_sheet.dart';

/// Edits the Destaques of the own profile (F5.4): choose what each section
/// shows, turn it on or off and drag to reorder. Pops `true` once saved.
@RoutePage()
class HighlightsEditorPage extends StatefulWidget {
  const HighlightsEditorPage({super.key});

  @override
  State<HighlightsEditorPage> createState() => _HighlightsEditorPageState();
}

class _HighlightsEditorPageState extends State<HighlightsEditorPage> {
  late final HighlightsEditorCubit _cubit = HighlightsEditorCubit(
    getHighlights: GetIt.I<GetProfileHighlights>(),
    saveHighlights: GetIt.I<SaveProfileHighlights>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (await _cubit.save()) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n?.highlightsSaveError ?? '')),
      );
    }
  }

  Future<void> _configure(ProfileHighlight slot) async {
    final l10n = AppLocalizations.of(context);
    switch (slot.type) {
      case HighlightType.top4:
        final movies = await TopMoviesPicker.show(context, slot.movies);
        if (movies != null) _cubit.setTopMovies(movies);
      case HighlightType.shelf:
        final getUserShelves = GetIt.I<GetUserShelves>();
        final shelf = await ShelfPickerBottomSheet.show(
          context,
          title: l10n?.highlightTitle(HighlightType.shelf.wireValue),
          loadShelves: () => getUserShelves(const GetUserShelvesParams()),
        );
        if (shelf != null) _cubit.setShelf(shelf);
      case HighlightType.locadora:
        final locadora = await _pickLocadora();
        if (locadora != null) _cubit.setLocadora(locadora);
      case HighlightType.soundtrack:
        final url = await _askSoundtrack(slot.soundtrackUrl);
        if (url != null) _cubit.setSoundtrack(url);
    }
  }

  Future<Locadora?> _pickLocadora() {
    final l10n = AppLocalizations.of(context);
    final locadoras = GetIt.I<GetUserLocadoras>()();
    return MuuvieBottomSheet.show<Locadora>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: FutureBuilder<Result<Paged<Locadora>>>(
          future: locadoras,
          builder: (context, snapshot) => switch (snapshot.data) {
            null => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            Failure(:final error) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(error.message),
            ),
            Success(:final data) when data.items.isEmpty => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n?.locadoraEmptyMessage ?? ''),
            ),
            Success(:final data) => ListView(
              shrinkWrap: true,
              children: [
                for (final locadora in data.items)
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(locadora.name),
                    subtitle: Text(
                      l10n?.locadoraProgress(
                            locadora.totalWatched,
                            locadora.totalMovies,
                          ) ??
                          '',
                    ),
                    onTap: () => Navigator.of(sheetContext).pop(locadora),
                  ),
              ],
            ),
          },
        ),
      ),
    );
  }

  Future<String?> _askSoundtrack(String? current) {
    final l10n = AppLocalizations.of(context);
    return MuuvieTextPromptDialog.show(
      context,
      title: l10n?.highlightTitle(HighlightType.soundtrack.wireValue) ?? '',
      confirmLabel: l10n?.shelfReorderDone ?? '',
      initialValue: current,
      hintText: l10n?.highlightSoundtrackHint,
      errorText: l10n?.highlightSoundtrackInvalid,
      keyboardType: TextInputType.url,
      parse: (text) {
        // Keyboards may capitalize the scheme ("HTTPS://"); Uri lowercases it and the host.
        final link = Uri.tryParse(text)?.toString() ?? '';
        return SoundtrackService.of(link) == null ? null : link;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<HighlightsEditorCubit, HighlightsEditorState>(
      bloc: _cubit,
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n?.profileTabHighlights ?? ''),
          actions: [
            if (state is HighlightsEditorReady)
              TextButton(
                onPressed: state.isSaving ? null : _save,
                child: Text(l10n?.editProfileSave ?? ''),
              ),
          ],
        ),
        body: switch (state) {
          HighlightsEditorLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          HighlightsEditorError(:final message) => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: _cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          HighlightsEditorReady(:final slots) => ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            buildDefaultDragHandles: false,
            itemCount: slots.length,
            onReorderItem: _cubit.move,
            itemBuilder: (context, index) => _SlotCard(
              key: ValueKey(slots[index].type),
              index: index,
              slot: slots[index],
              onConfigure: () => _configure(slots[index]),
              onEnabled: (enabled) =>
                  _cubit.setEnabled(slots[index].type, enabled),
            ),
          ),
        },
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final int index;
  final ProfileHighlight slot;
  final VoidCallback onConfigure;
  final ValueChanged<bool> onEnabled;

  const _SlotCard({
    super.key,
    required this.index,
    required this.slot,
    required this.onConfigure,
    required this.onEnabled,
  });

  String? _summary(AppLocalizations? l10n) => switch (slot.type) {
    HighlightType.top4 when slot.movieIds.isNotEmpty =>
      slot.movies.map((movie) => movie.title).join(' · '),
    HighlightType.shelf when slot.shelf != null =>
      l10n?.shelfName(slot.shelf!.systemType, slot.shelf!.name) ??
          slot.shelf!.name,
    HighlightType.locadora when slot.locadora != null => slot.locadora!.name,
    HighlightType.soundtrack when slot.soundtrackUrl != null =>
      slot.soundtrackUrl,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final configured = HighlightsEditorCubit.isConfigured(slot);
    final summary = _summary(l10n);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.drag_handle),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.highlightTitle(slot.type.wireValue) ?? '',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    summary ?? l10n?.highlightNotSet ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: onConfigure,
                    child: Text(
                      (configured
                              ? l10n?.highlightChange
                              : l10n?.highlightChoose) ??
                          '',
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: l10n?.highlightTitle(slot.type.wireValue),
              child: Switch(
                value: slot.enabled && configured,
                onChanged: configured ? onEnabled : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
