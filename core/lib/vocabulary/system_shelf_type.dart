/// Shelves every account has. They cannot be renamed or deleted.
enum SystemShelfType {
  /// "Já assisti"
  watched('watched'),

  /// "Quero ver"
  watchlist('watchlist');

  final String wireValue;

  const SystemShelfType(this.wireValue);

  static SystemShelfType? fromWireValue(String? value) =>
      values.where((type) => type.wireValue == value).firstOrNull;
}
