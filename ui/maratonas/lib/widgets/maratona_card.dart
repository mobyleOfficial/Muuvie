import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';

/// A maratona in a list (Programação, profile participations).
class MaratonaCard extends StatelessWidget {
  final MaratonaSummary maratona;
  final VoidCallback onTap;

  const MaratonaCard({super.key, required this.maratona, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaratonaLogo(
                title: maratona.title,
                logoUrl: maratona.logoUrl,
                accentColor: maratona.accentColor,
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maratona.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      maratonaPeriod(l10n, maratona.startsOn, maratona.endsOn),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${l10n?.maratonaChallengesCount(maratona.totalChallenges) ?? ''}'
                      ' · '
                      '${l10n?.maratonaParticipants(maratona.totalParticipants) ?? ''}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        MaratonaBadge(
                          label: maratona.status.label(l10n),
                          highlighted: maratona.status == MaratonaStatus.active,
                        ),
                        if (maratona.joined)
                          MaratonaBadge(
                            label: l10n?.maratonaJoined ?? '',
                            icon: Icons.check,
                            highlighted: true,
                          ),
                        if (maratona.trusted)
                          MaratonaBadge(
                            label: l10n?.maratonaFilterCurated ?? '',
                            icon: Icons.verified_outlined,
                          ),
                        if (maratona.hasPassword)
                          MaratonaBadge(
                            label: l10n?.maratonaLocked ?? '',
                            icon: Icons.lock_outline,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
