import 'package:social_network_domain/models/social_user.dart';

/// What a report points at; [wireValue] is the `targetType` of `POST /reports`.
enum ReportTarget {
  user('user'),
  activity('activity'),
  comment('comment'),
  message('message'),
  shelf('shelf'),
  locadora('locadora'),
  maratona('maratona'),
  cineclube('cineclube'),
  watchLog('watch_log');

  final String wireValue;

  const ReportTarget(this.wireValue);
}

/// Why something is reported.
enum ReportReason {
  spam('spam'),
  harassment('harassment'),
  hate('hate'),
  sexual('sexual'),
  violence('violence'),
  impersonation('impersonation'),
  spoiler('spoiler'),
  other('other');

  final String wireValue;

  const ReportReason(this.wireValue);
}

/// An account the current user blocked.
class BlockedUser {
  final SocialUser user;
  final DateTime blockedAt;

  const BlockedUser({required this.user, required this.blockedAt});
}

class BlockedPage {
  final List<BlockedUser> users;
  final int page;
  final bool hasNext;

  const BlockedPage({
    required this.users,
    required this.page,
    required this.hasNext,
  });
}
