import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:profile/profile.dart';

@module
abstract class ProfileModule {
  @lazySingleton
  ProfileRemoteDataSource profileRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => ProfileRemoteDataSourceImpl(httpClient);

  @lazySingleton
  ProfileRepository profileRepository(
    ProfileRemoteDataSource profileRemoteDataSource,
    WebSocketClient webSocketClient,
  ) => ProfileRepositoryImpl(profileRemoteDataSource, webSocketClient);

  @lazySingleton
  ProfilesRemoteDataSource profilesRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => ProfilesRemoteDataSourceImpl(httpClient);

  @lazySingleton
  ProfilesRepository profilesRepository(
    ProfilesRemoteDataSource remoteDataSource,
  ) => ProfilesRepositoryImpl(remoteDataSource);

  @injectable
  GetProfileDetails getProfileDetails(ProfilesRepository repository) =>
      GetProfileDetails(repository);

  @injectable
  SaveMyProfile saveMyProfile(ProfilesRepository repository) =>
      SaveMyProfile(repository);

  @injectable
  CheckHandleAvailability checkHandleAvailability(
    ProfilesRepository repository,
  ) => CheckHandleAvailability(repository);

  @injectable
  GetProfileHighlights getProfileHighlights(ProfilesRepository repository) =>
      GetProfileHighlights(repository);

  @injectable
  SaveProfileHighlights saveProfileHighlights(ProfilesRepository repository) =>
      SaveProfileHighlights(repository);

  @injectable
  DiscoverProfiles discoverProfiles(ProfilesRepository repository) =>
      DiscoverProfiles(repository);

  @injectable
  UpdateUserProfile updateUserProfile(ProfileRepository repository) =>
      UpdateUserProfile(repository);

  @injectable
  ObserveUserProfile getUserProfile(ProfileRepository repository) =>
      ObserveUserProfile(repository);

  @injectable
  RefreshUserProfile refreshUserProfile(ProfileRepository repository) =>
      RefreshUserProfile(repository);
}
