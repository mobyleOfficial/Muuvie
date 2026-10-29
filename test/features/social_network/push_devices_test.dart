import 'package:flutter_test/flutter_test.dart';
import 'package:social_network/social_network.dart';

import '../../helpers/fake_push_messaging.dart';
import '../../helpers/fake_social_network_repository.dart';

void main() {
  late FakeSocialNetworkRepository repository;
  late FakePushMessaging push;

  setUp(() {
    repository = FakeSocialNetworkRepository();
    push = FakePushMessaging();
  });

  tearDown(() async {
    await repository.dispose();
    await push.dispose();
  });

  group('RegisterPushDevice', () {
    test(
      'sends the platform, the token and the language when allowed',
      () async {
        push.permitted = true;

        await RegisterPushDevice(repository, push)('pt_BR');

        expect(repository.calls, ['registerDevice:android:token-1:pt_BR']);
      },
    );

    test('does nothing without permission or without a token', () async {
      await RegisterPushDevice(repository, push)('pt');
      push
        ..permitted = true
        ..currentToken = null;
      await RegisterPushDevice(repository, push)('pt');

      expect(repository.calls, isEmpty);
    });
  });

  group('RemovePushDevice', () {
    test('removes the token on the server and on the device', () async {
      await RemovePushDevice(repository, push)();

      expect(repository.calls, ['removeDevice:token-1']);
      expect(push.tokenDeletions, 1);
    });

    test('does nothing without a token', () async {
      push.currentToken = null;

      await RemovePushDevice(repository, push)();

      expect(repository.calls, isEmpty);
      expect(push.tokenDeletions, 0);
    });
  });
}
