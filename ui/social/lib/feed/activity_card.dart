import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:gamification/gamification.dart' show Pet, PetRarity;
import 'package:gamification_ui/widgets/gamification_labels.dart';
import 'package:social_network/social_network.dart';

/// One activity of the Atts feed (F6.2): who did what, the movie, shelf,
/// locadora or maratona it is about, and the "amei". Navigation is left to
/// the caller.
class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onOpenActor;
  final ValueChanged<ActivityMovie> onOpenMovie;
  final ValueChanged<ActivityShelf> onOpenShelf;
  final ValueChanged<ActivityLocadora> onOpenLocadora;

  /// Opens a maratona (phase 7); null where it is already open.
  final ValueChanged<ActivityMaratona>? onOpenMaratona;

  /// Opens a CineClube (phase 8); null where it is already open.
  final ValueChanged<ActivityCineClube>? onOpenCineClube;
  final VoidCallback onToggleLove;

  /// Hides or shows my own activity; null on other people's.
  final VoidCallback? onToggleHidden;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onOpenActor,
    required this.onOpenMovie,
    required this.onOpenShelf,
    required this.onOpenLocadora,
    this.onOpenMaratona,
    this.onOpenCineClube,
    required this.onToggleLove,
    this.onToggleHidden,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final actor = activity.actor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onOpenActor,
            child: MuuvieUserAvatar(
              url: actor.avatarUrl,
              name: actor.name,
              accentColor: actor.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Headline(
                        activity: activity,
                        onOpenActor: onOpenActor,
                      ),
                    ),
                    if (onToggleHidden != null)
                      PopupMenuButton<void>(
                        tooltip: l10n?.activityMoreOptions,
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (_) => [
                          PopupMenuItem<void>(
                            onTap: onToggleHidden,
                            child: Text(
                              activity.hidden
                                  ? l10n?.activityShow ?? ''
                                  : l10n?.activityHide ?? '',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _Body(
                  activity: activity,
                  onOpenMovie: onOpenMovie,
                  onOpenShelf: onOpenShelf,
                  onOpenLocadora: onOpenLocadora,
                  onOpenMaratona: onOpenMaratona,
                  onOpenCineClube: onOpenCineClube,
                ),
                Row(
                  children: [
                    _LoveButton(activity: activity, onPressed: onToggleLove),
                    const Spacer(),
                    if (activity.hidden)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _Pill(label: l10n?.activityHidden ?? ''),
                      ),
                    if (activity.visibility != ContentVisibility.public)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Tooltip(
                          message:
                              l10n?.contentVisibility(activity.visibility) ??
                              '',
                          child: Icon(
                            activity.visibility == ContentVisibility.secret
                                ? Icons.lock_outline
                                : Icons.people_outline,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                Divider(height: 8, color: colorScheme.outlineVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "**Ana** assistiu **Halloween** · 2 h".
class _Headline extends StatelessWidget {
  final Activity activity;
  final VoidCallback onOpenActor;

  const _Headline({required this.activity, required this.onOpenActor});

  String _verb(AppLocalizations? l10n) {
    final log = activity.log;
    return switch (activity.type) {
      ActivityType.finishedMovie when log?.isRewatch == true =>
        l10n?.activityVerbRewatched ?? '',
      ActivityType.finishedMovie => l10n?.activityVerbFinished ?? '',
      ActivityType.watchSession => l10n?.activityVerbSession ?? '',
      ActivityType.rating => l10n?.activityVerbRating ?? '',
      ActivityType.newShelf => l10n?.activityVerbNewShelf ?? '',
      ActivityType.featuredShelf => l10n?.activityVerbFeaturedShelf ?? '',
      ActivityType.newLocadora => l10n?.activityVerbNewLocadora ?? '',
      ActivityType.watchingNow => l10n?.activityVerbWatchingNow ?? '',
      ActivityType.importedMovies =>
        l10n?.activityVerbImported(_sourceName(activity.import?.source)) ?? '',
      ActivityType.createdMaratona => l10n?.activityVerbCreatedMaratona ?? '',
      ActivityType.createdCineclube => l10n?.activityVerbCreatedCineClube ?? '',
      ActivityType.joinedCineclube => l10n?.activityVerbJoinedCineClube ?? '',
      ActivityType.unlockedBichinho => l10n?.activityVerbUnlockedBichinho ?? '',
      ActivityType.joinedMaratona => l10n?.activityVerbJoinedMaratona ?? '',
      ActivityType.finishedChallenge =>
        l10n?.activityVerbFinishedChallenge ?? '',
      ActivityType.finishedMaratona => l10n?.activityVerbFinishedMaratona ?? '',
    };
  }

  static String _sourceName(String? source) => switch (source) {
    'filmow' => 'Filmow',
    'letterboxd' => 'Letterboxd',
    _ => source ?? '',
  };

  String? get _object =>
      activity.maratona?.title ??
      activity.cineclube?.title ??
      activity.movie?.title ??
      activity.shelf?.name ??
      activity.locadora?.name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final bichinho = activity.bichinho;
    final object =
        _object ?? (bichinho == null ? null : petName(l10n, bichinho.slug));
    final strong = textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    );
    final soft = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: activity.actor.name, style: strong),
            TextSpan(text: ' ${_verb(l10n)}', style: soft),
            if (object != null && activity.type != ActivityType.importedMovies)
              TextSpan(text: ' $object', style: strong),
            TextSpan(
              text: ' · ${formatRelativeTime(l10n, activity.createdAt)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Activity activity;
  final ValueChanged<ActivityMovie> onOpenMovie;
  final ValueChanged<ActivityShelf> onOpenShelf;
  final ValueChanged<ActivityLocadora> onOpenLocadora;
  final ValueChanged<ActivityMaratona>? onOpenMaratona;
  final ValueChanged<ActivityCineClube>? onOpenCineClube;

  const _Body({
    required this.activity,
    required this.onOpenMovie,
    required this.onOpenShelf,
    required this.onOpenLocadora,
    this.onOpenMaratona,
    this.onOpenCineClube,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final movie = activity.movie;
    final shelf = activity.shelf;
    final locadora = activity.locadora;
    final imported = activity.import;
    final maratona = activity.maratona;
    final openMaratona = onOpenMaratona;
    final cineclube = activity.cineclube;
    final openCineClube = onOpenCineClube;

    final bichinho = activity.bichinho;
    if (bichinho != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: PetAvatar(
          pet: Pet(
            slug: bichinho.slug,
            rarity: PetRarity.fromWireValue(bichinho.rarity),
            unlocked: true,
          ),
          size: 72,
        ),
      );
    }

    if (cineclube != null) {
      return _CineClubeBlock(
        movie: movie,
        cineclube: cineclube,
        onOpen: openCineClube == null ? null : () => openCineClube(cineclube),
        onOpenMovie: onOpenMovie,
      );
    }

    if (maratona != null) {
      return _MaratonaBlock(
        activity: activity,
        maratona: maratona,
        onOpen: openMaratona == null ? null : () => openMaratona(maratona),
        onOpenMovie: onOpenMovie,
      );
    }

    if (movie != null) {
      return _MovieBlock(
        movie: movie,
        log: activity.log,
        rating: activity.rating,
        onOpen: () => onOpenMovie(movie),
      );
    }
    if (shelf != null) {
      return _PostersBlock(
        posterPaths: shelf.posterPaths,
        caption: l10n?.shelfMoviesCount(shelf.totalMovies) ?? '',
        semanticLabel: shelf.name,
        onOpen: () => onOpenShelf(shelf),
      );
    }
    if (locadora != null) {
      return _PostersBlock(
        posterPaths: locadora.posterPaths,
        caption: l10n?.locadoraMoviesCount(locadora.totalMovies) ?? '',
        semanticLabel: locadora.name,
        onOpen: () => onOpenLocadora(locadora),
      );
    }
    if (imported != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          l10n?.activityImportCounts(imported.watched, imported.watchlist) ??
              '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// A maratona activity: the challenge done with its movie, or the level
/// reached, and the maratona itself.
class _MaratonaBlock extends StatelessWidget {
  final Activity activity;
  final ActivityMaratona maratona;
  final VoidCallback? onOpen;
  final ValueChanged<ActivityMovie> onOpenMovie;

  const _MaratonaBlock({
    required this.activity,
    required this.maratona,
    required this.onOpen,
    required this.onOpenMovie,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final challenge = activity.challenge;
    final level = activity.level;
    final movie = activity.movie;
    final color =
        MuuvieColorPicker.fromHex(maratona.accentColor) ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (challenge != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      challenge.description,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          if (movie != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MovieBlock(
                movie: movie,
                log: null,
                rating: null,
                onOpen: () => onOpenMovie(movie),
              ),
            ),
          if (level != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n?.activityMaratonaLevel(
                      level.name,
                      level.completed,
                      level.total,
                    ) ??
                    '',
                style: textTheme.bodyMedium,
              ),
            ),
          Semantics(
            button: onOpen != null,
            child: InkWell(
              borderRadius: MuuvieRadius.smallAll,
              onTap: onOpen,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: color),
                  borderRadius: MuuvieRadius.smallAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 18, color: color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        maratona.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A CineClube activity: the movie of the current session and the CineClube.
class _CineClubeBlock extends StatelessWidget {
  final ActivityMovie? movie;
  final ActivityCineClube cineclube;
  final VoidCallback? onOpen;
  final ValueChanged<ActivityMovie> onOpenMovie;

  const _CineClubeBlock({
    required this.movie,
    required this.cineclube,
    required this.onOpen,
    required this.onOpenMovie,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final current = movie;
    final color =
        MuuvieColorPicker.fromHex(cineclube.accentColor) ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (current != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MovieBlock(
                movie: current,
                log: null,
                rating: null,
                onOpen: () => onOpenMovie(current),
              ),
            ),
          Semantics(
            button: onOpen != null,
            child: InkWell(
              borderRadius: MuuvieRadius.smallAll,
              onTap: onOpen,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: color),
                  borderRadius: MuuvieRadius.smallAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups_outlined, size: 18, color: color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        cineclube.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Poster, then the rating label, emotions, comment (behind a tap when it spoils) and GIF.
class _MovieBlock extends StatelessWidget {
  static const _posterWidth = 64.0;

  final ActivityMovie movie;
  final ActivityLog? log;
  final ActivityRating? rating;
  final VoidCallback onOpen;

  const _MovieBlock({
    required this.movie,
    required this.log,
    required this.rating,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final posterPath = movie.posterPath;
    final currentRating = rating;
    final currentLog = log;
    final comment = currentLog?.comment?.trim();
    final review = currentRating?.review?.trim();
    final emotions = currentLog?.emotions ?? const <Emotion>[];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          label: movie.title,
          child: InkWell(
            borderRadius: MuuvieRadius.smallAll,
            onTap: onOpen,
            child: ClipRRect(
              borderRadius: MuuvieRadius.smallAll,
              child: SizedBox(
                width: _posterWidth,
                height: _posterWidth * 1.5,
                child: posterPath == null
                    ? ColoredBox(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.movie_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: TmdbImageUrl.buildPosterMedium(posterPath),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentRating?.rating case final rating?)
                MuuvieRatingBadge(rating: rating),
              if (currentLog != null && !currentLog.completed)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _progress(context, currentLog),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (emotions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final emotion in emotions.take(3))
                        _Pill(label: l10n?.emotion(emotion) ?? ''),
                    ],
                  ),
                ),
              for (final (text, spoiler) in [
                if (comment != null && comment.isNotEmpty)
                  (comment, currentLog?.hasSpoiler ?? false),
                if (review != null && review.isNotEmpty)
                  (review, currentRating?.hasSpoiler ?? false),
              ])
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _SpoilerText(text: text, hasSpoiler: spoiler),
                ),
              if (currentLog?.gifUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: ClipRRect(
                    borderRadius: MuuvieRadius.smallAll,
                    child: ExcludeSemantics(
                      child: CachedNetworkImage(
                        imageUrl: currentLog!.gifUrl!,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _progress(BuildContext context, ActivityLog log) {
    final l10n = AppLocalizations.of(context);
    final mode = l10n?.watchMode(log.mode) ?? '';
    return switch (log.mode) {
      WatchMode.minutes when log.minutes != null => '$mode: ${log.minutes}',
      WatchMode.percent when log.percent != null => '$mode: ${log.percent}%',
      _ => mode,
    };
  }
}

/// A comment that starts hidden when it spoils the movie.
class _SpoilerText extends StatefulWidget {
  final String text;
  final bool hasSpoiler;

  const _SpoilerText({required this.text, required this.hasSpoiler});

  @override
  State<_SpoilerText> createState() => _SpoilerTextState();
}

class _SpoilerTextState extends State<_SpoilerText> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.hasSpoiler && !_revealed) {
      return TextButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        onPressed: () => setState(() => _revealed = true),
        icon: const Icon(Icons.visibility_off_outlined, size: 18),
        label: Text(AppLocalizations.of(context)?.spoilerReveal ?? ''),
      );
    }
    return Text(
      widget.text,
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
    );
  }
}

/// Up to four posters of a shelf or locadora, with the movie count.
class _PostersBlock extends StatelessWidget {
  static const _posterWidth = 48.0;

  final List<String> posterPaths;
  final String caption;
  final String semanticLabel;
  final VoidCallback onOpen;

  const _PostersBlock({
    required this.posterPaths,
    required this.caption,
    required this.semanticLabel,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: '$semanticLabel, $caption',
      child: InkWell(
        borderRadius: MuuvieRadius.smallAll,
        onTap: onOpen,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                for (final path in posterPaths.take(4))
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ClipRRect(
                      borderRadius: MuuvieRadius.smallAll,
                      child: CachedNetworkImage(
                        imageUrl: TmdbImageUrl.buildPosterSmall(path),
                        width: _posterWidth,
                        height: _posterWidth * 1.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (posterPaths.isEmpty)
                  Icon(
                    Icons.collections_bookmark_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    caption,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _LoveButton extends StatelessWidget {
  final Activity activity;
  final VoidCallback onPressed;

  const _LoveButton({required this.activity, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final loved = activity.loved;

    return Semantics(
      label: l10n?.activityLovesCount(activity.loves),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: loved
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
          minimumSize: const Size(48, 48),
        ),
        onPressed: onPressed,
        icon: Icon(
          loved ? Icons.favorite : Icons.favorite_border,
          semanticLabel: loved ? l10n?.activityUnlove : l10n?.activityLove,
        ),
        label: ExcludeSemantics(
          child: Text(activity.loves > 0 ? '${activity.loves}' : ''),
        ),
      ),
    );
  }
}

/// A small read-only label (an emotion, "Oculta").
class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: MuuvieRadius.pillAll,
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
