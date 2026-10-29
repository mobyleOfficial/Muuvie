import 'package:auto_route/auto_route.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:core/core.dart';
import 'package:imports_ui/imports_router.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:whispers/whispers_router.dart';

/// The screen a tapped push opens (fase 15, D1). The types and fields are the
/// ones of `SocialEvent` in the backend; an unknown type opens nothing.
PageRouteInfo? pushRoute(PushNotification push) {
  final data = push.data;
  String? field(String key) {
    final value = data[key];
    return value == null || value.isEmpty ? null : value;
  }

  return switch (push.type) {
    'message' => switch (field('senderId')) {
      final userId? => ConversationRoute(
        userId: userId,
        name: field('name') ?? '',
        conversationId: int.tryParse(data['conversationId'] ?? ''),
      ),
      null => null,
    },
    'new_follower' || 'activity_loved' => switch (field('userId')) {
      final userId? => PublicProfileRoute(
        userId: userId,
        displayName: field('name'),
      ),
      null => null,
    },
    'maratona_started' || 'maratona_finished' => switch (field('slug')) {
      final slug? => MaratonaDetailRoute(
        slug: slug,
        title: field('title') ?? '',
      ),
      null => null,
    },
    'cineclube_debate' => switch (field('slug')) {
      final slug? => CineClubeDetailRoute(
        slug: slug,
        title: field('title') ?? '',
      ),
      null => null,
    },
    'import_updated' => switch (int.tryParse(data['jobId'] ?? '')) {
      final jobId? => ImportJobRoute(jobId: jobId),
      null => const ImportStartRoute(),
    },
    _ => null,
  };
}
