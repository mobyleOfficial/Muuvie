import 'package:core/core.dart';
import 'package:social_network_data/models/remote_social_network.dart';
import 'package:social_network_domain/models/models.dart';

abstract interface class SocialNetworkRemoteDataSource {
  Future<Result<ActivityPage>> getFeed(FeedScope scope, String? cursor);

  Future<Result<ActivityPage>> getUserActivities(String userId, String? cursor);

  Future<Result<ActivityPage>> getMovieActivities(
    int movieId,
    String? cursor, {
    FeedScope scope = FeedScope.following,
    MovieActivityKind? kind,
  });

  Future<Result<ActivityPage>> getMaratonaProgress(String slug, String? cursor);

  Future<Result<ActivityLoves>> setLove(int activityId, bool love);

  Future<Result<void>> setHidden(int activityId, bool hidden);

  Future<Result<FollowStatus>> setFollowing(String userId, bool follow);

  Future<Result<FollowStatus>> getFollowStatus(String userId);

  Future<Result<FollowPage>> getFollowers(String userId, int page);

  Future<Result<FollowPage>> getFollowing(String userId, int page);

  Future<Result<ConversationPage>> getConversations(String? cursor);

  Future<Result<Conversation>> getConversation(int conversationId);

  Future<Result<Conversation>> getConversationWith(String userId);

  Future<Result<MessagePage>> getMessages(int conversationId, String? cursor);

  Future<Result<Message>> sendMessage(String userId, String body);

  Future<Result<UnreadCount>> markRead(int conversationId);

  Future<Result<UnreadCount>> getUnreadCount();

  Future<Result<NotificationPrefs>> getNotificationPrefs();

  Future<Result<NotificationPrefs>> saveNotificationPrefs(
    NotificationPrefs prefs,
  );
}

