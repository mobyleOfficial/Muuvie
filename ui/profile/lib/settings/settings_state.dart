import 'package:social_network/social_network.dart';

sealed class SettingsState {
  const SettingsState();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// The settings with the push preferences; [prefs] is null when they could
/// not be read, and their switches are hidden.
class SettingsReady extends SettingsState {
  final NotificationPrefs? prefs;

  const SettingsReady({this.prefs});
}

class SettingsLoggedOut extends SettingsState {
  const SettingsLoggedOut();
}
