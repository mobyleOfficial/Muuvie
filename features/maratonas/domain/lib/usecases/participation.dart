import 'package:core/core.dart';
import 'package:maratonas_domain/models/models.dart';
import 'package:maratonas_domain/repositories/maratonas_repository.dart';

class JoinMaratonaParams {
  final String slug;
  final int? levelId;
  final int? teamId;
  final String? password;

  const JoinMaratonaParams({
    required this.slug,
    this.levelId,
    this.teamId,
    this.password,
  });
}

/// Joins a maratona (F7.4); the backend creates the "Fila" shelf.
class JoinMaratona extends UseCase<JoinMaratonaParams, Result<Maratona>> {
  final MaratonasRepository _repository;

  JoinMaratona(this._repository);

  @override
  Future<Result<Maratona>> call([JoinMaratonaParams? params]) {
    final value = params!;
    return _repository.join(
      value.slug,
      levelId: value.levelId,
      teamId: value.teamId,
      password: value.password,
    );
  }
}

/// Leaves a maratona; the "Fila" shelf and the links go with it.
class LeaveMaratona extends UseCase<String, Result<void>> {
  final MaratonasRepository _repository;

  LeaveMaratona(this._repository);

  @override
  Future<Result<void>> call([String? slug]) => _repository.leave(slug!);
}

class GetMaratonaChallenges
    extends UseCase<String, Result<List<MaratonaCategory>>> {
  final MaratonasRepository _repository;

  GetMaratonaChallenges(this._repository);

  @override
  Future<Result<List<MaratonaCategory>>> call([String? slug]) =>
      _repository.getChallenges(slug!);
}

class GetChallengeSuggestionsParams {
  final String slug;
  final int challengeId;
  final int page;

  const GetChallengeSuggestionsParams({
    required this.slug,
    required this.challengeId,
    this.page = 1,
  });
}

/// Movies that fit a challenge's criteria ("Descoberta", F7.3).
class GetChallengeSuggestions
    extends UseCase<GetChallengeSuggestionsParams, Result<SuggestionPage>> {
  final MaratonasRepository _repository;

  GetChallengeSuggestions(this._repository);

  @override
  Future<Result<SuggestionPage>> call([GetChallengeSuggestionsParams? params]) {
    final value = params!;
    return _repository.getSuggestions(
      value.slug,
      value.challengeId,
      page: value.page,
    );
  }
}

class SetChallengeLinkParams {
  final String slug;
  final int challengeId;
  final int movieId;
  final bool linked;

  const SetChallengeLinkParams({
    required this.slug,
    required this.challengeId,
    required this.movieId,
    required this.linked,
  });
}

/// Marks a challenge with a movie by hand, or takes it back (F7.5).
class SetChallengeLink
    extends UseCase<SetChallengeLinkParams, Result<MaratonaChallenge>> {
  final MaratonasRepository _repository;

  SetChallengeLink(this._repository);

  @override
  Future<Result<MaratonaChallenge>> call([SetChallengeLinkParams? params]) {
    final value = params!;
    return _repository.setLink(
      value.slug,
      value.challengeId,
      value.movieId,
      linked: value.linked,
    );
  }
}

class GetMaratonaRankingParams {
  final String slug;
  final int page;

  const GetMaratonaRankingParams({required this.slug, this.page = 1});
}

/// Participants ranked by challenges done (F7.6).
class GetMaratonaRanking
    extends UseCase<GetMaratonaRankingParams, Result<RankingPage>> {
  final MaratonasRepository _repository;

  GetMaratonaRanking(this._repository);

  @override
  Future<Result<RankingPage>> call([GetMaratonaRankingParams? params]) {
    final value = params!;
    return _repository.getRanking(value.slug, page: value.page);
  }
}

class GetTeamRanking extends UseCase<String, Result<List<TeamRankingEntry>>> {
  final MaratonasRepository _repository;

  GetTeamRanking(this._repository);

  @override
  Future<Result<List<TeamRankingEntry>>> call([String? slug]) =>
      _repository.getTeamRanking(slug!);
}
