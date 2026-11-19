import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:auth/auth.dart';
import 'package:muuvie/push/logout_with_push.dart';
import 'package:social_network/social_network.dart';

@module
abstract class AuthModule {
  @lazySingleton
  SecureTokenStorage secureTokenStorage() => SecureTokenStorage();

  // Google client ids come from secrets/.env.dev (--dart-define-from-file): the
  // web client the ID token is issued for, and the iOS client.
  @lazySingleton
  SocialSignInDataSource socialSignInDataSource() => SocialSignInDataSourceImpl(
    googleServerClientId: const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    ),
    googleIosClientId: const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
  );

  @lazySingleton
  AuthRemoteDataSource authRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => AuthRemoteDataSourceImpl(httpClient);

  @lazySingleton
  AuthLocalDataSource authLocalDataSource(SecureTokenStorage secureStorage) =>
      AuthLocalDataSourceImpl(secureStorage);

  @lazySingleton
  AuthRepository authRepository(
    SocialSignInDataSource socialSignInDataSource,
    AuthRemoteDataSource authRemoteDataSource,
    AuthLocalDataSource localDataSource,
  ) => AuthRepositoryImpl(
    socialSignInDataSource,
    authRemoteDataSource,
    localDataSource,
  );

  @injectable
  Login loginUseCase(AuthRepository repository) => Login(repository);

  @injectable
  ChooseNickname chooseNicknameUseCase(AuthRepository repository) =>
      ChooseNickname(repository);

  @injectable
  IsUserAuthenticated isUserAuthenticatedUseCase(AuthRepository repository) =>
      IsUserAuthenticated(repository);

  // Stops the push to this device before the session ends (fase 15).
  @injectable
  Logout logoutUseCase(
    AuthRepository repository,
    RemovePushDevice removePushDevice,
  ) => LogoutWithPush(repository, removePushDevice);

  @injectable
  ObserveSessionEnded observeSessionEndedUseCase(AuthRepository repository) =>
      ObserveSessionEnded(repository);

  @injectable
  CheckNicknameAvailability checkNicknameAvailabilityUseCase(
    AuthRepository repository,
  ) => CheckNicknameAvailability(repository);
}
