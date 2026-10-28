import 'package:shelves/shelves.dart';

sealed class LocadoraDetailState {
  const LocadoraDetailState();
}

class LocadoraDetailLoading extends LocadoraDetailState {
  const LocadoraDetailLoading();
}

class LocadoraDetailSuccess extends LocadoraDetailState {
  final Locadora locadora;
  final List<LocadoraShelf> shelves;

  /// Drag-to-reorder mode of the shelves (F4.3).
  final bool isReordering;

  const LocadoraDetailSuccess({
    required this.locadora,
    required this.shelves,
    this.isReordering = false,
  });

  LocadoraDetailSuccess copyWith({
    Locadora? locadora,
    List<LocadoraShelf>? shelves,
    bool? isReordering,
  }) => LocadoraDetailSuccess(
    locadora: locadora ?? this.locadora,
    shelves: shelves ?? this.shelves,
    isReordering: isReordering ?? this.isReordering,
  );
}

class LocadoraDetailError extends LocadoraDetailState {
  final String message;

  const LocadoraDetailError(this.message);
}
