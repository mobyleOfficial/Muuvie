import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:social/feed/activity_card.dart';
import 'package:social_network/social_network.dart';

/// What people did in a maratona (F7.6), newest first.
class ProgressFeedCubit extends Cubit<ProgressFeedState> {
  final String slug;
  final GetMaratonaProgress _getProgress;
  final ToggleActivityLove _toggleLove;

  ProgressFeedCubit({
    required this.slug,
    required GetMaratonaProgress getProgress,
    required ToggleActivityLove toggleLove,
  }) : _getProgress = getProgress,
       _toggleLove = toggleLove,
       super(const ProgressFeedState());

  Future<void> load() async {
    final result = await _getProgress(GetMaratonaProgressParams(slug: slug));
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => ProgressFeedState(
        loading: false,
        activities: data.activities,
        nextCursor: data.nextCursor,
      ),
      Failure(:final error) => ProgressFeedState(loading: false, error: error),
    });
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    final result = await _getProgress(
      GetMaratonaProgressParams(slug: slug, cursor: cursor),
    );
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => state.copyWith(
        activities: [...state.activities, ...data.activities],
        nextCursor: data.nextCursor,
        clearCursor: data.nextCursor == null,
        loadingMore: false,
      ),
      Failure() => state.copyWith(loadingMore: false),
    });
  }

  /// Optimistic "amei", undone when the server refuses it.
  Future<void> toggleLove(Activity activity) async {
    final loved = !activity.loved;
    _replace(
      activity.copyWith(loved: loved, loves: activity.loves + (loved ? 1 : -1)),
    );
    final result = await _toggleLove(
      ToggleLoveParams(activityId: activity.id, love: loved),
    );
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        _replace(activity.copyWith(loved: data.loved, loves: data.loves));
      case Failure():
        _replace(activity);
    }
  }

  void _replace(Activity activity) => emit(
    state.copyWith(
      activities: [
        for (final item in state.activities)
          item.id == activity.id ? activity : item,
      ],
    ),
  );
}

class ProgressFeedState {
  final bool loading;
  final bool loadingMore;
  final AppError? error;
  final List<Activity> activities;
  final String? nextCursor;

  const ProgressFeedState({
    this.loading = true,
    this.loadingMore = false,
    this.error,
    this.activities = const [],
    this.nextCursor,
  });

  ProgressFeedState copyWith({
    List<Activity>? activities,
    String? nextCursor,
    bool clearCursor = false,
    bool? loadingMore,
  }) => ProgressFeedState(
    loading: loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error,
    activities: activities ?? this.activities,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
  );
}

/// The activity section of the About tab. Lives in a parent scroll view, so it
/// renders as a column with a "load more" button instead of its own list.
class ProgressFeed extends StatefulWidget {
  final String slug;

  const ProgressFeed({super.key, required this.slug});

  @override
  State<ProgressFeed> createState() => _ProgressFeedState();
}

class _ProgressFeedState extends State<ProgressFeed> {
  late final ProgressFeedCubit _cubit = ProgressFeedCubit(
    slug: widget.slug,
    getProgress: GetIt.I<GetMaratonaProgress>(),
    toggleLove: GetIt.I<ToggleActivityLove>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ProgressFeedCubit, ProgressFeedState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.loading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: MuuvieActivityIndicator()),
          );
        }
        if (state.activities.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              state.error != null
                  ? l10n?.emptyStateErrorMessage ?? ''
                  : l10n?.maratonaProgressEmpty ?? '',
              style: textTheme.bodyMedium,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final activity in state.activities)
              ActivityCard(
                activity: activity,
                onOpenActor: () => context.router.push(
                  PublicProfileRoute(
                    userId: activity.actor.id,
                    displayName: activity.actor.name,
                  ),
                ),
                onOpenMovie: (movie) => context.router.push(
                  MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
                ),
                onOpenShelf: (_) {},
                onOpenLocadora: (_) {},
                onToggleLove: () => _cubit.toggleLove(activity),
              ),
            if (state.nextCursor != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: state.loadingMore
                      ? const MuuvieActivityIndicator()
                      : TextButton(
                          onPressed: _cubit.loadMore,
                          child: Text(l10n?.maratonaLoadMore ?? ''),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }
}
