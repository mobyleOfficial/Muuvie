import 'package:auth_domain/repositories/auth_repository.dart';

/// Emits after each sign-in, so what depends on the account (the WebSocket,
/// the session profile and the push registration) starts again.
class ObserveSessionStarted {
  final AuthRepository _repository;

  ObserveSessionStarted(this._repository);

  Stream<void> call() => _repository.observeSessionStarted();
}
