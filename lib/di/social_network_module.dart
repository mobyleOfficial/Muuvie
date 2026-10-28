import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:social_network/social_network.dart';

@module
abstract class SocialNetworkModule {
  @lazySingleton
  SocialNetworkRemoteDataSource socialNetworkRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => SocialNetworkRemoteDataSourceImpl(httpClient);

  @lazySingleton
  SocialNetworkRepository socialNetworkRepository(
    SocialNetworkRemoteDataSource remoteDataSource,
    WebSocketClient webSocketClient,
  ) => SocialNetworkRepositoryImpl(remoteDataSource, webSocketClient);

  @injectable
  GetFeed getFeed(SocialNetworkRepository repository) => GetFeed(repository);

  @injectable
  GetProfileActivities getProfileActivities(
    SocialNetworkRepository repository,
  ) => GetProfileActivities(repository);

  @injectable
  GetMovieActivities getMovieActivities(SocialNetworkRepository repository) =>
      GetMovieActivities(repository);

  @injectable
  GetMaratonaProgress getMaratonaProgress(SocialNetworkRepository repository) =>
      GetMaratonaProgress(repository);

  @injectable
  ToggleActivityLove toggleActivityLove(SocialNetworkRepository repository) =>
      ToggleActivityLove(repository);

  @injectable
  HideActivity hideActivity(SocialNetworkRepository repository) =>
      HideActivity(repository);

  @injectable
  SetFollowing setFollowing(SocialNetworkRepository repository) =>
      SetFollowing(repository);

  @injectable
  GetFollowStatus getFollowStatus(SocialNetworkRepository repository) =>
      GetFollowStatus(repository);

  @injectable
  GetFollowList getFollowList(SocialNetworkRepository repository) =>
      GetFollowList(repository);

  @injectable
  GetConversations getConversations(SocialNetworkRepository repository) =>
      GetConversations(repository);

  @injectable
  GetConversation getConversation(SocialNetworkRepository repository) =>
      GetConversation(repository);

  @injectable
  GetConversationWith getConversationWith(SocialNetworkRepository repository) =>
      GetConversationWith(repository);

  @injectable
  GetMessages getMessages(SocialNetworkRepository repository) =>
      GetMessages(repository);

  @injectable
  SendWhisper sendWhisper(SocialNetworkRepository repository) =>
      SendWhisper(repository);

  @injectable
  MarkConversationRead markConversationRead(
    SocialNetworkRepository repository,
  ) => MarkConversationRead(repository);

  @injectable
  GetUnreadCount getUnreadCount(SocialNetworkRepository repository) =>
      GetUnreadCount(repository);

  @injectable
  WatchIncomingMessages watchIncomingMessages(
    SocialNetworkRepository repository,
  ) => WatchIncomingMessages(repository);

  @injectable
  WatchUnreadCount watchUnreadCount(SocialNetworkRepository repository) =>
      WatchUnreadCount(repository);

  @injectable
  GetNotificationPrefs getNotificationPrefs(
    SocialNetworkRepository repository,
  ) => GetNotificationPrefs(repository);

  @injectable
  SaveNotificationPrefs saveNotificationPrefs(
    SocialNetworkRepository repository,
  ) => SaveNotificationPrefs(repository);

  @injectable
  RegisterPushDevice registerPushDevice(
    SocialNetworkRepository repository,
    PushMessaging push,
  ) => RegisterPushDevice(repository, push);

  @injectable
  RemovePushDevice removePushDevice(
    SocialNetworkRepository repository,
    PushMessaging push,
  ) => RemovePushDevice(repository, push);
}
