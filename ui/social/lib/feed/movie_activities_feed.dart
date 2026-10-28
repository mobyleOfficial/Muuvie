import 'package:auto_route/auto_route.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:locadoras_ui/locadoras_router.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:social/feed/activity_card.dart';
import 'package:social_network/social_network.dart';

/// Everything people did with a movie (B13.3): the Comunidade tab of the
/// movie detail, newest first, filtered by kind (Avaliações, Atualizações or
/// Tudo) and by people (Todos, Seguindo or Só eu).
class MovieActivitiesCubit extends Cubit<MovieActivitiesState> {
  final int movieId;
  final GetMovieActivities _getActivities;
  final ToggleActivityLove _toggleLove;

  MovieActivitiesCubit({
    required this.movieId,
    MovieActivityKind? kind,
    required GetMovieActivities getActivities,
    required ToggleActivityLove toggleLove,
  }) : _getActivities = getActivities,
       _toggleLove = toggleLove,
       super(MovieActivitiesState(kind: kind));

  Future<void> setFilters({MovieActivityKind? kind, FeedScope? scope}) {
    emit(
      MovieActivitiesState(
        kind: kind ?? state.kind,
        scope: scope ?? state.scope,
      ),
    );
    return load();
  }

  /// [kind] null is Tudo, so it cannot go through [setFilters].
  Future<void> showEverything() {
    emit(MovieActivitiesState(scope: state.scope));
    return load();
  }

  Future<void> load() async {
    emit(MovieActivitiesState(kind: state.kind, scope: state.scope));
    final result = await _getActivities(
      GetMovieActivitiesParams(
        movieId: movieId,
        scope: state.scope,
        kind: state.kind,
      ),
    );
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => state.copyWith(
        loading: false,
        activities: data.activities,
        nextCursor: data.nextCursor,
      ),
      Failure(:final error) => state.copyWith(loading: false, error: error),
    });
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    final result = await _getActivities(
      GetMovieActivitiesParams(
        movieId: movieId,
        cursor: cursor,
        scope: state.scope,
        kind: state.kind,
      ),
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

class MovieActivitiesState {
  final bool loading;
  final bool loadingMore;
  final AppError? error;
  final List<Activity> activities;
  final String? nextCursor;

  /// Null is Tudo.
  final MovieActivityKind? kind;

  /// [FeedScope.all] is everyone the user may see.
  final FeedScope scope;

  const MovieActivitiesState({
    this.loading = true,
    this.loadingMore = false,
    this.error,
    this.activities = const [],
    this.nextCursor,
    this.kind,
    this.scope = FeedScope.all,
  });

  MovieActivitiesState copyWith({
    bool? loading,
    AppError? error,
    List<Activity>? activities,
    String? nextCursor,
    bool clearCursor = false,
    bool? loadingMore,
  }) => MovieActivitiesState(
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error ?? this.error,
    activities: activities ?? this.activities,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    kind: kind,
    scope: scope,
  );
}

class MovieActivitiesFeed extends StatefulWidget {
  /// Database id of the movie.
  final int movieId;

  /// Each new value selects that kind ("Ver todas" of the recent ratings).
  final ValueListenable<MovieActivityKind?>? kindRequests;

  const MovieActivitiesFeed({
    super.key,
    required this.movieId,
    this.kindRequests,
  });

  @override
  State<MovieActivitiesFeed> createState() => _MovieActivitiesFeedState();
}

class _MovieActivitiesFeedState extends State<MovieActivitiesFeed> {
  late final MovieActivitiesCubit _cubit = MovieActivitiesCubit(
    movieId: widget.movieId,
    kind: widget.kindRequests?.value,
    getActivities: GetIt.I<GetMovieActivities>(),
    toggleLove: GetIt.I<ToggleActivityLove>(),
  )..load();

  @override
  void initState() {
    super.initState();
    widget.kindRequests?.addListener(_onKindRequest);
  }

  @override
  void dispose() {
    widget.kindRequests?.removeListener(_onKindRequest);
    _cubit.close();
    super.dispose();
  }

  void _onKindRequest() => _setKind(widget.kindRequests?.value);

  void _setKind(MovieActivityKind? kind) =>
      kind == null ? _cubit.showEverything() : _cubit.setFilters(kind: kind);

  /// Seguindo and Só eu need an account.
  Future<void> _setScope(FeedScope scope) async {
    if (scope != FeedScope.all && !await AuthGate.check(context)) return;
    await _cubit.setFilters(scope: scope);
  }

  Future<void> _toggleLove(Activity activity) async {
    final authenticated = await AuthGate.check(context);
    if (authenticated) await _cubit.toggleLove(activity);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieActivitiesCubit, MovieActivitiesState>(
      bloc: _cubit,
      builder: (context, state) => Column(
        children: [
          _Filters(state: state, onKind: _setKind, onScope: _setScope),
          Expanded(child: _list(context, state)),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, MovieActivitiesState state) {
    final l10n = AppLocalizations.of(context);
    if (state.loading) {
      return const Center(child: MuuvieActivityIndicator());
    }
    if (state.activities.isEmpty) {
      return state.error != null
          ? MuuvieEmptyState(
              illustration: MuuvieIllustration.error,
              title: l10n?.emptyStateErrorTitle ?? '',
              message: l10n?.emptyStateErrorMessage ?? '',
              action: _cubit.load,
              actionLabel: l10n?.emptyStateRetry ?? '',
            )
          : MuuvieEmptyState(
              illustration: MuuvieIllustration.movies,
              title: l10n?.movieDetailRecordsTab ?? '',
              message: l10n?.movieRecordsEmpty ?? '',
            );
    }
    return RefreshIndicator(
      onRefresh: _cubit.load,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 400) _cubit.loadMore();
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 32),
          itemCount: state.activities.length + (state.loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.activities.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: MuuvieActivityIndicator()),
              );
            }
            final activity = state.activities[index];
            return ActivityCard(
              key: ValueKey(activity.id),
              activity: activity,
              onOpenActor: () => context.router.push(
                PublicProfileRoute(
                  userId: activity.actor.id,
                  displayName: activity.actor.name,
                ),
              ),
              // Already on this movie.
              onOpenMovie: (_) {},
              onOpenShelf: (shelf) => context.router.push(
                ShelfDetailRoute(
                  shelfId: shelf.id,
                  shelfName: shelf.name,
                  shelfColor: shelf.color,
                ),
              ),
              onOpenLocadora: (locadora) => context.router.push(
                LocadoraDetailRoute(
                  locadoraId: locadora.id,
                  locadoraName: locadora.name,
                  onOpenShelf: (context, shelf) => context.router.push(
                    ShelfDetailRoute(
                      shelfId: shelf.id,
                      shelfName: shelf.name,
                      shelfColor: shelf.color,
                    ),
                  ),
                  onOpenOwner: (context, locadora) => context.router.push(
                    PublicProfileRoute(
                      userId: locadora.ownerId,
                      displayName: locadora.ownerUsername,
                    ),
                  ),
                ),
              ),
              onOpenMaratona: (maratona) => context.router.push(
                MaratonaDetailRoute(slug: maratona.slug, title: maratona.title),
              ),
              onOpenCineClube: (cineclube) => context.router.push(
                CineClubeDetailRoute(
                  slug: cineclube.slug,
                  title: cineclube.title,
                ),
              ),
              onToggleLove: () => _toggleLove(activity),
            );
          },
        ),
      ),
    );
  }
}

