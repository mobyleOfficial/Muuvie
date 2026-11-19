import 'package:core/core.dart';
import 'package:auth_domain/repositories/auth_repository.dart';

/// Deletes the account and everything it made, then ends the session.
/// `Success(false)` when the user gave up on the Apple confirmation.
class DeleteAccount extends UseCase<void, Result<bool>> {
  final AuthRepository _repository;

  DeleteAccount(this._repository);

  @override
  Future<Result<bool>> call([void params]) => _repository.deleteAccount();
}
