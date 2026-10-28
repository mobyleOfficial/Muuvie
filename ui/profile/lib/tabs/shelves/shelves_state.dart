import 'package:shelves/shelves.dart';

sealed class ShelvesState {
  const ShelvesState();
}

class ShelvesLoading extends ShelvesState {
  const ShelvesLoading();
}

class ShelvesSuccess extends ShelvesState {
  final List<Shelf> shelves;

  /// Drag-to-reorder mode of the profile order (F1.7).
  final bool isReordering;

  const ShelvesSuccess(this.shelves, {this.isReordering = false});

  ShelvesSuccess copyWith({List<Shelf>? shelves, bool? isReordering}) =>
      ShelvesSuccess(
        shelves ?? this.shelves,
        isReordering: isReordering ?? this.isReordering,
      );
}

class ShelvesError extends ShelvesState {
  final String message;

  const ShelvesError(this.message);
}
