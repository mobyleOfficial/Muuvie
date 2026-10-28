import 'package:core/core.dart';
import 'package:auth_domain/repositories/auth_repository.dart';

/// Ends the session on the server (best effort) and always clears it locally.
class Logout extends UseCase<void, Result<void>> {
  final AuthRepository _repository;

  Logout(this._repository);

  @override
  Future<Result<void>> call([void params]) async => _repository.logout();
}
