import 'package:core/core.dart';

/// Whether the user already went through the introduction (F11.1). Kept on
/// the device: it shows once per install.
abstract interface class OnboardingRepository {
  Result<bool> hasSeen();

  Result<void> markSeen();

  Result<void> reset();
}

class ShouldShowOnboarding extends UseCase<void, Result<bool>> {
  final OnboardingRepository _repository;

  ShouldShowOnboarding(this._repository);

  @override
  Future<Result<bool>> call([void params]) async =>
      switch (_repository.hasSeen()) {
        Success(:final data) => Success(!data),
        Failure(:final error) => Failure(error),
      };
}

class MarkOnboardingSeen extends UseCase<void, Result<void>> {
  final OnboardingRepository _repository;

  MarkOnboardingSeen(this._repository);

  @override
  Future<Result<void>> call([void params]) async => _repository.markSeen();
}

/// "Rever introdução" in the settings: the next launch shows it again.
class ResetOnboarding extends UseCase<void, Result<void>> {
  final OnboardingRepository _repository;

  ResetOnboarding(this._repository);

  @override
  Future<Result<void>> call([void params]) async => _repository.reset();
}
