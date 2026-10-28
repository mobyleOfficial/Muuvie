/// Situation of a movie for the user, from the system shelves.
///
/// "Na geladeira" and "Abandonei" are [Rating]s since phase 13.
enum WatchStatus {
  watched('watched'),
  wantToWatch('want_to_watch');

  final String wireValue;

  const WatchStatus(this.wireValue);

  static WatchStatus? fromWireValue(String? value) =>
      values.where((status) => status.wireValue == value).firstOrNull;
}