/// Social endpoints of the v1 API (`/api/v1`). See the backend README.
class SocialNetworkRemoteDataSourceImpl
    implements SocialNetworkRemoteDataSource {
  static const _base = '/api/v1';
  static const _feedPageSize = 20;
  static const _followPageSize = 30;

  final HttpClient _httpClient;

  SocialNetworkRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<ActivityPage>> getFeed(FeedScope scope, String? cursor) async =>
      _map(
        await _httpClient.get<Map<String, dynamic>>(
          '$_base/feed',
          queryParams: {
            'scope': scope.wireValue,
            'cursor': ?cursor,
            'limit': _feedPageSize,
          },
        ),
        RemoteSocialNetwork.activityPage,
      );

  @override
  Future<Result<ActivityPage>> getUserActivities(
    String userId,
    String? cursor,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/users/${Uri.encodeComponent(userId)}/activities',
      queryParams: {'cursor': ?cursor, 'limit': _feedPageSize},
    ),
    RemoteSocialNetwork.activityPage,
  );

  @override
  Future<Result<ActivityPage>> getMovieActivities(
    int movieId,
    String? cursor, {
    FeedScope scope = FeedScope.following,
    MovieActivityKind? kind,
  }) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/movies/$movieId/activities',
      queryParams: {
        'scope': scope.wireValue,
        'type': ?kind?.wireValue,
        'cursor': ?cursor,
        'limit': _feedPageSize,
      },
    ),
    RemoteSocialNetwork.activityPage,
  );

  @override
  Future<Result<ActivityPage>> getMaratonaProgress(
    String slug,
    String? cursor,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/maratonas/${Uri.encodeComponent(slug)}/progress',
      queryParams: {'cursor': ?cursor},
    ),
    RemoteSocialNetwork.activityPage,
  );

  @override
  Future<Result<ActivityLoves>> setLove(int activityId, bool love) async {
    final path = '$_base/activities/$activityId/love';
    return _map(
      love
          ? await _httpClient.put<Map<String, dynamic>>(path)
          : await _httpClient.delete<Map<String, dynamic>>(path),
      RemoteSocialNetwork.loves,
    );
  }

  @override
  Future<Result<void>> setHidden(int activityId, bool hidden) async =>
      _ignoreBody(
        await _httpClient.put<dynamic>(
          '$_base/activities/$activityId/hidden',
          body: {'hidden': hidden},
        ),
      );

  @override
  Future<Result<FollowStatus>> setFollowing(String userId, bool follow) async {
    final path = '$_base/users/${Uri.encodeComponent(userId)}/follow';
    return _map(
      follow
          ? await _httpClient.post<Map<String, dynamic>>(path)
          : await _httpClient.delete<Map<String, dynamic>>(path),
      RemoteSocialNetwork.followStatus,
    );
  }

  @override
  Future<Result<FollowStatus>> getFollowStatus(String userId) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/users/${Uri.encodeComponent(userId)}/follow-status',
    ),
    RemoteSocialNetwork.followStatus,
  );

  @override
  Future<Result<FollowPage>> getFollowers(String userId, int page) async =>
      _map(
        await _httpClient.get<Map<String, dynamic>>(
          '$_base/users/${Uri.encodeComponent(userId)}/followers',
          queryParams: {'page': page, 'limit': _followPageSize},
        ),
        RemoteSocialNetwork.followPage,
      );

  @override
  Future<Result<FollowPage>> getFollowing(String userId, int page) async =>
      _map(
        await _httpClient.get<Map<String, dynamic>>(
          '$_base/users/${Uri.encodeComponent(userId)}/following',
          queryParams: {'page': page, 'limit': _followPageSize},
        ),
        RemoteSocialNetwork.followPage,
      );

  @override
  Future<Result<ConversationPage>> getConversations(String? cursor) async =>
      _map(
        await _httpClient.get<Map<String, dynamic>>(
          '$_base/conversations',
          queryParams: {'cursor': ?cursor},
        ),
        RemoteSocialNetwork.conversationPage,
      );

  @override
  Future<Result<Conversation>> getConversation(int conversationId) async =>
      _map(
        await _httpClient.get<Map<String, dynamic>>(
          '$_base/conversations/$conversationId',
        ),
        RemoteSocialNetwork.conversation,
      );

  @override
  Future<Result<Conversation>> getConversationWith(String userId) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/users/${Uri.encodeComponent(userId)}/conversation',
    ),
    RemoteSocialNetwork.conversation,
  );

  @override
  Future<Result<MessagePage>> getMessages(
    int conversationId,
    String? cursor,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/conversations/$conversationId/messages',
      queryParams: {'cursor': ?cursor},
    ),
    RemoteSocialNetwork.messagePage,
  );

  @override
  Future<Result<Message>> sendMessage(String userId, String body) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/users/${Uri.encodeComponent(userId)}/messages',
      body: {'body': body},
    ),
    RemoteSocialNetwork.message,
  );

  @override
  Future<Result<UnreadCount>> markRead(int conversationId) async => _map(
    await _httpClient.put<Map<String, dynamic>>(
      '$_base/conversations/$conversationId/read',
    ),
    RemoteSocialNetwork.unreadCount,
  );

  @override
  Future<Result<UnreadCount>> getUnreadCount() async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_base/users/me/unread-count'),
    RemoteSocialNetwork.unreadCount,
  );

  Result<T> _map<T>(
    Result<Map<String, dynamic>> result,
    T Function(Map<String, dynamic>) fromJson,
  ) => switch (result) {
    Success(:final data) => Success(fromJson(data)),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<NotificationPrefs>> getNotificationPrefs() async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/users/me/notification-prefs',
    ),
    RemoteSocialNetwork.notificationPrefs,
  );

  @override
  Future<Result<NotificationPrefs>> saveNotificationPrefs(
    NotificationPrefs prefs,
  ) async => _map(
    await _httpClient.put<Map<String, dynamic>>(
      '$_base/users/me/notification-prefs',
      body: RemoteSocialNetwork.notificationPrefsJson(prefs),
    ),
    RemoteSocialNetwork.notificationPrefs,
  );

  Result<void> _ignoreBody(Result<dynamic> result) => switch (result) {
    Success() => const Success(null),
    Failure(:final error) => Failure(error),
  };
}
