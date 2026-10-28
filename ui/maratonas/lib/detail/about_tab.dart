import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/detail/progress_feed.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';

/// "Sobre" (F7.3): description, who runs it, levels, teams, prizes and what
/// people did in the maratona.
class MaratonaAboutTab extends StatelessWidget {
  final Maratona maratona;
  final ValueChanged<MaratonaUser> onOpenUser;
  final VoidCallback? onOpenSocialLink;

  const MaratonaAboutTab({
    super.key,
    required this.maratona,
    required this.onOpenUser,
    this.onOpenSocialLink,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final description = maratona.description;
    final myLevel = maratona.joined
        ? maratona.level(maratona.me?.levelId)
        : null;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (description != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(description, style: textTheme.bodyLarge),
          ),
        const SizedBox(height: 8),
        _UserTile(
          user: maratona.owner,
          label: l10n?.maratonaOwnerBy(maratona.owner.name),
          onTap: () => onOpenUser(maratona.owner),
        ),
        if (maratona.coOwners.isNotEmpty) ...[
          _Section(title: l10n?.maratonaCoOwners ?? ''),
          for (final user in maratona.coOwners)
            _UserTile(user: user, onTap: () => onOpenUser(user)),
        ],
        if (onOpenSocialLink != null)
          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: Text(l10n?.maratonaSocialLink ?? ''),
            trailing: const Icon(Icons.open_in_new),
            onTap: onOpenSocialLink,
          ),
        _Section(title: l10n?.maratonaLevels ?? ''),
        for (final level in maratona.levels)
          ListTile(
            leading: Icon(
              level.id == myLevel?.id ? Icons.flag : Icons.outlined_flag,
              color: level.id == myLevel?.id ? colorScheme.primary : null,
            ),
            title: Text(level.name),
            subtitle: Text(
              l10n?.maratonaChallengesCount(level.minChallenges) ?? '',
            ),
          ),
        if (maratona.teams.isNotEmpty) ...[
          _Section(title: l10n?.maratonaTeams ?? ''),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final team in maratona.teams)
                  Chip(
                    avatar: CircleAvatar(
                      backgroundColor: maratonaColor(context, team.color),
                    ),
                    label: Text(team.name),
                  ),
              ],
            ),
          ),
        ],
        if (maratona.prizes.isNotEmpty) ...[
          _Section(title: l10n?.maratonaPrizes ?? ''),
          for (final prize in maratona.prizes)
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: Text(prize.title),
              subtitle: prize.description == null
                  ? null
                  : Text(prize.description!),
            ),
        ],
        _Section(title: l10n?.maratonaProgressFeed ?? ''),
        ProgressFeed(slug: maratona.slug),
      ],
    );
  }
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

class _UserTile extends StatelessWidget {
  final MaratonaUser user;
  final String? label;
  final VoidCallback onTap;

  const _UserTile({required this.user, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: MuuvieUserAvatar(
      url: user.avatarUrl,
      name: user.name,
      accentColor: user.accentColor,
    ),
    title: Text(label ?? user.name),
    subtitle: user.handle == null ? null : Text('@${user.handle}'),
    onTap: onTap,
  );
}
