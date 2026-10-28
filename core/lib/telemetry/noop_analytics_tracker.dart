import 'package:core/telemetry/analytics_tracker.dart';

/// Used while Firebase is not configured, and in tests.
class NoopAnalyticsTracker implements AnalyticsTracker {
  const NoopAnalyticsTracker();

  @override
  Future<void> logEvent(
    String name, [
    Map<String, Object> parameters = const {},
  ]) async {}

  @override
  Future<void> logScreen(String screenName) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}
