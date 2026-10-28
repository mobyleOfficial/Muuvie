import 'dart:async';

import 'package:core/core.dart';
import 'package:social_network/social_network.dart';

/// Hand-rolled fake of [SocialNetworkRepository]: answers what the test sets
/// and records the calls. [incoming] and [unread] play the WebSocket.
class FakeSocialNetworkRepository implements SocialNetworkRepository {
  final calls = <String>[];
  final incoming = StreamController<Message>.broadcast();
  final unread = StreamController<UnreadCount>.broadcast();

  /// Feed pages by `scope:cursor`.
  final feedPages = <String, Result<ActivityPage>>{};
  Result<ActivityLoves>? loveResult;
  Result<void> hideResult = const Success(null);
  Result<FollowStatus> followResult = const Success(
    FollowStatus(following: true, followedBy: false),
  );
  Result<FollowStatus> followStatus = const Success(
    FollowStatus(following: true, followedBy: true),
  );
  final followPages = <String, Result<FollowPage>>{};
  Result<ConversationPage> conversationsResult = const Success(
    ConversationPage(conversations: []),
  );
  final conversationsById = <int, Result<Conversation>>{};
  Result<Conversation> conversationWith = const Failure(AppError.notFound);
  final messagePages = <String, Result<MessagePage>>{};
  Result<Message> Function(String body)? sendResult;
  Result<UnreadCount> unreadResult = const Success(UnreadCount.zero);

  @override
  Future<Result<ActivityPage>> getFeed(
    FeedScope scope, {
    String? cursor,
  }) async {
    calls.add('feed ${scope.wireValue} $cursor');
    return feedPages['${scope.wireValue}:$cursor'] ??
        const Success(ActivityPage(activities: []));
  }

  @override
  Future<Result<ActivityPage>> getUserActivities(
    String userId, {
    String? cursor,
  }) async => const Success(ActivityPage(activities: []));

  @override
  Future<Result<ActivityPage>> getMovieActivities(
    int movieId, {
    String? cursor,
    FeedScope scope = FeedScope.following,
    MovieActivityKind? kind,
  }) async {
    calls.add('movie $movieId ${scope.wireValue} ${kind?.wireValue}');
    return const Success(ActivityPage(activities: []));
  }

  @override
  Future<Result<ActivityPage>> getMaratonaProgress(
    String slug, {
    String? cursor,
  }) async => const Success(ActivityPage(activities: []));

  @override
  Future<Result<ActivityLoves>> love(int activityId) async {
    calls.add('love $activityId');
    return loveResult ?? const Success(ActivityLoves(loves: 1, loved: true));
  }

  @override
  Future<Result<ActivityLoves>> unlove(int activityId) async {
    calls.add('unlove $activityId');
    return loveResult ?? const Success(ActivityLoves(loves: 0, loved: false));
  }

  @override
  Future<Result<void>> setHidden(int activityId, bool hidden) async {
    calls.add('hide $activityId $hidden');
    return hideResult;
  }

  @override
  Future<Result<FollowStatus>> follow(String userId) async {
    calls.add('follow $userId');
    return followResult;
  }

  @override
  Future<Result<FollowStatus>> unfollow(String userId) async {
    calls.add('unfollow $userId');
    return followResult;
  }

  @override
  Future<Result<FollowStatus>> getFollowStatus(String userId) async =>
      followStatus;

  @override
  Future<Result<FollowPage>> getFollowers(
    String userId, {
    int page = 1,
  }) async =>
      followPages['followers:$page'] ??
      const Success(FollowPage(cards: [], page: 1, hasNext: false));

  @override
  Future<Result<FollowPage>> getFollowing(
    String userId, {
    int page = 1,
  }) async =>
      followPages['following:$page'] ??
      const Success(FollowPage(cards: [], page: 1, hasNext: false));

  @override
  Future<Result<ConversationPage>> getConversations({String? cursor}) async {
    calls.add('conversations $cursor');
    return conversationsResult;
  }

  @override
  Future<Result<Conversation>> getConversation(int conversationId) async =>
      conversationsById[conversationId] ?? const Failure(AppError.notFound);

  @override
  Future<Result<Conversation>> getConversationWith(String userId) async =>
      conversationWith;

  @override
  Future<Result<MessagePage>> getMessages(
    int conversationId, {
    String? cursor,
  }) async =>
      messagePages['$conversationId:$cursor'] ??
      const Success(MessagePage(messages: []));

  @override
  Future<Result<Message>> sendMessage(String userId, String body) async {
    calls.add('send $userId $body');
    return sendResult?.call(body) ?? const Failure(AppError.server);
  }

  @override
  Future<Result<UnreadCount>> markRead(int conversationId) async {
    calls.add('read $conversationId');
    return const Success(UnreadCount.zero);
  }

  @override
  Future<Result<UnreadCount>> getUnreadCount() async => unreadResult;

  @override
  Stream<Message> watchMessages() => incoming.stream;

  @override
  Stream<UnreadCount> watchUnreadCount() => unread.stream;

  NotificationPrefs prefs = const NotificationPrefs();
  final savedPrefs = <NotificationPrefs>[];

  @override
  Future<Result<NotificationPrefs>> getNotificationPrefs() async =>
      Success(prefs);

  @override
  Future<Result<NotificationPrefs>> saveNotificationPrefs(
    NotificationPrefs value,
  ) async {
    savedPrefs.add(value);
    prefs = value;
    return Success(value);
  }

  @override
  Future<Result<void>> registerDevice(
    String platform,
    String token,
    String? locale,
  ) async {
    calls.add('registerDevice:$platform:$token:$locale');
    return const Success(null);
  }

  @override
  Future<Result<void>> removeDevice(String token) async {
    calls.add('removeDevice:$token');
    return const Success(null);
  }

  Future<void> dispose() async {
    await incoming.close();
    await unread.close();
  }
}

const anaUser = SocialUser(id: 'ana-id', username: 'ana', displayName: 'Ana');
const biaUser = SocialUser(id: 'bia-id', username: 'bia', displayName: 'Bia');

Activity activityFixture({
  int id = 1,
  SocialUser actor = anaUser,
  ActivityType type = ActivityType.finishedMovie,
  bool loved = false,
  int loves = 0,
  bool self = false,
  bool hidden = false,
}) => Activity(
  id: id,
  type: type,
  actor: actor,
  visibility: ContentVisibility.public,
  movie: const ActivityMovie(id: 10, title: 'Halloween'),
  log: const ActivityLog(id: 70, completed: true, emotions: [Emotion.joy]),
  rating: const ActivityRating(id: 5, rating: Rating.loved),
  loves: loves,
  loved: loved,
  self: self,
  hidden: hidden,
  createdAt: DateTime.now().subtract(const Duration(hours: 2)),
);

Message messageFixture({
  required int id,
  int conversationId = 7,
  String? senderId = 'bia-id',
  String body = 'Oi',
  bool system = false,
  bool mine = false,
}) => Message(
  id: id,
  conversationId: conversationId,
  senderId: senderId,
  body: body,
  system: system,
  mine: mine,
  createdAt: DateTime(2026, 10, 26, 20, id),
);

Conversation conversationFixture({
  int id = 7,
  SocialUser other = biaUser,
  bool enabled = true,
  int unread = 0,
  Message? lastMessage,
}) => Conversation(
  id: id,
  other: other,
  enabled: enabled,
  unread: unread,
  lastMessage: lastMessage,
  lastMessageAt: DateTime(2026, 10, 26, 20),
);
