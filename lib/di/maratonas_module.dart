import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:maratonas/maratonas.dart';

@module
abstract class MaratonasModule {
  @lazySingleton
  MaratonasRemoteDataSource maratonasRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => MaratonasRemoteDataSourceImpl(httpClient);

  @lazySingleton
  MaratonasRepository maratonasRepository(
    MaratonasRemoteDataSource remoteDataSource,
  ) => MaratonasRepositoryImpl(remoteDataSource);

  @injectable
  GetMaratonas getMaratonas(MaratonasRepository repository) =>
      GetMaratonas(repository);

  @injectable
  GetMaratona getMaratona(MaratonasRepository repository) =>
      GetMaratona(repository);

  @injectable
  CheckMaratonaSlug checkMaratonaSlug(MaratonasRepository repository) =>
      CheckMaratonaSlug(repository);

  @injectable
  SaveMaratona saveMaratona(MaratonasRepository repository) =>
      SaveMaratona(repository);

  @injectable
  CancelMaratona cancelMaratona(MaratonasRepository repository) =>
      CancelMaratona(repository);

  @injectable
  GetMaratonaTemplates getMaratonaTemplates(MaratonasRepository repository) =>
      GetMaratonaTemplates(repository);

  @injectable
  CreateMaratonaFromTemplate createMaratonaFromTemplate(
    MaratonasRepository repository,
  ) => CreateMaratonaFromTemplate(repository);

  @injectable
  JoinMaratona joinMaratona(MaratonasRepository repository) =>
      JoinMaratona(repository);

  @injectable
  LeaveMaratona leaveMaratona(MaratonasRepository repository) =>
      LeaveMaratona(repository);

  @injectable
  GetMaratonaChallenges getMaratonaChallenges(MaratonasRepository repository) =>
      GetMaratonaChallenges(repository);

  @injectable
  GetChallengeSuggestions getChallengeSuggestions(
    MaratonasRepository repository,
  ) => GetChallengeSuggestions(repository);

  @injectable
  SetChallengeLink setChallengeLink(MaratonasRepository repository) =>
      SetChallengeLink(repository);

  @injectable
  GetMaratonaRanking getMaratonaRanking(MaratonasRepository repository) =>
      GetMaratonaRanking(repository);

  @injectable
  GetTeamRanking getTeamRanking(MaratonasRepository repository) =>
      GetTeamRanking(repository);
}
