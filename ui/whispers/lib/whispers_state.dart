import 'package:core/core.dart';
import 'package:social_network/social_network.dart';

/// The Sussurros list (F6.5).
sealed class WhispersState {
  const WhispersState();
}

class WhispersLoading extends WhispersState {
  const WhispersLoading();
}

class WhispersSuccess extends WhispersState {
  /// Latest message first.
  final List<Conversation> conversations;
  final String? nextCursor;
  final bool isLoadingMore;

  const WhispersSuccess({
    required this.conversations,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null;

  WhispersSuccess copyWith({
    List<Conversation>? conversations,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
  }) => WhispersSuccess(
    conversations: conversations ?? this.conversations,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class WhispersError extends WhispersState {
  final AppError error;

  const WhispersError(this.error);
}
