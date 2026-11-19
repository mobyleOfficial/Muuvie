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

  /// The account is being deleted; the screen waits.
  final bool deleting;

  const SettingsReady({
    this.prefs,
    this.pushBlocked = false,
    this.deleting = false,
  });

  SettingsReady copyWith({bool? deleting}) => SettingsReady(
    prefs: prefs,
    pushBlocked: pushBlocked,
    deleting: deleting ?? this.deleting,
  );
}

class SettingsLoggedOut extends SettingsState {
  /// The session ended because the account was deleted.
  final bool accountDeleted;

  const SettingsLoggedOut({this.accountDeleted = false});
}
