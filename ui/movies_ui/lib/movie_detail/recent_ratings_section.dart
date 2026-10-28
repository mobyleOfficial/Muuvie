import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies_ui/movie_detail/movie_section.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:social_network/social_network.dart';

/// "Avaliações recentes" on the movie detail (B13.2): the latest ratings with
/// a text that the user may see, from anyone. Hidden when there is none.
class RecentRatingsSection extends StatefulWidget {
  static const _maxShown = 3;

  /// Database id of the movie.
  final int movieId;

  /// "Ver todas": the Comunidade tab on Avaliações.
  final VoidCallback onSeeAll;

  const RecentRatingsSection({
    super.key,
    required this.movieId,
    required this.onSeeAll,
  });

  @override
  State<RecentRatingsSection> createState() => _RecentRatingsSectionState();
}

class _RecentRatingsSectionState extends State<RecentRatingsSection> {
  late final Future<Result<ActivityPage>> _activities =
      GetIt.I<GetMovieActivities>()(
        GetMovieActivitiesParams(
          movieId: widget.movieId,
          scope: FeedScope.all,
          kind: MovieActivityKind.ratings,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Result<ActivityPage>>(
      future: _activities,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result is! Success<ActivityPage>) return const SizedBox.shrink();
        final withText = result.data.activities
            .where((activity) {
              final review = activity.rating?.review?.trim();
              return activity.rating?.rating != null &&
                  review != null &&
                  review.isNotEmpty;
            })
            .take(RecentRatingsSection._maxShown)
            .toList();
        if (withText.isEmpty) return const SizedBox.shrink();

        return MovieSection(
          title: l10n?.movieRecentRatings ?? '',
          actionLabel: l10n?.movieRecentRatingsAll ?? '',
          onAction: widget.onSeeAll,
          child: Column(
            children: [
              for (final activity in withText)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RatingCard(
                    activity: activity,
                    onTap: () => context.router.push(
                      PublicProfileRoute(
                        userId: activity.actor.id,
                        displayName: activity.actor.name,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Who, the label in evidence, then the text, masked while it spoils.
class _RatingCard extends StatefulWidget {
  final Activity activity;
  final VoidCallback onTap;

  const _RatingCard({required this.activity, required this.onTap});

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activity = widget.activity;
    final rating = activity.rating!;
    final masked = rating.hasSpoiler && !_revealed;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: MuuvieRadius.largeAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MuuvieUserAvatar(
                    url: activity.actor.avatarUrl,
                    name: activity.actor.name,
                    accentColor: activity.actor.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.actor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatRelativeTime(l10n, activity.createdAt),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  MuuvieRatingBadge(rating: rating.rating!),
                ],
              ),
              const SizedBox(height: 10),
              if (masked)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(l10n?.watchLogSpoiler ?? ''),
                  onPressed: () => setState(() => _revealed = true),
                )
              else
                Text(
                  rating.review!.trim(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.45,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
