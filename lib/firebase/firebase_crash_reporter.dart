import 'package:core/core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseCrashReporter implements CrashReporter {
  final FirebaseCrashlytics _crashlytics;

  FirebaseCrashReporter(this._crashlytics);

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) => _crashlytics.recordError(error, stackTrace, fatal: fatal);

  // Crashlytics has no way to clear the id, so a logout sets it empty.
  @override
  Future<void> setUserId(String? userId) =>
      _crashlytics.setUserIdentifier(userId ?? '');

  @override
  Future<void> setKey(String key, String value) =>
      _crashlytics.setCustomKey(key, value);
}
