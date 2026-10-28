import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';

abstract interface class LocadorasRepository {
  /// Locadoras of [userId] the caller can see; `me` is the current user.
  Future<Result<Paged<Locadora>>> getUserLocadoras({
    required String userId,
    required int page,
  });

  /// Public locadoras of other users for the Catálogo (F5.6).
  Future<Result<Paged<Locadora>>> discoverLocadoras({
    String? query,
    required int page,
  });

  Future<Result<Locadora>> getLocadora(int locadoraId);

  Future<Result<Locadora>> createLocadora(LocadoraDraft draft);

  Future<Result<Locadora>> updateLocadora(int locadoraId, LocadoraDraft draft);

  /// Deletes the locadora only; its shelves stay.
  Future<Result<void>> deleteLocadora(int locadoraId);

  Future<Result<Paged<LocadoraShelf>>> getLocadoraShelves({
    required int locadoraId,
    required int page,
  });

  /// Replaces the shelves of the locadora.
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
