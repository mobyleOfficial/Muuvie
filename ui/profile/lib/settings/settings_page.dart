import 'package:auth/auth.dart' show DeleteAccount, Logout;
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:imports_ui/imports_router.dart';
import 'package:onboarding/onboarding.dart';
import 'package:onboarding_ui/onboarding_router.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:profile_ui/settings/settings_bloc.dart';
import 'package:profile_ui/settings/settings_screen.dart';
import 'package:profile_ui/settings/settings_state.dart';
import 'package:social_network/social_network.dart';
import 'package:url_launcher/url_launcher.dart';

/// Perfil › Configurações (F11.1), over the whole screen: edit the profile,
/// import, push preferences, the introduction again and logout.
@RoutePage()
class SettingsPage extends StatefulWidget {
  final ProfileDetails profile;

  const SettingsPage({super.key, required this.profile});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsCubit _cubit = SettingsCubit(
    getPrefs: GetIt.I<GetNotificationPrefs>(),
    savePrefs: GetIt.I<SaveNotificationPrefs>(),
    resetOnboarding: GetIt.I<ResetOnboarding>(),
    logout: GetIt.I<Logout>(),
    deleteAccount: GetIt.I<DeleteAccount>(),
    // Without Firebase there is no permission to warn about.
    push: switch (GetIt.I<PushMessaging>()) {
      NoopPushMessaging() => null,
      final push => push,
    },
    registerPushDevice: GetIt.I<RegisterPushDevice>(),
  )..load();

  /// True when the profile changed, so the profile reloads.
  var _changed = false;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _editProfile() async {
    final saved = await context.router.push<bool>(
      EditProfileRoute(profile: widget.profile),
    );
    if (saved ?? false) _changed = true;
  }

  Future<void> _savePrefs(NotificationPrefs prefs) async {
    final error = await _cubit.setPrefs(prefs);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.commonActionError ?? '',
          ),
        ),
      );
    }
  }

  Future<void> _showIntro() async {
    await _cubit.resetOnboarding();
    if (mounted) await context.router.push(const OnboardingRoute());
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context);
    var confirmed = false;
    await MuuvieDialog.show(
      context: context,
      title: l10n?.settingsLogoutTitle ?? '',
      confirmText: l10n?.settingsLogout ?? '',
      cancelText: l10n?.commonCancel ?? '',
      onConfirm: () => confirmed = true,
    );
    if (confirmed) await _cubit.logout();
  }

  Future<void> _deleteAccount() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    var confirmed = false;
    await MuuvieDialog.show(
      context: context,
      title: l10n?.settingsDeleteAccountTitle ?? '',
      content: l10n?.settingsDeleteAccountMessage,
      confirmText: l10n?.settingsDeleteAccountConfirm ?? '',
      cancelText: l10n?.commonCancel ?? '',
      onConfirm: () => confirmed = true,
    );
    if (!confirmed) return;
    final error = await _cubit.deleteAccount();
    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n?.settingsDeleteAccountError ?? '')),
      );
    }
  }

  void _open(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) =>
      BlocListener<SettingsCubit, SettingsState>(
        bloc: _cubit,
        listener: (context, state) {
          if (state is SettingsLoggedOut) {
            if (state.accountDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)?.settingsDeleteAccountDone ??
                        '',
                  ),
                ),
              );
            }
            context.router.maybePop(true);
          }
        },
        child: MuuvieModalScreen(
          title: AppLocalizations.of(context)?.settingsTitle,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          onClose: () => context.router.maybePop(_changed),
          body: SettingsScreen(
            cubit: _cubit,
            onEditProfile: _editProfile,
            onImport: () => context.router.push(const ImportStartRoute()),
            onSavePrefs: _savePrefs,
            onAllowPush: _cubit.allowPush,
            onShowIntro: _showIntro,
            onLogout: _logout,
            onBlockedAccounts: () =>
                context.router.push(const BlockedAccountsRoute()),
            onPrivacyPolicy: () => _open(MuuvieLegalLinks.privacyPolicy),
            onTerms: () => _open(MuuvieLegalLinks.terms),
            onSupport: () => _open(MuuvieLegalLinks.support),
            onDeleteAccount: _deleteAccount,
          ),
        ),
      );
}
