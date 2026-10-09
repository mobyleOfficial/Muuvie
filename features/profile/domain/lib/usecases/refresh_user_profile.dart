import 'package:profile_domain/repositories/profile_repository.dart';

class RefreshUserProfile {
  final ProfileRepository _profileRepository;

  RefreshUserProfile(this._profileRepository);

  Future<void> call() => _profileRepository.fetchProfile();
}
