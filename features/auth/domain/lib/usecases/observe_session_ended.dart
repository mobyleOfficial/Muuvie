import 'package:auth_domain/repositories/auth_repository.dart';

/// Emits whenever the session ends: logout or a refresh token that is no longer valid.
class ObserveSessionEnded {
  final AuthRepository _repository;

  ObserveSessionEnded(this._repository);

  Stream<void> call() => _repository.observeSessionEnded();
}
