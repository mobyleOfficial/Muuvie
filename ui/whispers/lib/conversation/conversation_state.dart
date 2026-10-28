import 'package:core/core.dart';
import 'package:social_network/social_network.dart';

/// A conversation with one mutual (F6.5).
sealed class ConversationState {
  const ConversationState();
}

class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

class ConversationReady extends ConversationState {
  /// Null until the first message: the server creates it then.
  final Conversation? conversation;

  /// Only mutuals can send; the history stays readable when the follow ends.
  final bool enabled;

  /// Newest first.
  final List<Message> messages;
  final String? nextCursor;
  final bool isLoadingOlder;
  final bool isSending;

  const ConversationReady({
    this.conversation,
    required this.enabled,
    this.messages = const [],
    this.nextCursor,
    this.isLoadingOlder = false,
    this.isSending = false,
  });

  bool get hasOlder => nextCursor != null;

  ConversationReady copyWith({
    Conversation? conversation,
    bool? enabled,
    List<Message>? messages,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingOlder,
    bool? isSending,
  }) => ConversationReady(
    conversation: conversation ?? this.conversation,
    enabled: enabled ?? this.enabled,
    messages: messages ?? this.messages,
    nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
    isSending: isSending ?? this.isSending,
  );
}

class ConversationError extends ConversationState {
  final AppError error;

  const ConversationError(this.error);
}
