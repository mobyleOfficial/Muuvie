import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/profile_bloc.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:profile_ui/profile_state.dart';

import 'package:movies_ui/movie_detail/movie_detail_router.dart';

class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) => switch (state) {
        ProfileSuccess(:final profile) => _ProfileInfoContent(
            profile: profile,
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _ProfileInfoContent extends StatelessWidget {
  final UserProfile profile;

  const _ProfileInfoContent({required this.profile});

  Future<void> _openEditProfile(BuildContext context) async {
    final result = await context.router.root.push<UserProfile?>(
      EditProfileRoute(
        initialPhotoUrl: profile.photoUrl,
        initialUsername: profile.username,
        initialBio: profile.bio,
        initialIsScraping: profile.isScraping,
      ),
    );

    if (result != null && context.mounted) {
      context.read<ProfileCubit>().updateProfile(result);
    }
  }

  void _openRecentMoviesSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    MuuvieBottomSheet.show(
      context: context,
      builder: (_) => _MoviesListSheet(
        title: l10n?.profileMoviesWatchedTitle ?? '',
        emptyMessage: l10n?.profileEmptyMoviesWatched ?? '',
        movies: profile.recentMovies,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Semantics(
            label: l10n?.profile ?? '',
            image: true,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: colorScheme.secondaryContainer,
              backgroundImage: profile.photoUrl.isNotEmpty
                  ? NetworkImage(profile.photoUrl)
                  : null,
              child: profile.photoUrl.isEmpty
                  ? ExcludeSemantics(
                      child: Icon(
                        Icons.person,
                        size: 52,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.username,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.bio,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProfileStat(
                  value: '${profile.moviesWatchedCount}',
                  label: l10n?.profileMoviesWatched ?? '',
                  onTap: () => _openRecentMoviesSheet(context),
                ),
                VerticalDivider(color: colorScheme.outlineVariant, width: 1),
                _ProfileStat(
                  value: '${profile.followingCount}',
                  label: l10n?.profileFollowing ?? '',
                  onTap: () {},
                ),
                VerticalDivider(color: colorScheme.outlineVariant, width: 1),
                _ProfileStat(
                  value: '${profile.followersCount}',
                  label: l10n?.profileFollowers ?? '',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openEditProfile(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSecondaryContainer,
                side: BorderSide(color: colorScheme.onSecondaryContainer),
              ),
              child: Text(l10n?.profileEditProfile ?? ''),
            ),
          ),
          const SizedBox(height: 28),
          if (profile.recentMovies.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n?.profileRecentMovies ?? '',
                style: textTheme.titleSmall
                    ?.copyWith(color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: profile.recentMovies.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final movie = profile.recentMovies[index];
                  return Semantics(
                    label: movie.title,
                    button: true,
                    child: InkWell(
                      onTap: () => context.router.push(
                        MovieDetailRoute(
                          movieId: movie.id,
                          movieTitle: movie.title,
                          filmowId: movie.filmowId,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: movie.posterPath.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: TmdbImageUrl.buildPosterMedium(movie.posterPath),
                                width: 80,
                                height: 120,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  width: 80,
                                  height: 120,
                                  color: colorScheme.surfaceContainerHighest,
                                ),
                                errorWidget: (_, _, _) => Container(
                                  width: 80,
                                  height: 120,
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.movie,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 120,
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.movie,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
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
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
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
  final List<Movie> movies;

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
                        filmowId: movie.filmowId,
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
