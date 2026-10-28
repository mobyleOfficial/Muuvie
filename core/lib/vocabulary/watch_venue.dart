/// Where a movie was watched.
enum WatchVenue {
  cinema('cinema'),
  streaming('streaming'),
  tv('tv'),
  physicalMedia('physical_media'),
  festival('festival'),
  other('other');

  final String wireValue;

  const WatchVenue(this.wireValue);

  static WatchVenue? fromWireValue(String? value) =>
      values.where((venue) => venue.wireValue == value).firstOrNull;
}
