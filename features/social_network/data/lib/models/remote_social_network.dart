import 'package:core/core.dart';
import 'package:social_network_domain/models/models.dart';

/// JSON of the v1 social endpoints (backend README, "Feed, follows, Sussurros
/// and push") and of their WebSocket events to domain models.
abstract final class RemoteSocialNetwork {
  static SocialUser user(Map<String, dynamic> json) => SocialUser(
    id: json['id'] as String? ?? '',
    username: json['username'] as String? ?? '',
    handle: json['handle'] as String?,
    displayName: json['displayName'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    accentColor: json['accentColor'] as String?,
  );

  static ActivityPage activityPage(Map<String, dynamic> json) => ActivityPage(
    activities: _list(
      json['results'],
    ).map(activity).whereType<Activity>().toList(),
    nextCursor: json['nextCursor'] as String?,
  );

  /// Null for a type this version of the app does not know yet.
  static Activity? activity(Map<String, dynamic> json) {
    final type = ActivityType.fromWireValue(json['type'] as String?);
    if (type == null) return null;
    final payload = _map(json['payload']);
    return Activity(
      id: _int(json['id']),
      type: type,
      actor: user(_map(json['actor'])),
      visibility:
          ContentVisibility.fromWireValue(json['visibility'] as String?) ??
          ContentVisibility.public,
      movie: _block(payload['movie'], _movie),
      log: _block(payload['log'], _log),
      rating: _block(payload['rating'], _rating),
      shelf: _block(payload['shelf'], _shelf),
      locadora: _block(payload['locadora'], _locadora),
      import: _block(payload['import'], _import),
      maratona: _block(payload['maratona'], _maratona),
      challenge: _block(payload['challenge'], _challenge),
      level: _block(payload['level'], _level),
      cineclube: _block(payload['cineclube'], _cineclube),
      bichinho: _block(payload['bichinho'], _bichinho),
      loves: _int(json['loves']),
      loved: json['loved'] as bool? ?? false,
      self: json['self'] as bool? ?? false,
      mutual: json['mutual'] as bool? ?? false,
      hidden: json['hidden'] as bool? ?? false,
      createdAt: _date(json['createdAt']) ?? DateTime(0),
    );
  }

  static ActivityLoves loves(Map<String, dynamic> json) => ActivityLoves(
    loves: _int(json['loves']),
    loved: json['loved'] as bool? ?? false,
  );

  static FollowStatus followStatus(Map<String, dynamic> json) => FollowStatus(
    following: json['following'] as bool? ?? false,
    followedBy: json['followedBy'] as bool? ?? false,
  );

  static FollowPage followPage(Map<String, dynamic> json) => FollowPage(
    cards: _list(json['results'])
        .map(
          (card) => FollowCard(
            user: user(_map(card['user'])),
            status: FollowStatus(
              following: card['isFollowing'] as bool? ?? false,
              followedBy: card['followsMe'] as bool? ?? false,
            ),
            self: card['self'] as bool? ?? false,
            followedAt: _date(card['followedAt']) ?? DateTime(0),
          ),
        )
        .toList(),
    page: _int(json['page'], fallback: 1),
    hasNext: json['hasNext'] as bool? ?? false,
  );

  static Message message(Map<String, dynamic> json) => Message(
    id: _int(json['id']),
    conversationId: _int(json['conversationId']),
    senderId: json['senderId'] as String?,
    body: json['body'] as String? ?? '',
    system: json['system'] as bool? ?? false,
    mine: json['mine'] as bool? ?? false,
    createdAt: _date(json['createdAt']) ?? DateTime(0),
  );

  static Conversation conversation(Map<String, dynamic> json) => Conversation(
    id: _int(json['id']),
    other: user(_map(json['other'])),
    enabled: json['enabled'] as bool? ?? false,
    lastMessage: _block(json['lastMessage'], message),
    unread: _int(json['unread']),
    lastMessageAt: _date(json['lastMessageAt']) ?? DateTime(0),
  );

  static ConversationPage conversationPage(Map<String, dynamic> json) =>
      ConversationPage(
        conversations: _list(json['results']).map(conversation).toList(),
        nextCursor: json['nextCursor'] as String?,
      );

  static MessagePage messagePage(Map<String, dynamic> json) => MessagePage(
    messages: _list(json['results']).map(message).toList(),
    nextCursor: json['nextCursor'] as String?,
  );

  static UnreadCount unreadCount(Map<String, dynamic> json) => UnreadCount(
    conversations: _int(json['conversations']),
    messages: _int(json['messages']),
  );

  /// The `message` WebSocket event; its values are all strings. [mine] is
  /// left false: the screen knows who the other member is.
  static Message? messageEvent(Map<String, dynamic>? data) {
    if (data == null) return null;
    final id = int.tryParse('${data['messageId']}');
    final conversationId = int.tryParse('${data['conversationId']}');
    if (id == null || conversationId == null) return null;
    final senderId = data['senderId'] as String?;
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId == null || senderId.isEmpty ? null : senderId,
      body: data['body'] as String? ?? '',
      system: '${data['system']}' == 'true',
      createdAt: _date(data['createdAt']) ?? DateTime.now(),
    );
  }