/// Kind (Avaliações, Atualizações, Tudo) and people (Todos, Seguindo, Só eu),
/// as the Atts chips.
class _Filters extends StatelessWidget {
  final MovieActivitiesState state;
  final ValueChanged<MovieActivityKind?> onKind;
  final ValueChanged<FeedScope> onScope;

  const _Filters({
    required this.state,
    required this.onKind,
    required this.onScope,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kinds = <(MovieActivityKind?, String)>[
      (MovieActivityKind.ratings, l10n?.movieActivitiesRatings ?? ''),
      (MovieActivityKind.updates, l10n?.movieActivitiesUpdates ?? ''),
      (null, l10n?.movieActivitiesEverything ?? ''),
    ];
    final scopes = <(FeedScope, String)>[
      (FeedScope.all, l10n?.movieActivitiesEveryone ?? ''),
      (FeedScope.following, l10n?.movieActivitiesFollowing ?? ''),
      (FeedScope.me, l10n?.movieActivitiesOnlyMe ?? ''),
    ];

    Widget row(List<Widget> chips) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          for (final chip in chips)
            Padding(padding: const EdgeInsets.only(right: 8), child: chip),
        ],
      ),
    );

    return Column(
      children: [
        row([
          for (final (kind, label) in kinds)
            ChoiceChip(
              label: Text(label),
              selected: state.kind == kind,
              onSelected: (_) => onKind(kind),
            ),
        ]),
        row([
          for (final (scope, label) in scopes)
            ChoiceChip(
              label: Text(label),
              selected: state.scope == scope,
              onSelected: (_) => onScope(scope),
            ),
        ]),
        const SizedBox(height: 4),
      ],
    );
  }
}
