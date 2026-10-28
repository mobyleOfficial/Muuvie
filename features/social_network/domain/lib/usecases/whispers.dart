import 'package:core/core.dart';
import 'package:social_network_domain/models/models.dart';
import 'package:social_network_domain/repositories/social_network_repository.dart';

/// Longest Sussurro the server takes.
const whisperMaxLength = 2000;

/// The Sussurros list (F6.5), latest message first.
class GetConversations extends UseCase<String, Result<ConversationPage>> {
  final SocialNetworkRepository _repository;

  GetConversations(this._repository);

  /// [cursor] loads the next page.
  @override
  Future<Result<ConversationPage>> call([String? cursor]) =>
      _repository.getConversations(cursor: cursor);
}

class GetConversation extends UseCase<int, Result<Conversation>> {
  final SocialNetworkRepository _repository;

  GetConversation(this._repository);

  @override
  Future<Result<Conversation>> call([int? conversationId]) =>
      _repository.getConversation(conversationId!);
}

/// The conversation with a user, to open it from their profile. Fails with
/// `notFound` while they never talked.
class GetConversationWith extends UseCase<String, Result<Conversation>> {
  final SocialNetworkRepository _repository;

  GetConversationWith(this._repository);

  @override
  Future<Result<Conversation>> call([String? userId]) =>
      _repository.getConversationWith(userId!);
}

class GetMessagesParams {
  final int conversationId;
  final String? cursor;

  const GetMessagesParams({required this.conversationId, this.cursor});
}

/// Messages of a conversation, newest first.
class GetMessages extends UseCase<GetMessagesParams, Result<MessagePage>> {
  final SocialNetworkRepository _repository;

  GetMessages(this._repository);

  @override
  Future<Result<MessagePage>> call([GetMessagesParams? params]) {
    final value = params!;
    return _repository.getMessages(value.conversationId, cursor: value.cursor);
  }
}

class SendWhisperParams {
  final String userId;
  final String body;

  const SendWhisperParams({required this.userId, required this.body});
}

/// Sends a Sussurro (F6.5); only between mutuals. Blank or too long messages
/// fail with `badRequest` without calling the server.
class SendWhisper extends UseCase<SendWhisperParams, Result<Message>> {
  final SocialNetworkRepository _repository;

  SendWhisper(this._repository);

  @override
  Future<Result<Message>> call([SendWhisperParams? params]) async {
    final value = params!;
    final body = value.body.trim();
    if (body.isEmpty || body.length > whisperMaxLength) {
      return const Failure(AppError.badRequest);
    }
    return _repository.sendMessage(value.userId, body);
  }
}

class MarkConversationRead extends UseCase<int, Result<UnreadCount>> {
  final SocialNetworkRepository _repository;

  MarkConversationRead(this._repository);

  @override
  Future<Result<UnreadCount>> call([int? conversationId]) =>
      _repository.markRead(conversationId!);
}

class GetUnreadCount extends UseCase<void, Result<UnreadCount>> {
  final SocialNetworkRepository _repository;

  GetUnreadCount(this._repository);

  @override
  Future<Result<UnreadCount>> call([void params]) =>
      _repository.getUnreadCount();
}

/// Sussurros as they arrive in real time.
class WatchIncomingMessages {
  final SocialNetworkRepository _repository;

  WatchIncomingMessages(this._repository);

  Stream<Message> call() => _repository.watchMessages();
}

/// The badge (F6.6) each time it changes on the server.
class WatchUnreadCount {
  final SocialNetworkRepository _repository;

  WatchUnreadCount(this._repository);

  Stream<UnreadCount> call() => _repository.watchUnreadCount();
}
