import 'package:core/core.dart';
import 'package:profile_domain/models/models.dart';
import 'package:profile_domain/repositories/profiles_repository.dart';
import 'package:shelves_domain/models/paged.dart';
import 'package:shelves_domain/usecases/discover_shelves.dart'
    show DiscoverParams;

/// A profile by id, `me` or `@handle` (F5.1, F5.5).
class GetProfileDetails extends UseCase<String, Result<ProfileDetails>> {
  final ProfilesRepository _repository;

  GetProfileDetails(this._repository);

  @override
  Future<Result<ProfileDetails>> call([String? params]) =>
      _repository.getProfile(params ?? 'me');
}

/// Saves the own profile (F5.3).
class SaveMyProfile extends UseCase<ProfileDraft, Result<ProfileDetails>> {
  final ProfilesRepository _repository;

  SaveMyProfile(this._repository);

  @override
  Future<Result<ProfileDetails>> call([ProfileDraft? params]) =>
      _repository.updateMyProfile(params!);
}

/// Checks a handle as the user types it. An invalid format is answered locally.
class CheckHandleAvailability
    extends UseCase<String, Result<HandleAvailability>> {
  final ProfilesRepository _repository;

  CheckHandleAvailability(this._repository);

  @override
  Future<Result<HandleAvailability>> call([String? params]) async {
    final handle = HandleAvailability.normalize(params ?? '');
    if (!HandleAvailability.format.hasMatch(handle)) {
      return Success(
        HandleAvailability(
          handle: handle,
          available: false,
          problem: HandleProblem.invalid,
        ),
      );
    }
    return _repository.checkHandle(handle);
  }
}

/// The Destaques of a profile (F5.4).
class GetProfileHighlights
    extends UseCase<String, Result<List<ProfileHighlight>>> {
  final ProfilesRepository _repository;

  GetProfileHighlights(this._repository);

  @override
  Future<Result<List<ProfileHighlight>>> call([String? params]) =>
      _repository.getHighlights(params ?? 'me');
}

/// Replaces the Destaques of the own profile (F5.4).
class SaveProfileHighlights
    extends UseCase<List<ProfileHighlight>, Result<List<ProfileHighlight>>> {
  final ProfilesRepository _repository;

  SaveProfileHighlights(this._repository);

  @override
  Future<Result<List<ProfileHighlight>>> call([
    List<ProfileHighlight>? params,
  ]) => _repository.saveHighlights(params ?? const []);
}

/// Profiles to follow in the Catálogo, curated first (F5.6); the Pessoas tab
/// of the search filters them by name (F14.2).
class DiscoverProfiles
    extends UseCase<DiscoverParams, Result<Paged<ProfileCard>>> {
  final ProfilesRepository _repository;

  DiscoverProfiles(this._repository);

  @override
  Future<Result<Paged<ProfileCard>>> call([DiscoverParams? params]) =>
      _repository.discoverProfiles(
        query: params?.query,
        page: params?.page ?? 1,
      );
}