  /// The `unread` WebSocket event.
  static UnreadCount? unreadEvent(Map<String, dynamic>? data) {
    if (data == null) return null;
    final conversations = int.tryParse('${data['conversations']}');
    final messages = int.tryParse('${data['messages']}');
    if (conversations == null || messages == null) return null;
    return UnreadCount(conversations: conversations, messages: messages);
  }

  // ── Payload blocks ────────────────────────────────────────────────────

  static ActivityMovie _movie(Map<String, dynamic> json) => ActivityMovie(
    id: _int(json['id']),
    tmdbId: (json['tmdbId'] as num?)?.toInt(),
    title: json['title'] as String? ?? '',
    posterPath: json['posterPath'] as String?,
  );

  static ActivityLog _log(Map<String, dynamic> json) => ActivityLog(
    id: _int(json['id']),
    watchedOn: _date(json['watchedOn']),
    cycle: _int(json['cycle'], fallback: 1),
    mode: WatchMode.fromWireValue(json['mode'] as String?) ?? WatchMode.watched,
    minutes: (json['minutes'] as num?)?.toInt(),
    percent: (json['percent'] as num?)?.toInt(),
    completed: json['completed'] as bool? ?? false,
    venue: WatchVenue.fromWireValue(json['venue'] as String?),
    providerName: json['providerName'] as String?,
    emotions: (json['emotions'] as List<dynamic>? ?? const [])
        .map((value) => Emotion.fromWireValue(value as String?))
        .whereType<Emotion>()
        .toList(),
    gifUrl: json['gifUrl'] as String?,
    comment: json['comment'] as String?,
    hasSpoiler: json['hasSpoiler'] as bool? ?? false,
  );

  static ActivityRating _rating(Map<String, dynamic> json) => ActivityRating(
    id: _int(json['id']),
    rating: Rating.fromWireValue(json['rating'] as String?),
    review: json['review'] as String?,
    hasSpoiler: json['hasSpoiler'] as bool? ?? false,
  );

  static ActivityShelf _shelf(Map<String, dynamic> json) => ActivityShelf(
    id: _int(json['id']),
    name: json['name'] as String? ?? '',
    color: json['color'] as String?,
    totalMovies: _int(json['totalMovies']),
    posterPaths: _strings(json['posterPaths']),
  );

  static ActivityLocadora _locadora(Map<String, dynamic> json) =>
      ActivityLocadora(
        id: _int(json['id']),
        name: json['name'] as String? ?? '',
        totalShelves: _int(json['totalShelves']),
        totalMovies: _int(json['totalMovies']),
        posterPaths: _strings(json['posterPaths']),
      );

  static ActivityImport _import(Map<String, dynamic> json) => ActivityImport(
    source: json['source'] as String? ?? '',
    watched: _int(json['watched']),
    watchlist: _int(json['watchlist']),
  );

  static ActivityMaratona _maratona(Map<String, dynamic> json) =>
      ActivityMaratona(
        id: _int(json['id']),
        slug: json['slug'] as String? ?? '',
        title: json['title'] as String? ?? '',
        logoUrl: json['logoUrl'] as String?,
        accentColor: json['accentColor'] as String?,
      );

  static ActivityChallenge _challenge(Map<String, dynamic> json) =>
      ActivityChallenge(
        id: _int(json['id']),
        description: json['description'] as String? ?? '',
      );

  static ActivityLevel _level(Map<String, dynamic> json) => ActivityLevel(
    id: _int(json['id']),
    name: json['name'] as String? ?? '',
    completed: _int(json['completed']),
    total: _int(json['total']),
  );

  static ActivityCineClube _cineclube(Map<String, dynamic> json) =>
      ActivityCineClube(
        id: _int(json['id']),
        slug: json['slug'] as String? ?? '',
        title: json['title'] as String? ?? '',
        accentColor: json['accentColor'] as String?,
        isCycle: json['isCycle'] as bool? ?? false,
      );

  static NotificationPrefs notificationPrefs(Map<String, dynamic> json) =>
      NotificationPrefs(
        messages: json['messages'] as bool? ?? true,
        newFollowers: json['newFollowers'] as bool? ?? true,
        loves: json['loves'] as bool? ?? true,
        maratonas: json['maratonas'] as bool? ?? true,
        cineclubes: json['cineclubes'] as bool? ?? true,
      );

  static Map<String, dynamic> notificationPrefsJson(NotificationPrefs prefs) =>
      {
        'messages': prefs.messages,
        'newFollowers': prefs.newFollowers,
        'loves': prefs.loves,
        'maratonas': prefs.maratonas,
        'cineclubes': prefs.cineclubes,
      };

  static ActivityBichinho _bichinho(Map<String, dynamic> json) =>
      ActivityBichinho(
        slug: json['slug'] as String? ?? '',
        rarity: json['rarity'] as String? ?? 'common',
      );

  // ── Helpers ───────────────────────────────────────────────────────────

  static T? _block<T>(Object? value, T Function(Map<String, dynamic>) map) =>
      value is Map<String, dynamic> ? map(value) : null;

  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static List<Map<String, dynamic>> _list(Object? value) =>
      (value as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

  static List<String> _strings(Object? value) =>
      (value as List<dynamic>? ?? const []).whereType<String>().toList();

  static int _int(Object? value, {int fallback = 0}) =>
      (value as num?)?.toInt() ?? fallback;

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;
}
