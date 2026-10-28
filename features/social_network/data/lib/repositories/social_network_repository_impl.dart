import 'package:core/core.dart';
import 'package:social_network_data/datasources/social_network_remote_data_source.dart';
import 'package:social_network_data/models/remote_social_network.dart';
import 'package:social_network_domain/models/models.dart';
import 'package:social_network_domain/repositories/social_network_repository.dart';

class SocialNetworkRepositoryImpl implements SocialNetworkRepository {
  final SocialNetworkRemoteDataSource _remoteDataSource;
  final WebSocketClient _webSocketClient;

  SocialNetworkRepositoryImpl(this._remoteDataSource, this._webSocketClient);

  @override
  Future<Result<ActivityPage>> getFeed(FeedScope scope, {String? cursor}) =>
      _remoteDataSource.getFeed(scope, cursor);

  @override
  Future<Result<ActivityPage>> getUserActivities(
    String userId, {
    String? cursor,
  }) => _remoteDataSource.getUserActivities(userId, cursor);

  @override
  Future<Result<ActivityPage>> getMovieActivities(
    int movieId, {
    String? cursor,
    FeedScope scope = FeedScope.following,
    MovieActivityKind? kind,
  }) => _remoteDataSource.getMovieActivities(
    movieId,
    cursor,
    scope: scope,
    kind: kind,
  );

  @override
  Future<Result<ActivityPage>> getMaratonaProgress(
    String slug, {
    String? cursor,
  }) => _remoteDataSource.getMaratonaProgress(slug, cursor);

  @override
  Future<Result<ActivityLoves>> love(int activityId) =>
      _remoteDataSource.setLove(activityId, true);

  @override
  Future<Result<ActivityLoves>> unlove(int activityId) =>
      _remoteDataSource.setLove(activityId, false);

  @override
  Future<Result<void>> setHidden(int activityId, bool hidden) =>
      _remoteDataSource.setHidden(activityId, hidden);

  @override
  Future<Result<FollowStatus>> follow(String userId) =>
      _remoteDataSource.setFollowing(userId, true);

  @override
  Future<Result<FollowStatus>> unfollow(String userId) =>
      _remoteDataSource.setFollowing(userId, false);

  @override
  Future<Result<FollowStatus>> getFollowStatus(String userId) =>
      _remoteDataSource.getFollowStatus(userId);

  @override
  Future<Result<FollowPage>> getFollowers(String userId, {int page = 1}) =>
      _remoteDataSource.getFollowers(userId, page);

  @override
  Future<Result<FollowPage>> getFollowing(String userId, {int page = 1}) =>
      _remoteDataSource.getFollowing(userId, page);

  @override
  Future<Result<ConversationPage>> getConversations({String? cursor}) =>
      _remoteDataSource.getConversations(cursor);

  @override
  Future<Result<Conversation>> getConversation(int conversationId) =>
      _remoteDataSource.getConversation(conversationId);

  @override
  Future<Result<Conversation>> getConversationWith(String userId) =>
      _remoteDataSource.getConversationWith(userId);

  @override
  Future<Result<MessagePage>> getMessages(
    int conversationId, {
    String? cursor,
  }) => _remoteDataSource.getMessages(conversationId, cursor);

  @override
  Future<Result<Message>> sendMessage(String userId, String body) =>
      _remoteDataSource.sendMessage(userId, body);

  @override
  Future<Result<UnreadCount>> markRead(int conversationId) =>
      _remoteDataSource.markRead(conversationId);

  @override
  Future<Result<UnreadCount>> getUnreadCount() =>
      _remoteDataSource.getUnreadCount();

  @override
  Stream<Message> watchMessages() => _webSocketClient.messages
      .where((message) => message.type == WsMessageType.message)
      .map((message) => RemoteSocialNetwork.messageEvent(message.data))
      .where((message) => message != null)
      .cast<Message>();

  @override
  Stream<UnreadCount> watchUnreadCount() => _webSocketClient.messages
      .where((message) => message.type == WsMessageType.unread)
      .map((message) => RemoteSocialNetwork.unreadEvent(message.data))
      .where((count) => count != null)
      .cast<UnreadCount>();

  @override
  Future<Result<NotificationPrefs>> getNotificationPrefs() =>
      _remoteDataSource.getNotificationPrefs();

  @override
  Future<Result<NotificationPrefs>> saveNotificationPrefs(
    NotificationPrefs prefs,
  ) => _remoteDataSource.saveNotificationPrefs(prefs);
}
