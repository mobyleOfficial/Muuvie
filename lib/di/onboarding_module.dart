import 'dart:io';

import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:objectbox/objectbox.dart';
import 'package:onboarding/onboarding.dart';

@module
abstract class OnboardingModule {
  // Next to the ObjectBox directory, like the feature flags.
  @lazySingleton
  OnboardingRepository onboardingRepository(
    LocalClient localClient,
    Store store,
  ) => OnboardingRepositoryImpl(
    localClient,
    File('${Directory(store.directoryPath).parent.path}/onboarding_seen'),
  );

  @injectable
  ShouldShowOnboarding shouldShowOnboarding(OnboardingRepository repository) =>
      ShouldShowOnboarding(repository);

  @injectable
  MarkOnboardingSeen markOnboardingSeen(OnboardingRepository repository) =>
      MarkOnboardingSeen(repository);

  @injectable
  ResetOnboarding resetOnboarding(OnboardingRepository repository) =>
      ResetOnboarding(repository);
}
