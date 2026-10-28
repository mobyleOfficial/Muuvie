import 'package:core/core.dart';
import 'package:shelves_domain/models/shelf_transfer_mode.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class TransferShelfMoviesParams {
  final int shelfId;
  final int targetShelfId;
  final ShelfTransferMode mode;

  /// Empty moves or copies every movie of the shelf.
  final List<int> movieIds;

  const TransferShelfMoviesParams({
    required this.shelfId,
    required this.targetShelfId,
    required this.mode,
    this.movieIds = const [],
  });
}

class TransferShelfMovies
    extends UseCase<TransferShelfMoviesParams, Result<void>> {
  final ShelvesRepository _repository;

  TransferShelfMovies(this._repository);

  @override
  Future<Result<void>> call([TransferShelfMoviesParams? params]) async {
    final value = params!;
    if (value.shelfId == value.targetShelfId) {
      return const Failure(AppError.badRequest);
    }
    return _repository.transferShelfMovies(
      shelfId: value.shelfId,
      targetShelfId: value.targetShelfId,
      mode: value.mode,
      movieIds: value.movieIds,
    );
  }
}
