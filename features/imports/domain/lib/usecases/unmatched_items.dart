import 'package:core/core.dart';
import 'package:imports_domain/models/models.dart';
import 'package:imports_domain/repositories/imports_repository.dart';

class GetUnmatchedItemsParams {
  final int jobId;
  final int page;

  const GetUnmatchedItemsParams({required this.jobId, this.page = 1});
}

/// Movies of the import that need the user to confirm the match (F3.4).
class GetUnmatchedItems
    extends UseCase<GetUnmatchedItemsParams, Result<UnmatchedPage>> {
  final ImportsRepository _repository;

  GetUnmatchedItems(this._repository);

  @override
  Future<Result<UnmatchedPage>> call([GetUnmatchedItemsParams? params]) =>
      _repository.getUnmatched(params!.jobId, page: params.page);
}

class ResolveUnmatchedItemParams {
  final int jobId;
  final int itemId;

  /// Null skips: the movie stays as it came from the source.
  final MovieCandidate? candidate;

  const ResolveUnmatchedItemParams({
    required this.jobId,
    required this.itemId,
    this.candidate,
  });
}

/// Confirms a candidate in one tap, or skips (F3.4).
class ResolveUnmatchedItem
    extends UseCase<ResolveUnmatchedItemParams, Result<UnmatchedItem>> {
  final ImportsRepository _repository;

  ResolveUnmatchedItem(this._repository);

  @override
  Future<Result<UnmatchedItem>> call([ResolveUnmatchedItemParams? params]) {
    final value = params!;
    final candidate = value.candidate;
    return candidate == null
        ? _repository.skipUnmatched(value.jobId, value.itemId)
        : _repository.matchUnmatched(value.jobId, value.itemId, candidate);
  }
}
