import 'package:imports/imports.dart';

sealed class ImportUnmatchedState {
  const ImportUnmatchedState();
}

class ImportUnmatchedLoading extends ImportUnmatchedState {
  const ImportUnmatchedLoading();
}

class ImportUnmatchedError extends ImportUnmatchedState {
  final String message;

  const ImportUnmatchedError(this.message);
}

class ImportUnmatchedSuccess extends ImportUnmatchedState {
  final List<UnmatchedItem> items;
  final int page;
  final bool hasNext;

  /// Items being resolved, by id.
  final Set<int> resolving;

  /// The last resolution failed; the screen shows a snackbar once.
  final bool actionFailed;

  const ImportUnmatchedSuccess({
    required this.items,
    required this.page,
    required this.hasNext,
    this.resolving = const {},
    this.actionFailed = false,
  });

  ImportUnmatchedSuccess copyWith({
    List<UnmatchedItem>? items,
    int? page,
    bool? hasNext,
    Set<int>? resolving,
    bool actionFailed = false,
  }) => ImportUnmatchedSuccess(
    items: items ?? this.items,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
    resolving: resolving ?? this.resolving,
    actionFailed: actionFailed,
  );
}
