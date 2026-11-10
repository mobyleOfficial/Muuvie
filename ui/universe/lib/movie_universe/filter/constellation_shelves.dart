import 'package:shelves/shelves.dart' show PublicShelf;

/// The public shelves that hold the star [starId], offered as
/// constellations in the filters.
sealed class ConstellationShelves {
  final int starId;

  const ConstellationShelves(this.starId);
}

final class ConstellationShelvesLoading extends ConstellationShelves {
  const ConstellationShelvesLoading(super.starId);
}

final class ConstellationShelvesLoaded extends ConstellationShelves {
  final List<PublicShelf> shelves;

  const ConstellationShelvesLoaded(super.starId, this.shelves);
}

final class ConstellationShelvesFailed extends ConstellationShelves {
  const ConstellationShelvesFailed(super.starId);
}
