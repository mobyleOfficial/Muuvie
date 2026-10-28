import 'dart:developer' as dev;

import 'package:core/core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:muuvie/firebase/firebase_analytics_tracker.dart';
import 'package:muuvie/firebase/firebase_crash_reporter.dart';
import 'package:muuvie/firebase/firebase_push_messaging.dart';

/// Turns Firebase on when the app has its config (fase 15). Without
/// `google-services.json` (or on web and iOS, still without config) the
/// initialization fails and everything falls back to the no-op versions, so
/// the app runs the same, only without crash reports, analytics and push.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  /// Sets [Telemetry] and answers the push implementation to register in DI.
  static Future<PushMessaging> initialize({required String flavor}) async {
    if (kIsWeb) return const NoopPushMessaging();
    try {
      await Firebase.initializeApp();
    } catch (e) {
      dev.log('[Firebase] Off, no config for this build: $e');
      return const NoopPushMessaging();
    }

    final crashlytics = FirebaseCrashlytics.instance;
    FlutterError.onError = crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
    Telemetry.crashes = FirebaseCrashReporter(crashlytics);
    Telemetry.analytics = FirebaseAnalyticsTracker(FirebaseAnalytics.instance);
    await Telemetry.crashes.setKey('flavor', flavor);
    return FirebasePushMessaging(FirebaseMessaging.instance);
  }
}
