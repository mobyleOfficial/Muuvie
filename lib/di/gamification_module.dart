import 'package:core/core.dart';
import 'package:gamification/gamification.dart';
import 'package:injectable/injectable.dart';

@module
abstract class GamificationModule {
  @lazySingleton
  GamificationRemoteDataSource gamificationRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => GamificationRemoteDataSourceImpl(httpClient);

  @lazySingleton
  GamificationRepository gamificationRepository(
    GamificationRemoteDataSource remoteDataSource,
    WebSocketClient webSocketClient,
  ) => GamificationRepositoryImpl(remoteDataSource, webSocketClient);

  @injectable
  GetPetShelter getPetShelter(GamificationRepository repository) =>
      GetPetShelter(repository);

  @injectable
  GetProfilePets getProfilePets(GamificationRepository repository) =>
      GetProfilePets(repository);

  @injectable
  ChooseStarterPet chooseStarterPet(GamificationRepository repository) =>
      ChooseStarterPet(repository);

  @injectable
  PinPet pinPet(GamificationRepository repository) => PinPet(repository);

  @injectable
  GetMissions getMissions(GamificationRepository repository) =>
      GetMissions(repository);

  @injectable
  GetDiaryDay getDiaryDay(GamificationRepository repository) =>
      GetDiaryDay(repository);

  @injectable
  SaveDiaryDay saveDiaryDay(GamificationRepository repository) =>
      SaveDiaryDay(repository);

  @injectable
  GetDiaryMonth getDiaryMonth(GamificationRepository repository) =>
      GetDiaryMonth(repository);

  @injectable
  GetDiaryYear getDiaryYear(GamificationRepository repository) =>
      GetDiaryYear(repository);

  @injectable
  WatchPartyActions watchPartyActions(GamificationRepository repository) =>
      WatchPartyActions(repository);

  @injectable
  GetPosterRound getPosterRound(GamificationRepository repository) =>
      GetPosterRound(repository);
}
