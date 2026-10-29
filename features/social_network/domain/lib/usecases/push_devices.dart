import 'package:core/core.dart';
import 'package:social_network_domain/repositories/social_network_repository.dart';

/// Registers this device's push token on the backend (fase 15), with the app
/// language for the texts. Without permission or a token it does nothing.
class RegisterPushDevice extends UseCase<String?, Result<void>> {
  final SocialNetworkRepository _repository;
  final PushMessaging _push;

  RegisterPushDevice(this._repository, this._push);

  @override
  Future<Result<void>> call([String? locale]) async {
    if (!await _push.isPermitted()) return const Success(null);
    final token = await _push.token();
    if (token == null) return const Success(null);
    return _repository.registerDevice(_push.platform, token, locale);
  }
}

/// Stops the push to this device, before the session ends on logout.
class RemovePushDevice extends UseCase<void, Result<void>> {
  final SocialNetworkRepository _repository;
  final PushMessaging _push;

  RemovePushDevice(this._repository, this._push);

  @override
  Future<Result<void>> call([void params]) async {
    final token = await _push.token();
    if (token == null) return const Success(null);
    final result = await _repository.removeDevice(token);
    // A new token is made on the next login, so the old one cannot come back.
    await _push.deleteToken();
    return result;
  }
}
