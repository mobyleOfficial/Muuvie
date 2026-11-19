import 'package:auth/auth.dart' show DeleteAccount, Logout;
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:onboarding/onboarding.dart';
import 'package:profile_ui/settings/settings_state.dart';
import 'package:social_network/social_network.dart';

/// Perfil › Configurações (F11.1): push preferences, the introduction again
/// and logout. With [push] (Firebase on), it also warns when the system blocks
/// notifications and asks for them again (fase 15, F15.4).
class SettingsCubit extends Cubit<SettingsState> {
  final GetNotificationPrefs _getPrefs;
  final SaveNotificationPrefs _savePrefs;
  final ResetOnboarding _resetOnboarding;
  final Logout _logout;
  final DeleteAccount? _deleteAccount;
  final PushMessaging? _push;
  final RegisterPushDevice? _registerPushDevice;

  SettingsCubit({
    required GetNotificationPrefs getPrefs,
    required SaveNotificationPrefs savePrefs,
    required ResetOnboarding resetOnboarding,
    required Logout logout,
    DeleteAccount? deleteAccount,
    PushMessaging? push,
    RegisterPushDevice? registerPushDevice,
  }) : _getPrefs = getPrefs,
       _savePrefs = savePrefs,
       _resetOnboarding = resetOnboarding,
       _logout = logout,
       _deleteAccount = deleteAccount,
       _push = push,
       _registerPushDevice = registerPushDevice,
       super(const SettingsLoading());

  Future<void> load() async {
    final result = await _getPrefs();
    final blocked = await _pushBlocked();
    if (isClosed) return;
    emit(
      SettingsReady(
        prefs: switch (result) {
          Success(:final data) => data,
          Failure() => null,
        },
        pushBlocked: blocked,
      ),
    );
  }

  Future<bool> _pushBlocked() async {
    final push = _push;
    return push != null && !await push.isPermitted();
  }

  /// Optimistic; the previous value comes back when the server refuses it.
  Future<AppError?> setPrefs(NotificationPrefs prefs) async {
    final current = state;
    if (current is! SettingsReady) return null;
    emit(SettingsReady(prefs: prefs, pushBlocked: current.pushBlocked));
    final result = await _savePrefs(prefs);
    if (isClosed) return null;
    if (result case Failure(:final error)) {
      emit(current);
      return error;
    }
    return null;
  }

  /// Asks the system again; once allowed, the device is registered right away.
  Future<void> allowPush() async {
    final push = _push;
    if (push == null) return;
    final allowed = await push.requestPermission();
    if (allowed) await _registerPushDevice?.call(Intl.getCurrentLocale());
    final current = state;
    if (isClosed || current is! SettingsReady) return;
    emit(SettingsReady(prefs: current.prefs, pushBlocked: !allowed));
  }

  Future<void> resetOnboarding() => _resetOnboarding();

  Future<void> logout() async {
    await _logout();
    if (!isClosed) emit(const SettingsLoggedOut());
  }

  /// Deletes the account. Answers the error when it failed; nothing happens
  /// when the user gave up on the Apple confirmation.
  Future<AppError?> deleteAccount() async {
    final current = state;
    if (current is! SettingsReady || current.deleting) return null;
    emit(current.copyWith(deleting: true));
    final result = await _deleteAccount?.call();
    if (isClosed) return null;
    switch (result) {
      case Success(:final data) when data:
        emit(const SettingsLoggedOut(accountDeleted: true));
        return null;
      case Success():
        emit(current);
        return null;
      case Failure(:final error):
        emit(current);
        return error;
      case null:
        emit(current);
        return AppError.unknown;
    }
  }
}
