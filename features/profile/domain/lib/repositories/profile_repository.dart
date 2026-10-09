import 'package:core/core.dart';
import 'package:movies_domain/models/movie_listing.dart';
import 'package:movies_domain/models/movie_review_listing.dart';
import 'package:profile_domain/models/user_profile.dart';

abstract interface class ProfileRepository {
  Future<Result<MovieReviewListing>> getUserReviews({required int page});
  Future<Result<MovieListing>> getUserFavoriteMovies({
    required String userId,
    required int page,
  });
  Future<Result<void>> updateUserProfile({required UserProfile profile});
  Stream<UserProfile> watchProfile();
  Future<void> fetchProfile();
  Future<Result<void>> startScrape({
    required String source,
    required String username,
    required String cookies,
  });
}
