import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/widgets/cineclube_labels.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// "Sobre" (F8.3): the movie of the session, its period and debate day,
/// where to watch it, the links, who runs it and the sessions of a cycle.
class CineClubeAboutTab extends StatelessWidget {
  final CineClube cineclube;

  /// The session picked in a cycle, else the current one.
  final CineClubeSession? session;
  final ValueChanged<CineClubeUser> onOpenUser;
  final ValueChanged<CineClubeMovie> onOpenMovie;
  final ValueChanged<String> onOpenLink;

  const CineClubeAboutTab({
    super.key,
    required this.cineclube,
    required this.session,
    required this.onOpenUser,
    required this.onOpenMovie,
    required this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final description = cineclube.description;
    final shown = session;
    final debateLink = cineclube.debateLink;
    final socialLink = cineclube.socialLink;
    final owner = cineclube.owner;
    // Watch providers come for the current session's movie only.
    final providers = shown?.id == cineclube.currentSessionId
        ? cineclube.watchProviders
        : const <WatchProviderInfo>[];

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (shown != null)
          _SessionMovie(
            session: shown,
            cineclube: cineclube,
            onOpenMovie: onOpenMovie,
          ),
        if (providers.isNotEmpty) ...[
          _Section(title: l10n?.cineclubeWhereToWatch ?? ''),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final provider in providers)
                  Chip(
                    avatar: provider.logoPath == null
                        ? null
                        : CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              TmdbImageUrl.buildPosterSmall(provider.logoPath!),
                            ),
                          ),
                    label: Text(provider.name),
                  ),
              ],
            ),
          ),
        ],
        if (description != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(description, style: textTheme.bodyLarge),
          ),
        const SizedBox(height: 8),
        ListTile(
          leading: MuuvieUserAvatar(
            url: owner.avatarUrl,
            name: owner.name,
            accentColor: owner.accentColor,
          ),
          title: Text(l10n?.maratonaOwnerBy(owner.name) ?? owner.name),
          subtitle: owner.handle == null ? null : Text('@${owner.handle}'),
          onTap: () => onOpenUser(owner),
        ),
        if (debateLink != null)
          ListTile(
            leading: const Icon(Icons.video_call_outlined),
            title: Text(l10n?.cineclubeDebateLink ?? ''),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => onOpenLink(debateLink),
          ),
        if (socialLink != null)
          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: Text(l10n?.maratonaSocialLink ?? ''),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => onOpenLink(socialLink),
          ),
        if (cineclube.isCycle) ...[
          _Section(title: l10n?.cineclubeSessions ?? ''),
          for (final (index, item) in cineclube.sessions.indexed)
            ListTile(
              leading: CineClubePoster(
                posterPath: item.movie.posterPath,
                accentColor: cineclube.accentColor,
                width: 36,
              ),
              title: Text(
                l10n?.cineclubeSessionLabel(index + 1, item.movie.title) ??
                    item.movie.title,
              ),
              subtitle: Text(
                '${cineclubePeriod(l10n, item.startsOn, item.endsOn)}\n'
                '${l10n?.cineclubeDebateOn(cineclubeDay(item.debateOn)) ?? ''}',
              ),
              isThreeLine: true,
              trailing: item.id == cineclube.currentSessionId
                  ? Icon(
                      Icons.play_arrow,
                      semanticLabel: l10n?.cineclubeCurrentSession,
                    )
                  : null,
              onTap: () => onOpenMovie(item.movie),
            ),
        ],
      ],
    );
  }
}

class _SessionMovie extends StatelessWidget {
  final CineClubeSession session;
  final CineClube cineclube;
  final ValueChanged<CineClubeMovie> onOpenMovie;

  const _SessionMovie({
    required this.session,
    required this.cineclube,
    required this.onOpenMovie,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final movie = session.movie;
    final today = DateUtils.dateOnly(DateTime.now());
    final runtime = movie.runtime;

    return InkWell(
      onTap: () => onOpenMovie(movie),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CineClubePoster(
              posterPath: movie.posterPath,
              accentColor: cineclube.accentColor,
              width: 96,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (movie.year != null || runtime != null)
                    Text(
                      [
                        if (movie.year != null) '${movie.year}',
                        if (runtime != null)
                          l10n?.cineclubeRuntime(runtime) ?? '',
                      ].join(' · '),
                      style: textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  _Line(
                    icon: Icons.date_range_outlined,
                    text: cineclubePeriod(
                      l10n,
                      session.startsOn,
                      session.endsOn,
                    ),
                  ),
                  _Line(
                    icon: Icons.forum_outlined,
                    text:
                        l10n?.cineclubeDebateOn(
                          cineclubeDay(session.debateOn),
                        ) ??
                        '',
                  ),
                  if (!session.debateCame(today))
                    _Line(
                      icon: Icons.visibility_off_outlined,
                      text: l10n?.cineclubeSpoilerNote ?? '',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Line({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Icon(icon, size: 16)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
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
