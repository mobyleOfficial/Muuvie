import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';

/// "Desafios" (F7.3, F7.5): the categories with a progress bar each and the
/// challenges, done ones checked. Tapping a challenge opens it.
class MaratonaChallengesTab extends StatelessWidget {
  final Maratona maratona;
  final List<MaratonaCategory> categories;
  final ValueChanged<MaratonaChallenge> onOpenChallenge;

  const MaratonaChallengesTab({
    super.key,
    required this.maratona,
    required this.categories,
    required this.onOpenChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final color = maratonaColor(context, maratona.accentColor);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final category in categories) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      category.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (category.teamOnly)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MaratonaBadge(
                      label: l10n?.maratonaTeamOnly ?? '',
                      icon: Icons.groups_outlined,
                    ),
                  ),
                if (maratona.joined)
                  Text(
                    '${category.completed}/${category.challenges.length}',
                    style: textTheme.labelMedium,
                  ),
              ],
            ),
          ),
          if (maratona.joined)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: category.challenges.isEmpty
                    ? 0
                    : category.completed / category.challenges.length,
                color: color,
                borderRadius: BorderRadius.circular(4),
                semanticsLabel: category.name,
              ),
            ),
          for (final challenge in category.challenges)
            _ChallengeTile(
              challenge: challenge,
              color: color,
              onTap: () => onOpenChallenge(challenge),
            ),
        ],
      ],
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  final MaratonaChallenge challenge;
  final Color color;
  final VoidCallback onTap;

  const _ChallengeTile({
    required this.challenge,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final kind = challenge.criteria != null
        ? l10n?.maratonaChallengeAuto
        : l10n?.maratonaChallengeManual;

    return MergeSemantics(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          challenge.completed
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: challenge.completed ? color : colorScheme.onSurfaceVariant,
          semanticLabel: challenge.completed
              ? l10n?.maratonaChallengeDone
              : l10n?.maratonaChallengeOpen,
        ),
        title: Text(challenge.description),
        subtitle: Text(
          [
            kind ?? '',
            if (challenge.daily) l10n?.maratonaChallengeDaily ?? '',
          ].join(' · '),
        ),
        trailing: challenge.links.isEmpty
            ? null
            : ExcludeSemantics(
                child: SizedBox(
                  height: 48,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final link in challenge.links.take(2))
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              width: 32,
                              height: 48,
                              child: link.posterPath == null
                                  ? ColoredBox(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: TmdbImageUrl.buildPosterSmall(
                                        link.posterPath!,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
