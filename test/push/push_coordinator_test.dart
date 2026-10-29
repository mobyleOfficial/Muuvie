import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:muuvie/push/push_coordinator.dart';
import 'package:profile/profile.dart';
import 'package:social_network/social_network.dart';

import '../helpers/fake_push_messaging.dart';
import '../helpers/fake_social_network_repository.dart';

void main() {
  late FakeSocialNetworkRepository repository;
  late FakePushMessaging push;
  late StreamController<UserProfile> profiles;
  late StreamController<void> sessionEnded;
  late List<PageRouteInfo> opened;
  late PushCoordinator coordinator;

  UserProfile profile(String id) =>
      UserProfile(id: id, photoUrl: '', username: id, bio: '');

  PushCoordinator build() => PushCoordinator(
    push: push,
    registerDevice: RegisterPushDevice(repository, push),
    profiles: profiles.stream,
    sessionEnded: sessionEnded.stream,
    open: opened.add,
  );

  setUp(() {
    repository = FakeSocialNetworkRepository();
    push = FakePushMessaging();
    profiles = StreamController<UserProfile>.broadcast();
    sessionEnded = StreamController<void>.broadcast();
    opened = [];
    coordinator = build();
  });

  tearDown(() async {
    await coordinator.dispose();
    await profiles.close();
    await sessionEnded.close();
    await repository.dispose();
    await push.dispose();
  });

  List<String> registrations() =>
      repository.calls.where((c) => c.startsWith('registerDevice')).toList();

  test('a signed-in user is asked once and their device registered', () async {
    await coordinator.start();

    profiles
      ..add(profile('u1'))
      ..add(profile('u1'));
    await pumpEventQueue();

    expect(push.permissionRequests, 1);
    expect(registrations(), hasLength(1));
  });

  test('a refreshed token is registered again', () async {
    await coordinator.start();
    profiles.add(profile('u1'));
    await pumpEventQueue();

    push.currentToken = 'token-2';
    push.refreshes.add('token-2');
    await pumpEventQueue();

    expect(registrations().last, startsWith('registerDevice:android:token-2'));
  });

  test('after the session ends the same user registers again', () async {
    await coordinator.start();
    profiles.add(profile('u1'));
    await pumpEventQueue();

    sessionEnded.add(null);
    profiles.add(profile('u1'));
    await pumpEventQueue();

    expect(registrations(), hasLength(2));
  });

  test('no profile, no registration, even when the token changes', () async {
    await coordinator.start();
    push.refreshes.add('token-2');
    await pumpEventQueue();

    expect(registrations(), isEmpty);
  });

  test(
    'a tapped push opens its screen, from closed or from the background',
    () async {
      push.initial = PushNotification.fromData({
        'type': 'maratona_started',
        'slug': 'outubro',
      });
      await coordinator.start();
      push.opened.add(
        PushNotification.fromData({
          'type': 'maratona_finished',
          'slug': 'novembro',
        }),
      );
      await pumpEventQueue();

      expect(opened.map((r) => (r.args as MaratonaDetailRouteArgs).slug), [
        'outubro',
        'novembro',
      ]);
    },
  );
}
