import 'package:cineclubes/cineclubes.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

@module
abstract class CineClubesModule {
  @lazySingleton
  CineClubesRemoteDataSource cineclubesRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => CineClubesRemoteDataSourceImpl(httpClient);

  @lazySingleton
  CineClubesRepository cineclubesRepository(
    CineClubesRemoteDataSource remoteDataSource,
  ) => CineClubesRepositoryImpl(remoteDataSource);

  @injectable
  GetCineClubes getCineClubes(CineClubesRepository repository) =>
      GetCineClubes(repository);

  @injectable
  GetCineClube getCineClube(CineClubesRepository repository) =>
      GetCineClube(repository);

  @injectable
  CheckCineClubeSlug checkCineClubeSlug(CineClubesRepository repository) =>
      CheckCineClubeSlug(repository);

  @injectable
  SaveCineClube saveCineClube(CineClubesRepository repository) =>
      SaveCineClube(repository);

  @injectable
  CancelCineClube cancelCineClube(CineClubesRepository repository) =>
      CancelCineClube(repository);

  @injectable
  JoinCineClube joinCineClube(CineClubesRepository repository) =>
      JoinCineClube(repository);

  @injectable
  LeaveCineClube leaveCineClube(CineClubesRepository repository) =>
      LeaveCineClube(repository);

  @injectable
  GetCineClubeProgress getCineClubeProgress(CineClubesRepository repository) =>
      GetCineClubeProgress(repository);

  @injectable
  GetCineClubeParticipants getCineClubeParticipants(
    CineClubesRepository repository,
  ) => GetCineClubeParticipants(repository);
}
