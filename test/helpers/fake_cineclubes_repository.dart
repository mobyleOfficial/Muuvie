import 'package:cineclubes/cineclubes.dart';
import 'package:core/core.dart';

/// Answers with the results set by the test and records what was asked.
class FakeCineClubesRepository implements CineClubesRepository {
  Result<CineClubePage> pageResult = const Success(
    CineClubePage(cineclubes: []),
  );
  Result<CineClube>? cineclubeResult;
  Result<CineClube>? joinResult;
  Result<void> leaveResult = const Success(null);
  Result<CineClubeLogPage> progressResult = const Success(
    CineClubeLogPage(logs: []),
  );
  Result<ParticipantPage> participantsResult = const Success(
    ParticipantPage(participants: []),
  );

  final filters = <CineClubeFilter>[];
  final joins = <String?>[];
  final progressFilters = <SessionProgress?>[];
  final progressSessions = <int?>[];
  var leaves = 0;

  @override
  Future<Result<CineClubePage>> getCineClubes(
    CineClubeFilter filter, {
    int page = 1,
  }) async {
    filters.add(filter);
    return pageResult;
  }

  @override
  Future<Result<CineClube>> getCineClube(String slug) async =>
      cineclubeResult ?? const Failure(AppError.notFound);

  @override
  Future<Result<CineClubeSlug>> checkSlug(String slug) async =>
      Success(CineClubeSlug(slug: slug, valid: true, available: true));

  @override
  Future<Result<CineClube>> create(CineClubeForm form) async =>
      cineclubeResult ?? const Failure(AppError.server);

  @override
  Future<Result<CineClube>> update(String slug, CineClubeForm form) async =>
      cineclubeResult ?? const Failure(AppError.server);

  @override
  Future<Result<CineClube>> cancel(String slug) async =>
      cineclubeResult ?? const Failure(AppError.server);

  @override
  Future<Result<CineClube>> join(String slug, {String? password}) async {
    joins.add(password);
    return joinResult ?? cineclubeResult ?? const Failure(AppError.server);
  }

  @override
  Future<Result<void>> leave(String slug) async {
    leaves++;
    return leaveResult;
  }

  @override
  Future<Result<CineClubeLogPage>> getProgress(
    String slug, {
    int? sessionId,
    int page = 1,
  }) async {
    progressSessions.add(sessionId);
    return progressResult;
  }

  @override
  Future<Result<ParticipantPage>> getParticipants(
    String slug, {
    int? sessionId,
    SessionProgress? progress,
    int page = 1,
  }) async {
    progressFilters.add(progress);
    return participantsResult;
  }
}
