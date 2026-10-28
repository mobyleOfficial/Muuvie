import 'package:core/core.dart';
import 'package:social_network_domain/models/models.dart';

/// Feed, follows and Sussurros of the v1 API (B6). `userId` takes a user id
/// or an @handle.
abstract interface class SocialNetworkRepository {
  Future<Result<ActivityPage>> getFeed(FeedScope scope, {String? cursor});

  /// A profile's activities; `me` for the current user.
  Future<Result<ActivityPage>> getUserActivities(
    String userId, {
    String? cursor,
  });

  /// Activities about a movie (database id), B13.3. On a movie, [FeedScope.all]
  /// is everything the user may see, not only people they follow; [kind] null
  /// keeps both kinds.
  Future<Result<ActivityPage>> getMovieActivities(
    int movieId, {
    String? cursor,
    FeedScope scope = FeedScope.following,
    MovieActivityKind? kind,
  });

  /// What people did in a maratona, newest first (F7.6).
  Future<Result<ActivityPage>> getMaratonaProgress(
    String slug, {
    String? cursor,
  });

  Future<Result<ActivityLoves>> love(int activityId);

  Future<Result<ActivityLoves>> unlove(int activityId);

  Future<Result<void>> setHidden(int activityId, bool hidden);

  Future<Result<FollowStatus>> follow(String userId);

  Future<Result<FollowStatus>> unfollow(String userId);

  Future<Result<FollowStatus>> getFollowStatus(String userId);

  /// `me` for the current user's followers, newest follow first.
  Future<Result<FollowPage>> getFollowers(String userId, {int page = 1});

  Future<Result<FollowPage>> getFollowing(String userId, {int page = 1});

  Future<Result<ConversationPage>> getConversations({String? cursor});

  Future<Result<Conversation>> getConversation(int conversationId);

  /// The conversation with a user; fails with `notFound` before the first message.
  Future<Result<Conversation>> getConversationWith(String userId);

  Future<Result<MessagePage>> getMessages(int conversationId, {String? cursor});

  /// Fails with `forbidden` when they are not mutuals and with
  /// `tooManyRequests` above the rate limit.
  Future<Result<Message>> sendMessage(String userId, String body);

  /// Marks the conversation read and answers the new badge.
  Future<Result<UnreadCount>> markRead(int conversationId);

  Future<Result<UnreadCount>> getUnreadCount();

  /// Messages that arrive on the WebSocket, including the ones the user sent
  /// from another session.
  Stream<Message> watchMessages();

  /// The badge, each time it changes on the server.
  Stream<UnreadCount> watchUnreadCount();

  Future<Result<NotificationPrefs>> getNotificationPrefs();

  Future<Result<NotificationPrefs>> saveNotificationPrefs(
    NotificationPrefs prefs,
  );
}
