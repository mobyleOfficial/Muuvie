import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_ui/follows/follow_button.dart';
import 'package:profile_ui/follows/follows_bloc.dart';
import 'package:profile_ui/follows/follows_state.dart';
import 'package:social/feed/activity_card.dart';
import 'package:social/social_bloc.dart';
import 'package:social/social_state.dart';
import 'package:social_network/social_network.dart';
import 'package:whispers/conversation/conversation_bloc.dart';
import 'package:whispers/conversation/conversation_state.dart';
import 'package:whispers/whispers_bloc.dart';
import 'package:whispers/whispers_state.dart';

import '../../helpers/fake_social_network_repository.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeSocialNetworkRepository repository;

  setUp(() => repository = FakeSocialNetworkRepository());
  tearDown(() => repository.dispose());

  group('Atts feed', () {
    SocialCubit cubitFor() => SocialCubit(
      getFeed: GetFeed(repository),
      toggleLove: ToggleActivityLove(repository),
      hideActivity: HideActivity(repository),
    );

    test('loads a scope, then the next page by cursor', () async {
      repository.feedPages['all:null'] = Success(
        ActivityPage(activities: [activityFixture(id: 1)], nextCursor: 'c1'),
      );
      repository.feedPages['all:c1'] = Success(
        ActivityPage(activities: [activityFixture(id: 2)]),
      );
      final cubit = cubitFor();
      await _settle();

      await cubit.loadMore();

      final state = cubit.state as SocialSuccess;
      expect(state.activities.map((activity) => activity.id), [1, 2]);
      expect(state.hasMore, false);
      await cubit.close();
    });

    test('switching the scope reloads with it', () async {
      final cubit = cubitFor();
      await _settle();

      await cubit.selectScope(FeedScope.me);

      expect(repository.calls, ['feed all null', 'feed me null']);
      expect(cubit.state.scope, FeedScope.me);
      await cubit.close();
    });

    test('"amei" flips at once and takes the count of the server', () async {
      repository.feedPages['all:null'] = Success(
        ActivityPage(activities: [activityFixture(loves: 4)]),
      );
      repository.loveResult = const Success(
        ActivityLoves(loves: 9, loved: true),
      );
      final cubit = cubitFor();
      await _settle();

      await cubit.toggleLove((cubit.state as SocialSuccess).activities.single);

      final activity = (cubit.state as SocialSuccess).activities.single;
      expect(activity.loved, true);
      expect(activity.loves, 9);
      await cubit.close();
    });

    test('a failed "amei" goes back', () async {
      repository.feedPages['all:null'] = Success(
        ActivityPage(activities: [activityFixture(loves: 4)]),
      );
      repository.loveResult = const Failure(AppError.network);
      final cubit = cubitFor();
      await _settle();

      await cubit.toggleLove((cubit.state as SocialSuccess).activities.single);

      final activity = (cubit.state as SocialSuccess).activities.single;
      expect(activity.loved, false);
      expect(activity.loves, 4);
      await cubit.close();
    });

    test('hiding leaves the list, except in "Só eu"', () async {
      repository.feedPages['all:null'] = Success(
        ActivityPage(activities: [activityFixture(self: true)]),
      );
      repository.feedPages['me:null'] = Success(
        ActivityPage(activities: [activityFixture(self: true)]),
      );
      final cubit = cubitFor();
      await _settle();

      expect(await cubit.toggleHidden(activityFixture(self: true)), true);
      expect((cubit.state as SocialSuccess).activities, isEmpty);

      await cubit.selectScope(FeedScope.me);
      await cubit.toggleHidden(activityFixture(self: true));
      expect((cubit.state as SocialSuccess).activities.single.hidden, true);
      await cubit.close();
    });

    testWidgets('a card says who did what, with stars and emotions', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ActivityCard(
            activity: activityFixture(loves: 3),
            onOpenActor: () {},
            onOpenMovie: (_) {},
            onOpenShelf: (_) {},
            onOpenLocadora: (_) {},
            onToggleLove: () {},
          ),
        ),
      );

      expect(find.textContaining('Ana'), findsWidgets);
      expect(find.textContaining('assistiu'), findsOneWidget);
      expect(find.textContaining('Halloween'), findsOneWidget);
      expect(find.text('Alegria'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byTooltip('Mais opções'), findsNothing);
    });

    testWidgets('my card offers hiding it', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ActivityCard(
            activity: activityFixture(self: true),
            onOpenActor: () {},
            onOpenMovie: (_) {},
            onOpenShelf: (_) {},
            onOpenLocadora: (_) {},
            onToggleLove: () {},
            onToggleHidden: () {},
          ),
        ),
      );

      expect(find.byTooltip('Mais opções'), findsOneWidget);
    });
  });

  group('follows', () {
    FollowCard card(
      String id, {
      bool following = false,
      bool followedBy = false,
    }) => FollowCard(
      user: SocialUser(id: id, username: id),
      status: FollowStatus(following: following, followedBy: followedBy),
      followedAt: DateTime(2026, 10, 1),
    );

    test('following back updates the row in both lists', () async {
      repository.followPages['followers:1'] = Success(
        FollowPage(
          cards: [card('bia-id', followedBy: true)],
          page: 1,
          hasNext: false,
        ),
      );
      repository.followResult = const Success(
        FollowStatus(following: true, followedBy: true),
      );
      final cubit = FollowsCubit(
        userId: 'me',
        getFollowList: GetFollowList(repository),
        setFollowing: SetFollowing(repository),
      );
      await _settle();

      final error = await cubit.toggleFollow(card('bia-id', followedBy: true));

      expect(error, isNull);
      expect(repository.calls, ['follow bia-id']);
      final row = (cubit.state.followers as FollowListSuccess).cards.single;
      expect(row.status.mutual, true);
      await cubit.close();
    });

    test('the rate limit comes back as an error', () async {
      repository.followResult = const Failure(AppError.tooManyRequests);
      final cubit = FollowsCubit(
        userId: 'me',
        getFollowList: GetFollowList(repository),
        setFollowing: SetFollowing(repository),
      );
      await _settle();

      expect(
        await cubit.toggleFollow(card('bia-id')),
        AppError.tooManyRequests,
      );
      await cubit.close();
    });

    testWidgets('the button reads Seguir, Seguir de volta or Seguindo', (
      tester,
    ) async {
      for (final (following, followedBy, label) in [
        (false, false, 'Seguir'),
        (false, true, 'Seguir de volta'),
        (true, true, 'Seguindo'),
      ]) {
        await tester.pumpWidget(
          _wrap(
            FollowButton(
              following: following,
              followedBy: followedBy,
              onPressed: () {},
            ),
          ),
        );
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });
  });

  group('whispers', () {
    test(
      'a message moves its conversation to the top and counts as unread',
      () async {
        repository.conversationsResult = Success(
          ConversationPage(
            conversations: [
              conversationFixture(id: 1, other: anaUser),
              conversationFixture(id: 7),
            ],
          ),
        );
        final cubit = WhispersCubit(
          getConversations: GetConversations(repository),
          watchIncomingMessages: WatchIncomingMessages(repository),
        );
        await _settle();

        repository.incoming.add(messageFixture(id: 80, body: 'Viu?'));
        await _settle();

        final conversations = (cubit.state as WhispersSuccess).conversations;
        expect(conversations.map((conversation) => conversation.id), [7, 1]);
        expect(conversations.first.unread, 1);
        expect(conversations.first.lastMessage?.body, 'Viu?');
        await cubit.close();
      },
    );

    ConversationCubit conversationFor({int? conversationId}) =>
        ConversationCubit(
          otherUserId: 'bia-id',
          conversationId: conversationId,
          getConversation: GetConversation(repository),
          getConversationWith: GetConversationWith(repository),
          getMessages: GetMessages(repository),
          sendWhisper: SendWhisper(repository),
          markRead: MarkConversationRead(repository),
          getFollowStatus: GetFollowStatus(repository),
          watchIncomingMessages: WatchIncomingMessages(repository),
        );

    test('without a conversation yet, mutuals can start one', () async {
      final cubit = conversationFor();
      await _settle();

      final state = cubit.state as ConversationReady;
      expect(state.conversation, isNull);
      expect(state.enabled, true);
      expect(state.messages, isEmpty);
      await cubit.close();
    });

    test(
      'a sent message shows once, even when the WebSocket echoes it',
      () async {
        repository.conversationsById[7] = Success(conversationFixture());
        repository.sendResult = (body) => Success(
          messageFixture(id: 81, senderId: 'me', body: body, mine: true),
        );
        final cubit = conversationFor(conversationId: 7);
        await _settle();

        expect(await cubit.send('Oi, Bia'), isNull);
        repository.incoming.add(
          messageFixture(id: 81, senderId: 'me', body: 'Oi, Bia'),
        );
        await _settle();

        final messages = (cubit.state as ConversationReady).messages;
        expect(messages.single.body, 'Oi, Bia');
        expect(messages.single.mine, true);
        await cubit.close();
      },
    );

    test(
      'a message from the other one is marked read; the end of the mutual closes the input',
      () async {
        repository.conversationsById[7] = Success(conversationFixture());
        final cubit = conversationFor(conversationId: 7);
        await _settle();

        repository.incoming
          ..add(messageFixture(id: 82, body: 'Tá aí?'))
          ..add(
            messageFixture(
              id: 83,
              senderId: null,
              system: true,
              body: SystemMessageCode.mutualLost.wireValue,
            ),
          )
          // Another conversation: not this screen's.
          ..add(messageFixture(id: 84, conversationId: 9));
        await _settle();

        final state = cubit.state as ConversationReady;
        expect(state.messages.map((message) => message.id), [83, 82]);
        expect(state.messages.last.mine, false);
        expect(state.enabled, false);
        expect(repository.calls, contains('read 7'));
        await cubit.close();
      },
    );

    test(
      'a refused send closes the input when they are not mutuals anymore',
      () async {
        repository.conversationsById[7] = Success(conversationFixture());
        repository.sendResult = (_) => const Failure(AppError.forbidden);
        final cubit = conversationFor(conversationId: 7);
        await _settle();

        expect(await cubit.send('Oi'), AppError.forbidden);
        expect((cubit.state as ConversationReady).enabled, false);
        await cubit.close();
      },
    );
  });
}
