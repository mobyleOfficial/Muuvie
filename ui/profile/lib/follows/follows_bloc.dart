import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_ui/follows/follows_state.dart';
import 'package:social_network/social_network.dart';

/// Followers and following of [userId] (F6.3), loaded page by page. Each row
/// can be followed, followed back or unfollowed from the list.
class FollowsCubit extends Cubit<FollowsState> {
  final String userId;
  final GetFollowList _getFollowList;
  final SetFollowing _setFollowing;

  FollowsCubit({
    required this.userId,
    required GetFollowList getFollowList,
    required SetFollowing setFollowing,
  }) : _getFollowList = getFollowList,
       _setFollowing = setFollowing,
       super(const FollowsState()) {
    for (final list in FollowList.values) {
      _load(list);
    }
  }

  Future<void> refresh(FollowList list) => _load(list);

  Future<void> loadMore(FollowList list) async {
    final current = state.of(list);
    if (current is! FollowListSuccess ||
        !current.hasNext ||
        current.isLoadingMore) {
      return;
    }
    emit(state.withList(list, current.copyWith(isLoadingMore: true)));
    final result = await _getFollowList(
      GetFollowListParams(userId: userId, list: list, page: current.page + 1),
    );
    final latest = state.of(list);
    if (isClosed || latest is! FollowListSuccess) return;
    emit(
      state.withList(list, switch (result) {
        Success(:final data) => latest.copyWith(
          cards: [...latest.cards, ...data.cards],
          page: data.page,
          hasNext: data.hasNext,
          isLoadingMore: false,
        ),
        Failure() => latest.copyWith(isLoadingMore: false),
      }),
    );
  }

  /// Follows or unfollows the user of [card], in both lists. Answers the
  /// error, or null when it worked.
  Future<AppError?> toggleFollow(FollowCard card) async {
    final target = card.user.id;
    _setBusy(target, true);
    final result = await _setFollowing(
      SetFollowingParams(userId: target, follow: !card.status.following),
    );
    if (isClosed) return null;
    _setBusy(target, false);
    switch (result) {
      case Success(:final data):
        for (final list in FollowList.values) {
          final current = state.of(list);
          if (current is! FollowListSuccess) continue;
          emit(
            state.withList(
              list,
              current.copyWith(
                cards: [
                  for (final item in current.cards)
                    item.user.id == target ? item.copyWith(status: data) : item,
                ],
              ),
            ),
          );
        }
        return null;
      case Failure(:final error):
        return error;
    }
  }

  Future<void> _load(FollowList list) async {
    final result = await _getFollowList(
      GetFollowListParams(userId: userId, list: list),
    );
    if (isClosed) return;
    emit(
      state.withList(list, switch (result) {
        Success(:final data) => FollowListSuccess(
          cards: data.cards,
          page: data.page,
          hasNext: data.hasNext,
        ),
        Failure(:final error) => FollowListError(error),
      }),
    );
  }

  void _setBusy(String target, bool busy) {
    for (final list in FollowList.values) {
      final current = state.of(list);
      if (current is! FollowListSuccess) continue;
      final ids = {...current.busy};
      busy ? ids.add(target) : ids.remove(target);
      emit(state.withList(list, current.copyWith(busy: ids)));
    }
  }
}
