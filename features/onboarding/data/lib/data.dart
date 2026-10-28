import 'dart:io';

import 'package:core/core.dart';
import 'package:onboarding_domain/domain.dart';

/// The "seen" mark in a small file next to the local database.
class OnboardingRepositoryImpl implements OnboardingRepository {
  final LocalClient _localClient;
  final File _file;

  OnboardingRepositoryImpl(this._localClient, this._file);

  @override
  Result<bool> hasSeen() => _localClient.execute(_file.existsSync);

  @override
  Result<void> markSeen() => _localClient.execute(
    () => _file.writeAsStringSync(
      DateTime.now().toUtc().toIso8601String(),
      flush: true,
    ),
  );

  @override
  Result<void> reset() => _localClient.execute(() {
    if (_file.existsSync()) _file.deleteSync();
  });
}
