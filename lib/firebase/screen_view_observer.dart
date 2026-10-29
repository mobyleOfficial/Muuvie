import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

/// Logs a `screen_view` with the route name (`MovieDetailRoute`...) whenever a
/// screen shows up: pushed, back on top after a pop, or picked in the tab bar
/// (fase 15, F15.2). Dialogs and sheets are not screens and are left out.
class ScreenViewObserver extends AutoRouterObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _log(previousRoute);
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) =>
      Telemetry.analytics.logScreen(route.name);

  void _log(Route<dynamic> route) {
    final name = route.settings.name;
    if (route is PageRoute && name != null) {
      Telemetry.analytics.logScreen(name);
    }
  }
}
