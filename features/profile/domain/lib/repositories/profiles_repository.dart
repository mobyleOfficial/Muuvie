import 'package:core/core.dart';
import 'package:profile_domain/models/models.dart';
import 'package:shelves_domain/models/paged.dart';

/// Profiles of the v1 API (`/api/v1/users`, F5.1–F5.5).
abstract interface class ProfilesRepository {
  /// [userId] is a user id, `me`, or a handle with the @ (`@cinefila`).
  Future<Result<ProfileDetails>> getProfile(String userId);

  /// Conflict when the handle is taken, bad request when a field is invalid.
  Future<Result<ProfileDetails>> updateMyProfile(ProfileDraft draft);

  Future<Result<HandleAvailability>> checkHandle(String handle);

  /// Others get the enabled sections they can open; `me` gets every section.
  Future<Result<List<ProfileHighlight>>> getHighlights(String userId);

  /// Replaces my highlights; the list order is the order on the profile.
  Future<Result<List<ProfileHighlight>>> saveHighlights(
    List<ProfileHighlight> highlights,
  );

  /// [query] filters by name, @ or username (F14.2).
  Future<Result<Paged<ProfileCard>>> discoverProfiles({
    String? query,
    required int page,
  });
}
