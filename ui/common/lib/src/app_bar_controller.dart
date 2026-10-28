import 'package:flutter/widgets.dart';

class AppBarController extends ChangeNotifier {
  String? _currentTitle;
  List<Widget>? _currentActions;

  String? get currentTitle => _currentTitle;
  List<Widget>? get currentActions => _currentActions;

  void update({required String? title}) {
    if (_currentTitle == title) return;
    _currentTitle = title;
    notifyListeners();
  }

  void setActions(List<Widget>? actions) {
    if (identical(_currentActions, actions)) return;
    _currentActions = actions;
    notifyListeners();
  }

  void clearActions() => setActions(null);
}

class AppBarControllerScope extends InheritedNotifier<AppBarController> {
  const AppBarControllerScope({
    super.key,
    required AppBarController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppBarController? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppBarControllerScope>()
      ?.notifier;
}

class TabIndexScope extends StatelessWidget {
  final int tabIndex;
  final Widget child;

  const TabIndexScope({super.key, required this.tabIndex, required this.child});

  static int? find(BuildContext context) =>
      context.findAncestorWidgetOfExactType<TabIndexScope>()?.tabIndex;

  @override
  Widget build(BuildContext context) => child;
}
