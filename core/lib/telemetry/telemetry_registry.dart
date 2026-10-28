import 'package:core/telemetry/analytics_tracker.dart';
import 'package:core/telemetry/crash_reporter.dart';
import 'package:core/telemetry/noop_analytics_tracker.dart';
import 'package:core/telemetry/noop_crash_reporter.dart';

/// Where blocs reach analytics and crash reports without taking them in the
/// constructor (fase 15). The app sets the Firebase versions at startup; until
/// then, and in tests, both do nothing.
class Telemetry {
  Telemetry._();

  static AnalyticsTracker analytics = const NoopAnalyticsTracker();
  static CrashReporter crashes = const NoopCrashReporter();
}
