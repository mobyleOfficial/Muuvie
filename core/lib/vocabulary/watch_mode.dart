/// How the progress of a watch session is expressed.
enum WatchMode {
  watched('watched'),
  minutes('minutes'),
  percent('percent');

  final String wireValue;

  const WatchMode(this.wireValue);

  static WatchMode? fromWireValue(String? value) =>
      values.where((mode) => mode.wireValue == value).firstOrNull;
}
