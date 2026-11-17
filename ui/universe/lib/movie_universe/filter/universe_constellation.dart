/// A public shelf drawn over the universe (phase 5): the planets whose
/// movies are in it stand out and are joined by lines.
class UniverseConstellation {
  final int shelfId;
  final String name;
  final String ownerName;
  final Set<int> movieIds;

  const UniverseConstellation({
    required this.shelfId,
    required this.name,
    required this.ownerName,
    required this.movieIds,
  });
}
