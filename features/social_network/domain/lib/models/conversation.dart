import 'package:social_network_domain/models/social_user.dart';

/// Codes the backend sends as the body of a system message.
enum SystemMessageCode {
  /// One of the two stopped following the other: the conversation is read-only.
  mutualLost('mutual_lost'),

  /// They follow each other again.
  mutualRestored('mutual_restored');

  final String wireValue;

  const SystemMessageCode(this.wireValue);

  static SystemMessageCode? fromWireValue(String? value) =>
      values.where((code) => code.wireValue == value).firstOrNull;
}

/// A Sussurro (F6.5). System messages have no [senderId]; their [body] is a
/// [SystemMessageCode] wire value.
class Message {
  final int id;
  final int conversationId;
  final String? senderId;
  final String body;
  final bool system;

  /// Sent by the current user.
  final bool mine;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    this.senderId,
    required this.body,
    this.system = false,
    this.mine = false,
    required this.createdAt,
  });

  SystemMessageCode? get systemCode =>
      system ? SystemMessageCode.fromWireValue(body) : null;
}

/// A conversation with [other]. Only [enabled] while both follow each other.
class Conversation {
  final int id;
  final SocialUser other;
  final bool enabled;
  final Message? lastMessage;
  final int unread;
  final DateTime lastMessageAt;

  const Conversation({
    required this.id,
    required this.other,
    required this.enabled,
    this.lastMessage,
    this.unread = 0,
    required this.lastMessageAt,
  });

  Conversation copyWith({Message? lastMessage, int? unread, bool? enabled}) =>
      Conversation(
        id: id,
        other: other,
        enabled: enabled ?? this.enabled,
        lastMessage: lastMessage ?? this.lastMessage,
        unread: unread ?? this.unread,
        lastMessageAt: lastMessage?.createdAt ?? lastMessageAt,
      );
}

class ConversationPage {
  final List<Conversation> conversations;
  final String? nextCursor;

  const ConversationPage({required this.conversations, this.nextCursor});
}

/// Messages newest first; [nextCursor] loads older ones.
class MessagePage {
  final List<Message> messages;
  final String? nextCursor;

  const MessagePage({required this.messages, this.nextCursor});
}

/// The Sussurros badge (F6.6): conversations with something unread, and
/// unread messages in total.
class UnreadCount {
  final int conversations;
  final int messages;

  const UnreadCount({required this.conversations, required this.messages});

  static const zero = UnreadCount(conversations: 0, messages: 0);
}
