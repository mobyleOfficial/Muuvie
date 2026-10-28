import 'package:shelves/shelves.dart';

sealed class AddToShelvesState {
  const AddToShelvesState();
}

class AddToShelvesLoading extends AddToShelvesState {
  const AddToShelvesLoading();
}

class AddToShelvesSuccess extends AddToShelvesState {
  final List<Shelf> shelves;

  /// Shelves that already hold the movie. They show checked and cannot be unchecked here.
  final Set<int> currentShelfIds;
  final Set<int> selectedShelfIds;
  final bool isSaving;

  const AddToShelvesSuccess({
    required this.shelves,
    required this.currentShelfIds,
    required this.selectedShelfIds,
    this.isSaving = false,
  });

  AddToShelvesSuccess copyWith({Set<int>? selectedShelfIds, bool? isSaving}) =>
      AddToShelvesSuccess(
        shelves: shelves,
        currentShelfIds: currentShelfIds,
        selectedShelfIds: selectedShelfIds ?? this.selectedShelfIds,
        isSaving: isSaving ?? this.isSaving,
      );
}

class AddToShelvesError extends AddToShelvesState {
  final String message;

  const AddToShelvesError(this.message);
}
