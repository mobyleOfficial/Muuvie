import 'package:shelves/shelves.dart';

sealed class PickShelvesState {
  const PickShelvesState();
}

class PickShelvesLoading extends PickShelvesState {
  const PickShelvesLoading();
}

class PickShelvesSuccess extends PickShelvesState {
  final List<Shelf> shelves;

  /// Selected shelf ids, in the order they will have in the locadora.
  final List<int> selectedIds;

  const PickShelvesSuccess({required this.shelves, required this.selectedIds});
}

class PickShelvesError extends PickShelvesState {
  final String message;

  const PickShelvesError(this.message);
}
