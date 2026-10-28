/// Product analytics (fase 15). Event names and parameters are snake_case and
/// never carry personal data: only internal ids, types and counts.
abstract class AnalyticsTracker {
  Future<void> logEvent(String name, [Map<String, Object> parameters]);

  Future<void> logScreen(String screenName);

  Future<void> setUserId(String? userId);
}
