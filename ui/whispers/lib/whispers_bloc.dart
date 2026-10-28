import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network/social_network.dart';
import 'package:whispers/whispers_state.dart';

/// The Sussurros list (F6.5). A message that arrives moves its conversation
/// to the top; one from a new conversation reloads the list.
class WhispersCubit extends Cubit<WhispersState> {
  final GetConversations _getConversations;
  StreamSubscription<Message>? _incoming;

  WhispersCubit({
    required GetConversations getConversations,
    required WatchIncomingMessages watchIncomingMessages,
  }) : _getConversations = getConversations,
       super(const WhispersLoading()) {
    _incoming = watchIncomingMessages().listen(_onMessage);
    load();
  }

  Future<void> load() async {
    final result = await _getConversations();
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => WhispersSuccess(
        conversations: data.conversations,
        nextCursor: data.nextCursor,
      ),
      Failure(:final error) => WhispersError(error),
    });
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! WhispersSuccess ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getConversations(current.nextCursor);
    final latest = state;
    if (isClosed || latest is! WhispersSuccess) return;
    emit(switch (result) {
      Success(:final data) => latest.copyWith(
        conversations: [...latest.conversations, ...data.conversations],
        nextCursor: data.nextCursor,
        clearCursor: data.nextCursor == null,
        isLoadingMore: false,
      ),
      Failure() => latest.copyWith(isLoadingMore: false),
    });
  }

  /// The conversation was read on its screen.
  void markRead(int conversationId) => _update(
    conversationId,
    (conversation) => conversation.copyWith(unread: 0),
  );

  void _onMessage(Message message) {
    final current = state;
    if (current is! WhispersSuccess) return;
    final index = current.conversations.indexWhere(
      (conversation) => conversation.id == message.conversationId,
    );
    if (index < 0) {
      load();
      return;
    }
    final conversation = current.conversations[index];
    final fromOther =
        message.system || message.senderId == conversation.other.id;
    final updated = conversation.copyWith(
      lastMessage: Message(
        id: message.id,
        conversationId: message.conversationId,
        senderId: message.senderId,
        body: message.body,
        system: message.system,
        mine: !fromOther,
        createdAt: message.createdAt,
      ),
      unread: fromOther ? conversation.unread + 1 : conversation.unread,
      enabled: switch (message.systemCode) {
        SystemMessageCode.mutualLost => false,
        SystemMessageCode.mutualRestored => true,
        null => null,
      },
    );
    emit(
      current.copyWith(
        conversations: [
          updated,
          ...current.conversations.where((item) => item.id != updated.id),
        ],
      ),
    );
  }

  void _update(int conversationId, Conversation Function(Conversation) change) {
    final current = state;
    if (current is! WhispersSuccess) return;
    emit(
      current.copyWith(
        conversations: [
          for (final conversation in current.conversations)
            conversation.id == conversationId
                ? change(conversation)
                : conversation,
        ],
      ),
    );
  }

  @override
  Future<void> close() {
    _incoming?.cancel();
    return super.close();
  }
}
