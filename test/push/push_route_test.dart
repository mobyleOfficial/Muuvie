import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imports_ui/imports_router.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:muuvie/push/push_route.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:whispers/whispers_router.dart';

void main() {
  PushNotification push(String type, Map<String, String> data) =>
      PushNotification.fromData({'type': type, ...data});

  test('a Sussurro opens the conversation with the sender', () {
    final route = pushRoute(
      push('message', {'senderId': 'u1', 'name': 'Ana', 'conversationId': '9'}),
    );

    expect(route, isA<ConversationRoute>());
    final args = route!.args as ConversationRouteArgs;
    expect((args.userId, args.name, args.conversationId), ('u1', 'Ana', 9));
  });

  test('a system message without a sender opens nothing', () {
    expect(pushRoute(push('message', {'senderId': ''})), isNull);
  });

  test('a new follower and a love open the profile of who did it', () {
    for (final type in ['new_follower', 'activity_loved']) {
      final route = pushRoute(push(type, {'userId': 'u2', 'name': 'Bia'}));

      expect(route, isA<PublicProfileRoute>());
      expect((route!.args as PublicProfileRouteArgs).userId, 'u2');
    }
  });

  test('a maratona and a CineClube open their page by slug', () {
    final maratona = pushRoute(
      push('maratona_finished', {'slug': 'outubro', 'title': 'Terror 70'}),
    );
    final cineclube = pushRoute(push('cineclube_debate', {'slug': 'noir'}));

    expect((maratona!.args as MaratonaDetailRouteArgs).slug, 'outubro');
    expect((cineclube!.args as CineClubeDetailRouteArgs).slug, 'noir');
  });

  test('an import opens its job, or the import screen without a job id', () {
    final job = pushRoute(push('import_updated', {'jobId': '7'}));

    expect((job!.args as ImportJobRouteArgs).jobId, 7);
    expect(pushRoute(push('import_updated', {})), isA<ImportStartRoute>());
  });

  test('an unknown type opens nothing', () {
    expect(pushRoute(push('watch_party', {'code': 'X'})), isNull);
  });
}
