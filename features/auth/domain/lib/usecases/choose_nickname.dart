import 'package:core/core.dart';
import 'package:auth_domain/repositories/auth_repository.dart';

/// Sets the nickname a new account picks after its first sign-in.
class ChooseNickname extends UseCase<String, Result<void>> {
  final AuthRepository _repository;

  ChooseNickname(this._repository);

  @override
  Future<Result<void>> call([String? params]) async =>
      _repository.chooseNickname(params!);
}
