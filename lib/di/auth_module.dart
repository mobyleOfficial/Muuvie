import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:auth/auth.dart';
import 'package:muuvie/push/logout_with_push.dart';
import 'package:social_network/social_network.dart';

@module
abstract class AuthModule {
  @lazySingleton
  SecureTokenStorage secureTokenStorage() => SecureTokenStorage();

  @lazySingleton
  OAuthRemoteDataSource oauthRemoteDataSource() => OAuthRemoteDataSourceImpl();

  @lazySingleton
  AuthRemoteDataSource authRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => AuthRemoteDataSourceImpl(httpClient);

  @lazySingleton
  AuthLocalDataSource authLocalDataSource(SecureTokenStorage secureStorage) =>
      AuthLocalDataSourceImpl(secureStorage);

  @lazySingleton
  AuthRepository authRepository(
    OAuthRemoteDataSource oauthRemoteDataSource,
    AuthRemoteDataSource authRemoteDataSource,
    AuthLocalDataSource localDataSource,
  ) => AuthRepositoryImpl(
    oauthRemoteDataSource,
    authRemoteDataSource,
    localDataSource,
  );

  @injectable
  Login loginUseCase(AuthRepository repository) => Login(repository);

  @injectable
  LoginWithEmail loginWithEmailUseCase(AuthRepository repository) =>
      LoginWithEmail(repository);

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
  SignUp signUpUseCase(AuthRepository repository) => SignUp(repository);

  @injectable
  CheckNicknameAvailability checkNicknameAvailabilityUseCase(
    AuthRepository repository,
  ) => CheckNicknameAvailability(repository);
}
