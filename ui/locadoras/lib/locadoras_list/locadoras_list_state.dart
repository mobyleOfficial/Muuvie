import 'package:shelves/shelves.dart';

sealed class LocadorasListState {
  const LocadorasListState();
}

class LocadorasListLoading extends LocadorasListState {
  const LocadorasListLoading();
}

class LocadorasListSuccess extends LocadorasListState {
  final List<Locadora> locadoras;

  /// Drag-to-reorder mode of the profile order.
  final bool isReordering;

  const LocadorasListSuccess(this.locadoras, {this.isReordering = false});

  LocadorasListSuccess copyWith({
    List<Locadora>? locadoras,
    bool? isReordering,
  }) => LocadorasListSuccess(
    locadoras ?? this.locadoras,
    isReordering: isReordering ?? this.isReordering,
  );
}

class LocadorasListError extends LocadorasListState {
  final String message;

  const LocadorasListError(this.message);
}
