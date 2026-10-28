import 'package:social_network/social_network.dart';

sealed class SettingsState {
  const SettingsState();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// The settings with the push preferences; [prefs] is null when they could
/// not be read, and their switches are hidden. [pushBlocked] is true when the
/// system does not let the app show notifications (fase 15).
class SettingsReady extends SettingsState {
  final NotificationPrefs? prefs;
  final bool pushBlocked;

  const SettingsReady({this.prefs, this.pushBlocked = false});
}

class SettingsLoggedOut extends SettingsState {
  const SettingsLoggedOut();
}
