import 'package:core/telemetry/crash_reporter.dart';

/// Used while Firebase is not configured, and in tests.
class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setKey(String key, String value) async {}
}
