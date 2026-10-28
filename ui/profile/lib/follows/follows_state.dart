import 'package:core/core.dart';
import 'package:social_network/social_network.dart';

/// One of the two lists of the follows screen.
sealed class FollowListState {
  const FollowListState();
}

class FollowListLoading extends FollowListState {
  const FollowListLoading();
}

class FollowListSuccess extends FollowListState {
  final List<FollowCard> cards;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;

  /// User ids whose follow is on its way; their button waits.
  final Set<String> busy;

  const FollowListSuccess({
    required this.cards,
    required this.page,
    required this.hasNext,
    this.isLoadingMore = false,
    this.busy = const {},
  });

  FollowListSuccess copyWith({
    List<FollowCard>? cards,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
    Set<String>? busy,
  }) => FollowListSuccess(
    cards: cards ?? this.cards,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    busy: busy ?? this.busy,
  );
}

class FollowListError extends FollowListState {
  final AppError error;

  const FollowListError(this.error);
}

/// "Seguindo" and "Seguidores recentes" of a profile (F6.3).
class FollowsState {
  final FollowListState followers;
  final FollowListState following;

  const FollowsState({
    this.followers = const FollowListLoading(),
    this.following = const FollowListLoading(),
  });

  FollowListState of(FollowList list) => switch (list) {
    FollowList.followers => followers,
    FollowList.following => following,
  };

  FollowsState withList(FollowList list, FollowListState value) =>
      switch (list) {
        FollowList.followers => FollowsState(
          followers: value,
          following: following,
        ),
        FollowList.following => FollowsState(
          followers: followers,
          following: value,
        ),
      };
}
