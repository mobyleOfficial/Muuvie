import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:public_profile_feature/public_profile_feature.dart';

@module
abstract class PublicProfileModule {
  @lazySingleton
  PublicProfileRemoteDataSource publicProfileRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => PublicProfileRemoteDataSourceImpl(httpClient);

  @lazySingleton
  PublicProfileRepository publicProfileRepository(
    PublicProfileRemoteDataSource remoteDataSource,
  ) => PublicProfileRepositoryImpl(remoteDataSource);

  @injectable
  GetPublicProfile getPublicProfile(PublicProfileRepository repository) =>
      GetPublicProfile(repository);

  @injectable
  FollowUser followUser(PublicProfileRepository repository) =>
      FollowUser(repository);

  @injectable
  UnfollowUser unfollowUser(PublicProfileRepository repository) =>
      UnfollowUser(repository);

  @injectable
  GetMyFollowing getMyFollowing(PublicProfileRepository repository) =>
      GetMyFollowing(repository);
}
