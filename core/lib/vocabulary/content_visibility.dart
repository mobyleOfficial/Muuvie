/// Who can see a user-owned resource (shelf, locadora, watch log, activity).
enum ContentVisibility {
  public('public'),

  /// Only users who follow each other.
  mutual('mutual'),
  secret('secret');

  final String wireValue;

  const ContentVisibility(this.wireValue);

  static const ContentVisibility defaultValue = ContentVisibility.public;

  static ContentVisibility? fromWireValue(String? value) =>
      values.where((visibility) => visibility.wireValue == value).firstOrNull;
}
