import 'package:core/core.dart';
import 'package:social_network_domain/models/models.dart';
import 'package:social_network_domain/repositories/social_network_repository.dart';

class SetBlockedParams {
  final String userId;

  /// True to block, false to unblock.
  final bool blocked;

  const SetBlockedParams({required this.userId, required this.blocked});
}

/// Blocks or unblocks an account. A block removes the follows both ways and
/// hides each one from the other; it answers whether the account is blocked now.
class SetBlocked extends UseCase<SetBlockedParams, Result<bool>> {
  final SocialNetworkRepository _repository;

  SetBlocked(this._repository);

  @override
  Future<Result<bool>> call([SetBlockedParams? params]) =>
      _repository.setBlocked(params!.userId, params.blocked);
}

/// The accounts the current user blocked, newest first.
class GetBlockedUsers extends UseCase<int, Result<BlockedPage>> {
  final SocialNetworkRepository _repository;

  GetBlockedUsers(this._repository);

  @override
  Future<Result<BlockedPage>> call([int? page]) =>
      _repository.getBlockedUsers(page: page ?? 1);
}

class ReportParams {
  final ReportTarget target;
  final String targetId;
  final ReportReason reason;
  final String? details;

  const ReportParams({
    required this.target,
    required this.targetId,
    required this.reason,
    this.details,
  });
}

/// Sends a report of an account or a piece of content to the team.
class ReportContent extends UseCase<ReportParams, Result<void>> {
  final SocialNetworkRepository _repository;

  ReportContent(this._repository);

  @override
  Future<Result<void>> call([ReportParams? params]) => _repository.report(
    params!.target,
    params.targetId,
    params.reason,
    params.details,
  );
}
