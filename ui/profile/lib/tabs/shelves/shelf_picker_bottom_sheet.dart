import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:shelves/shelves.dart';

/// Picks one of the current user's shelves, e.g. the target of a move or copy.
class ShelfPickerBottomSheet extends StatefulWidget {
  final Future<Result<Paged<Shelf>>> Function() loadShelves;
  final int? excludedShelfId;

  /// Defaults to the move/copy title.
  final String? title;

  const ShelfPickerBottomSheet({
    super.key,
    required this.loadShelves,
    this.excludedShelfId,
    this.title,
  });

  static Future<Shelf?> show(
    BuildContext context, {
    required Future<Result<Paged<Shelf>>> Function() loadShelves,
    int? excludedShelfId,
    String? title,
  }) => MuuvieBottomSheet.show<Shelf>(
    context: context,
    builder: (_) => ShelfPickerBottomSheet(
      loadShelves: loadShelves,
      excludedShelfId: excludedShelfId,
      title: title,
    ),
  );

  @override
  State<ShelfPickerBottomSheet> createState() => _ShelfPickerBottomSheetState();
}

class _ShelfPickerBottomSheetState extends State<ShelfPickerBottomSheet> {
  late final Future<Result<Paged<Shelf>>> _shelves = widget.loadShelves();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.title ?? l10n?.shelfPickTarget ?? '',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
            child: FutureBuilder<Result<Paged<Shelf>>>(
              future: _shelves,
              builder: (context, snapshot) => switch (snapshot.data) {
                null => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                Failure(:final error) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error.message),
                ),
                Success(:final data) => ListView(
                  shrinkWrap: true,
                  children: [
                    for (final shelf in data.items)
                      if (shelf.id != widget.excludedShelfId)
                        ListTile(
                          leading: CircleAvatar(
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
                          onTap: () => Navigator.of(context).pop(shelf),
                        ),
                  ],
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
