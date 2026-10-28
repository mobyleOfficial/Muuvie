sealed class MainState {
  const MainState();
}

class MainLoading extends MainState {
  const MainLoading();
}

class MainSuccess extends MainState {
  final bool isScraping;

  const MainSuccess({this.isScraping = false});
}
