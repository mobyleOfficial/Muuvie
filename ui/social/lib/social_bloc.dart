import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/social_state.dart';
import 'package:social_network/social_network.dart';

/// The Atts feed (F6.2): one scope at a time, loaded page by page, with
/// optimistic "amei" and hiding of my own activities.
class SocialCubit extends Cubit<SocialState> {
  final GetFeed _getFeed;
  final ToggleActivityLove _toggleLove;
  final HideActivity _hideActivity;

  SocialCubit({
    required GetFeed getFeed,
    required ToggleActivityLove toggleLove,
    required HideActivity hideActivity,
    FeedScope scope = FeedScope.all,
  }) : _getFeed = getFeed,
       _toggleLove = toggleLove,
       _hideActivity = hideActivity,
       super(SocialLoading(scope)) {
    _load(scope);
  }

  Future<void> selectScope(FeedScope scope) async {
    if (scope == state.scope && state is! SocialError) return;
    emit(SocialLoading(scope));
    await _load(scope);
  }

  /// Pull to refresh: keeps the list on screen until the first page arrives.
  Future<void> refresh() => _load(state.scope);

  Future<void> loadMore() async {
    final current = state;
    if (current is! SocialSuccess ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getFeed(
      GetFeedParams(scope: current.scope, cursor: current.nextCursor),
    );
    final latest = state;
    if (isClosed || latest is! SocialSuccess || latest.scope != current.scope) {
      return;
    }
    switch (result) {
      case Success(:final data):
        emit(
          latest.copyWith(
            activities: [...latest.activities, ...data.activities],
            nextCursor: data.nextCursor,
            clearCursor: data.nextCursor == null,
            isLoadingMore: false,
          ),
        );
      case Failure():
        emit(latest.copyWith(isLoadingMore: false));
    }
  }

  /// Flips the "amei" right away and settles it with the server's count.
  Future<void> toggleLove(Activity activity) async {
    final love = !activity.loved;
    _replace(
      activity.id,
      (item) => item.copyWith(loved: love, loves: item.loves + (love ? 1 : -1)),
    );
    final result = await _toggleLove(
      ToggleLoveParams(activityId: activity.id, love: love),
    );
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        _replace(
          activity.id,
          (item) => item.copyWith(loved: data.loved, loves: data.loves),
        );
      case Failure():
        _replace(
          activity.id,
          (item) => item.copyWith(loved: activity.loved, loves: activity.loves),
        );
    }
  }

  /// Hides or shows one of my activities; false when it failed.
  Future<bool> toggleHidden(Activity activity) async {
    final hidden = !activity.hidden;
    final result = await _hideActivity(
      HideActivityParams(activityId: activity.id, hidden: hidden),
    );
    if (isClosed || result is Failure) return false;
    final current = state;
    if (current is SocialSuccess && current.scope != FeedScope.me && hidden) {
      // Outside "Só eu" a hidden activity leaves the list, as it does on the server.
      emit(
        current.copyWith(
          activities: current.activities
              .where((item) => item.id != activity.id)
              .toList(),
        ),
      );
    } else {
      _replace(activity.id, (item) => item.copyWith(hidden: hidden));
    }
    return true;
  }

  Future<void> _load(FeedScope scope) async {
    final result = await _getFeed(GetFeedParams(scope: scope));
    if (isClosed || state.scope != scope) return;
    emit(switch (result) {
      Success(:final data) => SocialSuccess(
        scope,
        activities: data.activities,
        nextCursor: data.nextCursor,
      ),
      Failure(:final error) => SocialError(scope, error),
    });
  }

  void _replace(int activityId, Activity Function(Activity) update) {
    final current = state;
    if (current is! SocialSuccess) return;
    emit(
      current.copyWith(
        activities: [
          for (final item in current.activities)
            item.id == activityId ? update(item) : item,
        ],
      ),
    );
  }
}
