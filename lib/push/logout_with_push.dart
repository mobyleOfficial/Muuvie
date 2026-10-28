import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:social_network/social_network.dart';

/// [Logout] that first stops the push to this device (fase 15), while the
/// session can still call the backend. Every logout button uses it through DI.
class LogoutWithPush extends Logout {
  final RemovePushDevice _removePushDevice;

  LogoutWithPush(super.repository, this._removePushDevice);

  @override
  Future<Result<void>> call([void params]) async {
    // Best effort, like the server side of the logout.
    await _removePushDevice();
    return super.call();
  }
}
