import 'package:core/core.dart';
import 'package:profile_data/models/remote_profile_v1.dart';
import 'package:profile_domain/models/models.dart';
import 'package:shelves_data/models/remote_page.dart';

/// Profiles on the v1 API (`/api/v1`). See the backend README, "Profiles".
abstract interface class ProfilesRemoteDataSource {
  Future<Result<RemoteProfileDetails>> getProfile(String userId);

  Future<Result<RemoteProfileDetails>> updateMyProfile(ProfileDraft draft);

  Future<Result<RemoteHandleAvailability>> checkHandle(String handle);

  Future<Result<List<RemoteProfileHighlight>>> getHighlights(String userId);

  Future<Result<List<RemoteProfileHighlight>>> saveHighlights(
    List<ProfileHighlight> highlights,
  );

  Future<Result<RemotePage<RemoteProfileCard>>> discoverProfiles({
    String? query,
    required int page,
  });
}
