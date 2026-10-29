/// Sends errors to a crash report service (fase 15). Never pass personal data:
/// the user is identified only by the account id.
abstract class CrashReporter {
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  });

  Future<void> setUserId(String? userId);

  Future<void> setKey(String key, String value);
}
