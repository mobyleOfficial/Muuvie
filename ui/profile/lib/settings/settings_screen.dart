import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_ui/settings/settings_bloc.dart';
import 'package:profile_ui/settings/settings_state.dart';
import 'package:social_network/social_network.dart';

/// The settings list: account, import, notifications and the rest.
class SettingsScreen extends StatelessWidget {
  final SettingsCubit cubit;
  final VoidCallback onEditProfile;
  final VoidCallback onImport;
  final ValueChanged<NotificationPrefs> onSavePrefs;
  final VoidCallback onAllowPush;
  final VoidCallback onShowIntro;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.cubit,
    required this.onEditProfile,
    required this.onImport,
    required this.onSavePrefs,
    required this.onAllowPush,
    required this.onShowIntro,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: cubit,
      builder: (context, state) {
        if (state is! SettingsReady) {
          return const Center(child: MuuvieActivityIndicator());
        }
        final prefs = state.prefs;
        return ListView(
          children: [
            _Section(title: l10n?.settingsAccount ?? ''),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n?.profileEditProfile ?? ''),
              onTap: onEditProfile,
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: Text(l10n?.settingsImport ?? ''),
              subtitle: Text(l10n?.settingsImportHint ?? ''),
              onTap: onImport,
            ),
            if (prefs != null) ...[
              _Section(title: l10n?.settingsNotifications ?? ''),
              if (state.pushBlocked)
                ListTile(
                  leading: Icon(
                    Icons.notifications_off_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(l10n?.settingsPushOff ?? ''),
                  subtitle: Text(l10n?.settingsPushOffHint ?? ''),
                  trailing: TextButton(
                    onPressed: onAllowPush,
                    child: Text(l10n?.settingsPushAllow ?? ''),
                  ),
                ),
              _Switch(
                title: l10n?.settingsNotifyMessages ?? '',
                value: prefs.messages,
                onChanged: (value) =>
                    onSavePrefs(prefs.copyWith(messages: value)),
              ),
              _Switch(
                title: l10n?.settingsNotifyFollowers ?? '',
                value: prefs.newFollowers,
                onChanged: (value) =>
                    onSavePrefs(prefs.copyWith(newFollowers: value)),
              ),
              _Switch(
                title: l10n?.settingsNotifyLoves ?? '',
                value: prefs.loves,
                onChanged: (value) => onSavePrefs(prefs.copyWith(loves: value)),
              ),
              _Switch(
                title: l10n?.settingsNotifyMaratonas ?? '',
                value: prefs.maratonas,
                onChanged: (value) =>
                    onSavePrefs(prefs.copyWith(maratonas: value)),
              ),
              _Switch(
                title: l10n?.settingsNotifyCineclubes ?? '',
                value: prefs.cineclubes,
                onChanged: (value) =>
                    onSavePrefs(prefs.copyWith(cineclubes: value)),
              ),
            ],
            _Section(title: l10n?.settingsAbout ?? ''),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined),
              title: Text(l10n?.settingsShowIntro ?? ''),
              onTap: onShowIntro,
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n?.settingsLogout ?? '',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: onLogout,
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _Switch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Switch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) =>
      SwitchListTile(title: Text(title), value: value, onChanged: onChanged);
}

class _Section extends StatelessWidget {
  final String title;

  const _Section({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Semantics(
      header: true,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
