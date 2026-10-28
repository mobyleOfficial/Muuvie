import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_network/social_network.dart';

import '../../../helpers/fake_http_client.dart';

class _FakeWebSocketClient implements WebSocketClient {
  final controller = StreamController<WsMessage>.broadcast();

  @override
  Stream<WsMessage> get messages => controller.stream;

  @override
  Future<void> dispose() => controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _actor = {
  'id': 'ana-id',
  'username': 'ana',
  'handle': 'ana.cinefila',
  'displayName': 'Ana',
};

/// A session and a rating of one movie merged in one activity (B6).
const _mergedActivity = {
  'id': 3,
  'type': 'concluiu_filme',
  'actor': _actor,
  'visibility': 'mutual',
  'subjectType': 'movie',
  'subjectId': 10,
  'payload': {
    'movie': {
      'id': 10,
      'tmdbId': 100,
      'title': 'Halloween',
      'posterPath': '/h.jpg',
    },
    'log': {
      'id': 70,
      'watchedOn': '2026-10-01',
      'cycle': 2,
      'mode': 'watched',
      'completed': true,
      'emotions': ['joy', 'fear', 'unknown_emotion'],
      'comment': 'Que filme',
      'hasSpoiler': true,
    },
    'rating': {'id': 5, 'rating': 'loved', 'review': null},
  },
  'loves': 2,
  'loved': true,
  'self': false,
  'mutual': true,
  'hidden': false,
  'createdAt': '2026-10-26T20:00:00Z',
};

void main() {
  late FakeHttpClient http;
  late _FakeWebSocketClient socket;
  late SocialNetworkRepositoryImpl repository;

  setUp(() {
    http = FakeHttpClient();
    socket = _FakeWebSocketClient();
    repository = SocialNetworkRepositoryImpl(
      SocialNetworkRemoteDataSourceImpl(http),
      socket,
    );
  });

  tearDown(() => socket.dispose());

  group('feed', () {
    test('reads the scope and the cursor, and maps every block', () async {
      http.response = const Success({
        'results': [
          _mergedActivity,
          {
            'id': 4,
            'type': 'novo_tipo_do_futuro',
            'actor': _actor,
            'payload': {},
          },
        ],
        'nextCursor': 'abc',
      });

      final result = await repository.getFeed(
        FeedScope.following,
        cursor: 'xyz',
      );

      expect(http.calls.single.path, '/api/v1/feed');
      expect(http.calls.single.query, {
        'scope': 'following',
        'cursor': 'xyz',
        'limit': 20,
      });
      final page = (result as Success<ActivityPage>).data;
      expect(page.nextCursor, 'abc');
      // A type this version does not know is left out.
      final activity = page.activities.single;
      expect(activity.type, ActivityType.finishedMovie);
      expect(activity.actor.name, 'Ana');
      expect(activity.visibility, ContentVisibility.mutual);
      expect(activity.movie?.title, 'Halloween');
      expect(activity.log?.isRewatch, true);
      expect(activity.log?.emotions, [Emotion.joy, Emotion.fear]);
      expect(activity.log?.hasSpoiler, true);
      expect(activity.rating?.rating, Rating.loved);
      expect(activity.loves, 2);
      expect(activity.loved, true);
    });

    test('a shelf activity carries its posters and count', () async {
      http.response = const Success({
        'results': [
          {
            'id': 5,
            'type': 'nova_estante',
            'actor': _actor,
            'payload': {
              'shelf': {
                'id': 9,
                'name': 'Giallo',
                'totalMovies': 3,
                'posterPaths': ['/a.jpg'],
              },
            },
          },
        ],
      });

      final result = await repository.getUserActivities('@ana.cinefila');

      expect(
        http.calls.single.path,
        '/api/v1/users/%40ana.cinefila/activities',
      );
      final activity = (result as Success<ActivityPage>).data.activities.single;
      expect(activity.shelf?.name, 'Giallo');
      expect(activity.shelf?.posterPaths, ['/a.jpg']);
      expect(activity.movie, isNull);
    });

    test('love and unlove use PUT and DELETE and answer the count', () async {
      http.response = const Success({'loves': 1, 'loved': true});

      final loved = await repository.love(3);
      await repository.unlove(3);

      expect(http.calls.map((call) => '${call.method} ${call.path}'), [
        'PUT /api/v1/activities/3/love',
        'DELETE /api/v1/activities/3/love',
      ]);
      expect((loved as Success<ActivityLoves>).data.loved, true);
    });

    test('the Comunidade tab sends the scope and the kind', () async {
      http.response = const Success({'results': [], 'nextCursor': null});

      await repository.getMovieActivities(7);
      await repository.getMovieActivities(
        7,
        cursor: 'abc',
        scope: FeedScope.all,
        kind: MovieActivityKind.ratings,
      );

      expect(http.calls.first.path, '/api/v1/movies/7/activities');
      expect(http.calls.first.query?['scope'], 'following');
      expect(http.calls.first.query?.containsKey('type'), false);
      expect(http.calls.last.query?['scope'], 'all');
      expect(http.calls.last.query?['type'], 'ratings');
      expect(http.calls.last.query?['cursor'], 'abc');
    });

    test('hiding sends the flag', () async {
      await repository.setHidden(3, true);

      expect(http.calls.single.method, 'PUT');
      expect(http.calls.single.path, '/api/v1/activities/3/hidden');
      expect(http.calls.single.body, {'hidden': true});
    });
  });

  group('follows', () {
    test(
      'follow posts, unfollow deletes, and both answer the relation',
      () async {
        http.response = const Success({
          'following': true,
          'followedBy': true,
          'mutual': true,
        });

        final status = await repository.follow('bia-id');
        await repository.unfollow('bia-id');

        expect(http.calls.map((call) => call.method), ['POST', 'DELETE']);
        expect(http.calls.first.path, '/api/v1/users/bia-id/follow');
        expect((status as Success<FollowStatus>).data.mutual, true);
      },
    );

    test('a follow list maps the relation of each row', () async {
      http.response = const Success({
        'results': [
          {
            'user': _actor,
            'isFollowing': false,
            'followsMe': true,
            'mutual': false,
            'self': false,
            'followedAt': '2026-10-20T10:00:00Z',
          },
        ],
        'page': 1,
        'hasNext': true,
      });

      final result = await repository.getFollowers('me', page: 2);

      expect(http.calls.single.path, '/api/v1/users/me/followers');
      expect(http.calls.single.query, {'page': 2, 'limit': 30});
      final page = (result as Success<FollowPage>).data;
      expect(page.hasNext, true);
      expect(page.cards.single.status.followedBy, true);
      expect(page.cards.single.status.mutual, false);
    });
  });

  group('whispers', () {
    test('sending posts the body to the recipient', () async {
      http.response = const Success({
        'id': 70,
        'conversationId': 7,
        'senderId': 'me',
        'body': 'Oi',
        'system': false,
        'mine': true,
        'createdAt': '2026-10-26T20:00:00Z',
      });

      final result = await repository.sendMessage('bia-id', 'Oi');

      expect(http.calls.single.path, '/api/v1/users/bia-id/messages');
      expect(http.calls.single.body, {'body': 'Oi'});
      expect((result as Success<Message>).data.mine, true);
    });

    test(
      'a conversation maps the other member and the last system message',
      () async {
        http.response = const Success({
          'id': 7,
          'other': _actor,
          'enabled': false,
          'lastMessage': {
            'id': 71,
            'conversationId': 7,
            'senderId': null,
            'body': 'mutual_lost',
            'system': true,
            'createdAt': '2026-10-26T20:00:00Z',
          },
          'unread': 1,
          'lastMessageAt': '2026-10-26T20:00:00Z',
        });

        final result = await repository.getConversation(7);

        final conversation = (result as Success<Conversation>).data;
        expect(conversation.enabled, false);
        expect(
          conversation.lastMessage?.systemCode,
          SystemMessageCode.mutualLost,
        );
      },
    );

    test(
      'messages and the badge come from their WebSocket events only',
      () async {
        final messages = <Message>[];
        final counts = <UnreadCount>[];
        final subscriptions = [
          repository.watchMessages().listen(messages.add),
          repository.watchUnreadCount().listen(counts.add),
        ];

        socket.controller
          ..add(
            const WsMessage(
              type: WsMessageType.importProgress,
              data: {'jobId': '1'},
            ),
          )
          ..add(
            const WsMessage(
              type: WsMessageType.message,
              data: {
                'conversationId': '7',
                'messageId': '72',
                'senderId': 'bia-id',
                'body': 'Viu?',
                'system': 'false',
                'createdAt': '2026-10-26T20:00:00Z',
              },
            ),
          )
          ..add(
            const WsMessage(
              type: WsMessageType.message,
              data: {'body': 'sem id'},
            ),
          )
          ..add(
            const WsMessage(
              type: WsMessageType.unread,
              data: {'conversations': '1', 'messages': '3'},
            ),
          );
        await Future<void>.delayed(Duration.zero);

        expect(messages.single.id, 72);
        expect(messages.single.senderId, 'bia-id');
        expect(messages.single.system, false);
        expect(counts.single.messages, 3);
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
  });

  group('use cases', () {
    test('a blank or too long whisper never reaches the server', () async {
      final send = SendWhisper(repository);

      final blank = await send(
        const SendWhisperParams(userId: 'bia-id', body: '   '),
      );
      final long = await send(
        SendWhisperParams(userId: 'bia-id', body: 'x' * (whisperMaxLength + 1)),
      );

      expect((blank as Failure).error, AppError.badRequest);
      expect((long as Failure).error, AppError.badRequest);
      expect(http.calls, isEmpty);
    });

    test('the whisper is trimmed before it goes', () async {
      http.response = const Success({
        'id': 1,
        'conversationId': 7,
        'body': 'Oi',
      });

      await SendWhisper(repository)(
        const SendWhisperParams(userId: 'bia-id', body: '  Oi \n'),
      );

      expect(http.calls.single.body, {'body': 'Oi'});
    });

    test('the follow list use case picks the list', () async {
      http.response = const Success({
        'results': [],
        'page': 1,
        'hasNext': false,
      });

      await GetFollowList(repository)(
        const GetFollowListParams(userId: 'ana-id', list: FollowList.following),
      );

      expect(http.calls.single.path, '/api/v1/users/ana-id/following');
    });
  });
}
