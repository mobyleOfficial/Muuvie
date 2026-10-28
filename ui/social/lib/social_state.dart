import 'package:core/core.dart';
import 'package:social_network/social_network.dart';

/// The Atts feed (F6.2) for one [scope].
sealed class SocialState {
  final FeedScope scope;

  const SocialState(this.scope);
}

class SocialLoading extends SocialState {
  const SocialLoading(super.scope);
}

class SocialSuccess extends SocialState {
  final List<Activity> activities;

  /// Null once the last page is in.
  final String? nextCursor;
  final bool isLoadingMore;

  const SocialSuccess(
    super.scope, {
    required this.activities,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null;

  SocialSuccess copyWith({
    List<Activity>? activities,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
  }) => SocialSuccess(
    scope,
    activities: activities ?? this.activities,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class SocialError extends SocialState {
  final AppError error;

  const SocialError(super.scope, this.error);
}
