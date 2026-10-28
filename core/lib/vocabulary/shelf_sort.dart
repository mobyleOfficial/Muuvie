/// Ordering of the movies inside a shelf. [manual] keeps the saved positions.
enum ShelfSort {
  manual('manual'),
  title('title'),
  director('director'),
  releaseYear('release_year'),
  addedNewest('added_newest'),
  addedOldest('added_oldest'),
  updatedNewest('updated_newest'),
  watchedFirst('watched_first'),
  watchedLast('watched_last'),
  progressHighest('progress_highest'),
  ratingHighest('rating_highest');

  final String wireValue;

  const ShelfSort(this.wireValue);

  static const ShelfSort defaultValue = ShelfSort.manual;

  static ShelfSort? fromWireValue(String? value) =>
      values.where((sort) => sort.wireValue == value).firstOrNull;
}
