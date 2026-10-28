import 'package:core/core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsTracker implements AnalyticsTracker {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsTracker(this._analytics);

  @override
  Future<void> logEvent(
    String name, [
    Map<String, Object> parameters = const {},
  ]) => _analytics.logEvent(
    name: name,
    parameters: parameters.isEmpty ? null : parameters,
  );

  @override
  Future<void> logScreen(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> setUserId(String? userId) => _analytics.setUserId(id: userId);
}
