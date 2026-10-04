import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:movies_ui/favorite_movies/favorite_movies_router.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:movies_ui/watch_list/watch_list_router.dart';
import 'package:user_activity/user_activities/user_activities_router.dart';
import 'package:public_profile/public_profile_info/public_profile_info_bloc.dart';
import 'package:public_profile/public_profile_info/public_profile_info_state.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:public_profile_domain/models/profile_user.dart';
import 'package:public_profile_domain/models/profile_watched_movie.dart';
import 'package:public_profile_domain/models/public_profile.dart';
import 'package:public_profile_domain/usecases/get_public_profile.dart';

class ProfileInfoTab extends StatefulWidget {
  final String userId;

  const ProfileInfoTab({super.key, required this.userId});

  @override
  State<ProfileInfoTab> createState() => _ProfileInfoTabState();
}

class _ProfileInfoTabState extends State<ProfileInfoTab> {
  late final PublicProfileInfoCubit _cubit = PublicProfileInfoCubit(
    getPublicProfile: GetIt.I<GetPublicProfile>(),
    userId: widget.userId,
  );

  bool _isFollowing = false;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<PublicProfileInfoCubit, PublicProfileInfoState>(
        builder: (context, state) => switch (state) {
          PublicProfileInfoLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          PublicProfileInfoError() => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: state.message,
            action: _cubit.reload,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          PublicProfileInfoSuccess(:final profile) => _ProfileInfoContent(
            profile: profile,
            isFollowing: _isFollowing,
            onFollowToggle: () => setState(() => _isFollowing = !_isFollowing),
          ),
        },
      ),
    );
  }
}

class _ProfileInfoContent extends StatelessWidget {
  final PublicProfile profile;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const _ProfileInfoContent({
    required this.profile,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final posterColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
      colorScheme.surfaceContainerHighest,
      colorScheme.primaryContainer,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Semantics(
            label: profile.displayName,
            image: true,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: colorScheme.secondaryContainer,
              child: ExcludeSemantics(
                child: Text(
                  profile.initials,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.displayName,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.bio,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProfileStat(
                  value: '${profile.moviesWatched.length}',
                  label: l10n?.profileMoviesWatched ?? '',
                  onTap: () => MuuvieBottomSheet.show(
                    context: context,
                    builder: (_) => _MoviesListSheet(
                      title: l10n?.profileMoviesWatchedTitle ?? '',
                      emptyMessage: l10n?.profileEmptyMoviesWatched ?? '',
                      movies: profile.moviesWatched,
                    ),
                  ),
                ),
                VerticalDivider(color: colorScheme.outlineVariant, width: 1),
                _ProfileStat(
                  value: '${profile.following.length}',
                  label: l10n?.profileFollowing ?? '',
                  onTap: () => MuuvieBottomSheet.show(
                    context: context,
                    builder: (_) => _UsersListSheet(
                      title: l10n?.profileFollowingTitle ?? '',
                      emptyMessage: l10n?.profileEmptyFollowing ?? '',
                      users: profile.following,
                    ),
                  ),
                ),
                VerticalDivider(color: colorScheme.outlineVariant, width: 1),
                _ProfileStat(
                  value: '${profile.followers.length}',
                  label: l10n?.profileFollowers ?? '',
                  onTap: () => MuuvieBottomSheet.show(
                    context: context,
                    builder: (_) => _UsersListSheet(
                      title: l10n?.profileFollowersTitle ?? '',
                      emptyMessage: l10n?.profileEmptyFollowers ?? '',
                      users: profile.followers,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onFollowToggle,
              style: isFollowing
                  ? OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      side: BorderSide(color: colorScheme.outlineVariant),
                    )
                  : OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSecondaryContainer,
                      side: BorderSide(color: colorScheme.onSecondaryContainer),
                    ),
              child: Text(
                isFollowing
                    ? (l10n?.profileFollowing ?? '')
                    : (l10n?.profileFollow ?? ''),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(
            title: l10n?.profileFavoriteMovies ?? '',
            seeAllLabel: l10n?.profileSeeAll ?? '',
            onSeeAll: () => context.router.push(
              FavoriteMoviesRoute(
                userId: profile.id,
                userName: profile.displayName,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: profile.favoriteMovies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => Semantics(
                label: profile.favoriteMovies[index].title,
                button: true,
                child: InkWell(
                  onTap: () => context.router.push(
                    MovieDetailRoute(
                      movieId: profile.favoriteMovies[index].id,
                      movieTitle: profile.favoriteMovies[index].title,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: posterColors[index],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(
            title: l10n?.profileRecentActivity ?? '',
            seeAllLabel: l10n?.profileSeeAll ?? '',
            onSeeAll: () => context.router.push(
              UserActivitiesRoute(
                userId: profile.id,
                userName: profile.displayName,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(profile.recentActivities.length, (index) {
            final activity = profile.recentActivities[index];
            return Semantics(
              label: '${activity.action} ${activity.movie}, ${activity.time}',
              child: ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        _activityIcon(activity.action),
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            children: [
                              TextSpan(text: '${activity.action} '),
                              TextSpan(
                                text: activity.movie,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activity.time,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          _SectionHeader(
            title: l10n?.profileWatchlistSection ?? '',
            seeAllLabel: l10n?.profileSeeAll ?? '',
            onSeeAll: () => context.router.push(
              WatchListRoute(userId: profile.id, userName: profile.displayName),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: profile.watchlist.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => Semantics(
                label: profile.watchlist[index].title,
                button: true,
                child: InkWell(
                  onTap: () => context.router.push(
                    MovieDetailRoute(
                      movieId: profile.watchlist[index].id,
                      movieTitle: profile.watchlist[index].title,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: posterColors[index],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static IconData _activityIcon(String action) => switch (action) {
    'Watched' => Icons.visibility,
    'Reviewed' => Icons.rate_review,
    'Added to watchlist' => Icons.bookmark_add,
    'Liked review of' => Icons.favorite,
    _ => Icons.movie,
  };
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String seeAllLabel;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.seeAllLabel,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
        ),
        Semantics(
          button: true,
          label: '$seeAllLabel $title',
          child: GestureDetector(
            onTap: onSeeAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                seeAllLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onTap;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$value $label',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetScaffold({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Material(
        color: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class _MoviesListSheet extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final List<ProfileWatchedMovie> movies;

  const _MoviesListSheet({
    required this.title,
    required this.emptyMessage,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _SheetScaffold(
      title: title,
      child: movies.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                emptyMessage,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shrinkWrap: true,
              itemCount: movies.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.router.push(
                      MovieDetailRoute(
                        movieId: movie.id,
                        movieTitle: movie.title,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: movie.posterPath.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: TmdbImageUrl.buildPosterMedium(movie.posterPath),
                                width: 48,
                                height: 72,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  width: 48,
                                  height: 72,
                                  color: colorScheme.surfaceContainerHighest,
                                ),
                                errorWidget: (_, _, _) => Container(
                                  width: 48,
                                  height: 72,
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.movie,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Container(
                                width: 48,
                                height: 72,
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.movie,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          movie.title,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _UsersListSheet extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final List<ProfileUser> users;

  const _UsersListSheet({
    required this.title,
    required this.emptyMessage,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _SheetScaffold(
      title: title,
      child: users.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                emptyMessage,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              shrinkWrap: true,
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.router.push(PublicProfileRoute(userId: user.id));
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(
                      user.initials,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    user.displayName,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
