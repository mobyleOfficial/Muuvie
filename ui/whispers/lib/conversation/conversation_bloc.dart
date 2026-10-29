import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network/social_network.dart';
import 'package:whispers/conversation/conversation_state.dart';

/// A conversation with [otherUserId] (F6.5). Messages arrive in real time on
/// the WebSocket and are marked read while the screen is open.
class ConversationCubit extends Cubit<ConversationState> {
  final String otherUserId;
  final int? _conversationId;
  final GetConversation _getConversation;
  final GetConversationWith _getConversationWith;
  final GetMessages _getMessages;
  final SendWhisper _sendWhisper;
  final MarkConversationRead _markRead;
  final GetFollowStatus _getFollowStatus;
  StreamSubscription<Message>? _incoming;

  ConversationCubit({
    required this.otherUserId,
    int? conversationId,
    required GetConversation getConversation,
    required GetConversationWith getConversationWith,
    required GetMessages getMessages,
    required SendWhisper sendWhisper,
    required MarkConversationRead markRead,
    required GetFollowStatus getFollowStatus,
    required WatchIncomingMessages watchIncomingMessages,
  }) : _conversationId = conversationId,
       _getConversation = getConversation,
       _getConversationWith = getConversationWith,
       _getMessages = getMessages,
       _sendWhisper = sendWhisper,
       _markRead = markRead,
       _getFollowStatus = getFollowStatus,
       super(const ConversationLoading()) {
    _incoming = watchIncomingMessages().listen(_onMessage);
    load();
  }

  Future<void> load() async {
    if (state is ConversationError) emit(const ConversationLoading());
    final id = _conversationId;
    final result = id == null
        ? await _getConversationWith(otherUserId)
        : await _getConversation(id);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        await _loadMessages(data);
      case Failure(error: AppError.notFound) when id == null:
        // They never talked: the conversation starts with the first message.
        final status = await _getFollowStatus(otherUserId);
        if (isClosed) return;
        emit(
          ConversationReady(
            enabled: status is Success<FollowStatus> && status.data.mutual,
          ),
        );
      case Failure(:final error):
        emit(ConversationError(error));
    }
  }

  Future<void> loadOlder() async {
    final current = state;
    final conversation = current is ConversationReady
        ? current.conversation
        : null;
    if (current is! ConversationReady ||
        conversation == null ||
        !current.hasOlder ||
        current.isLoadingOlder) {
      return;
    }
    emit(current.copyWith(isLoadingOlder: true));
    final result = await _getMessages(
      GetMessagesParams(
        conversationId: conversation.id,
        cursor: current.nextCursor,
      ),
    );
    final latest = state;
    if (isClosed || latest is! ConversationReady) return;
    emit(switch (result) {
      Success(:final data) => latest.copyWith(
        messages: [...latest.messages, ...data.messages],
        nextCursor: data.nextCursor,
        clearCursor: data.nextCursor == null,
        isLoadingOlder: false,
      ),
      Failure() => latest.copyWith(isLoadingOlder: false),
    });
  }

  /// Sends [text]; answers the error, or null when it went.
  Future<AppError?> send(String text) async {
    final current = state;
    if (current is! ConversationReady || current.isSending) return null;
    emit(current.copyWith(isSending: true));
    final result = await _sendWhisper(
      SendWhisperParams(userId: otherUserId, body: text),
    );
    final latest = state;
    if (isClosed || latest is! ConversationReady) return null;
    switch (result) {
      case Success(:final data):
        final sent = _asSeen(data);
        Telemetry.analytics.logEvent('whisper_sent');
        var updated = latest.copyWith(
          messages: _withMessage(latest.messages, sent),
          isSending: false,
        );
        if (latest.conversation == null) {
          // The first message created the conversation.
          final conversation = await _getConversation(data.conversationId);
          if (isClosed) return null;
          if (conversation is Success<Conversation>) {
            updated = updated.copyWith(conversation: conversation.data);
          }
        }
        emit(updated);
        return null;
      case Failure(:final error):
        emit(
          latest.copyWith(
            isSending: false,
            // Not mutuals anymore: the server refused, so the input closes.
            enabled: error == AppError.forbidden ? false : null,
          ),
        );
        return error;
    }
  }

  Future<void> _loadMessages(Conversation conversation) async {
    final result = await _getMessages(
      GetMessagesParams(conversationId: conversation.id),
    );
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(
          ConversationReady(
            conversation: conversation,
            enabled: conversation.enabled,
            messages: data.messages,
            nextCursor: data.nextCursor,
          ),
        );
        if (conversation.unread > 0) _markRead(conversation.id);
      case Failure(:final error):
        emit(ConversationError(error));
    }
  }

  void _onMessage(Message message) {
    final current = state;
    if (current is! ConversationReady) return;
    final conversation = current.conversation;
    final belongs = conversation != null
        ? message.conversationId == conversation.id
        // Before the first message, the other one may start it.
        : message.senderId == otherUserId;
    if (!belongs) return;
    final seen = _asSeen(message);
    emit(
      current.copyWith(
        messages: _withMessage(current.messages, seen),
        enabled: switch (message.systemCode) {
          SystemMessageCode.mutualLost => false,
          SystemMessageCode.mutualRestored => true,
          null => null,
        },
      ),
    );
    if (conversation == null) {
      _loadConversation(message.conversationId);
    } else if (!seen.mine) {
      _markRead(conversation.id);
    }
  }

  Future<void> _loadConversation(int conversationId) async {
    final result = await _getConversation(conversationId);
    final latest = state;
    if (isClosed || latest is! ConversationReady) return;
    if (result is Success<Conversation>) {
      emit(latest.copyWith(conversation: result.data));
      _markRead(conversationId);
    }
  }

  /// The WebSocket does not say whose a message is: mine unless it came
  /// from the other member or from the system.
  Message _asSeen(Message message) => Message(
    id: message.id,
    conversationId: message.conversationId,
    senderId: message.senderId,
    body: message.body,
    system: message.system,
    mine: !message.system && message.senderId != otherUserId,
    createdAt: message.createdAt,
  );

  /// Adds [message] on top unless it is already there (the WebSocket echoes
  /// what this screen sent).
  List<Message> _withMessage(List<Message> messages, Message message) =>
      messages.any((item) => item.id == message.id)
      ? messages
      : [message, ...messages];

  @override
  Future<void> close() {
    _incoming?.cancel();
    return super.close();
  }
}
