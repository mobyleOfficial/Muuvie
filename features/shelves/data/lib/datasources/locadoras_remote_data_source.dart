import 'package:core/core.dart';
import 'package:shelves_data/models/models.dart';
import 'package:shelves_domain/models/models.dart';

abstract interface class LocadorasRemoteDataSource {
  Future<Result<RemotePage<RemoteLocadora>>> getUserLocadoras({
    required String userId,
    required int page,
  });

  Future<Result<RemotePage<RemoteLocadora>>> discoverLocadoras({
    String? query,
    required int page,
  });

  Future<Result<RemoteLocadora>> getLocadora(int locadoraId);

  Future<Result<RemoteLocadora>> createLocadora(LocadoraDraft draft);

  Future<Result<RemoteLocadora>> updateLocadora(
    int locadoraId,
    LocadoraDraft draft,
  );

  Future<Result<void>> deleteLocadora(int locadoraId);

  Future<Result<RemotePage<RemoteLocadoraShelf>>> getLocadoraShelves({
    required int locadoraId,
    required int page,
  });

  Future<Result<void>> setLocadoraShelves({
    required int locadoraId,
    required List<int> shelfIds,
  });

  Future<Result<void>> reorderLocadoraShelves({
    required int locadoraId,
    required List<int> shelfIds,
  });

  Future<Result<void>> reorderLocadoras({
    required List<int> locadoraIds,
    List<int>? pinnedIds,
  });
}
