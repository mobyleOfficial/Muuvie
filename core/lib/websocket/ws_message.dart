enum WsMessageType {
  /// An import job changed (B3). Payload: jobId, source, status, processed, total.
  importProgress('import_progress'),

  /// A Sussurro arrived, or the user sent one from another session (B6).
  /// Payload: conversationId, messageId, senderId (empty for system
  /// messages), name, body, system, createdAt.
  message('message'),

  /// The unread badge changed. Payload: conversations, messages.
  unread('unread'),

  /// Someone followed the user. Payload: userId, name.
  newFollower('new_follower'),

  /// Someone loved one of the user's activities. Payload: activityId, userId, name.
  activityLoved('activity_loved'),

  /// Something changed in a watch party the user is in (F10.4). Payload:
  /// code, event (join, leave, message, start, closed).
  watchParty('watch_party'),
  unknown('unknown');

  final String value;

  const WsMessageType(this.value);

  static WsMessageType fromString(String? type) => switch (type) {
    'import_progress' => importProgress,
    'message' => message,
    'unread' => unread,
    'new_follower' => newFollower,
    'activity_loved' => activityLoved,
    'watch_party' => watchParty,
    _ => unknown,
  };
}

class WsMessage {
  final WsMessageType type;
  final Map<String, dynamic>? data;

  const WsMessage({required this.type, this.data});

  factory WsMessage.fromJson(Map<String, dynamic> json) => WsMessage(
    type: WsMessageType.fromString(json['type'] as String?),
    data: json['payload'] as Map<String, dynamic>?,
  );
}
