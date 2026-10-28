import 'package:auth/auth.dart' show Logout;
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboarding/onboarding.dart';
import 'package:profile_ui/settings/settings_state.dart';
import 'package:social_network/social_network.dart';

/// Perfil › Configurações (F11.1): push preferences, the introduction again
/// and logout.
class SettingsCubit extends Cubit<SettingsState> {
  final GetNotificationPrefs _getPrefs;
  final SaveNotificationPrefs _savePrefs;
  final ResetOnboarding _resetOnboarding;
  final Logout _logout;

  SettingsCubit({
    required GetNotificationPrefs getPrefs,
    required SaveNotificationPrefs savePrefs,
    required ResetOnboarding resetOnboarding,
    required Logout logout,
  }) : _getPrefs = getPrefs,
       _savePrefs = savePrefs,
       _resetOnboarding = resetOnboarding,
       _logout = logout,
       super(const SettingsLoading());

  Future<void> load() async {
    final result = await _getPrefs();
    if (isClosed) return;
    emit(
      SettingsReady(
        prefs: switch (result) {
          Success(:final data) => data,
          Failure() => null,
        },
      ),
    );
  }

  /// Optimistic; the previous value comes back when the server refuses it.
  Future<AppError?> setPrefs(NotificationPrefs prefs) async {
    final current = state;
    if (current is! SettingsReady) return null;
    emit(SettingsReady(prefs: prefs));
    final result = await _savePrefs(prefs);
    if (isClosed) return null;
    if (result case Failure(:final error)) {
      emit(current);
      return error;
    }
    return null;
  }

  Future<void> resetOnboarding() => _resetOnboarding();

  Future<void> logout() async {
    await _logout();
    if (!isClosed) emit(const SettingsLoggedOut());
  }
}
